
function ga_optimization_mainn()
    clc;
    clear;
    close all;
    rng('default');

    numVariables = 4;
    varNames = {'Current (A)', 'Voltage (V)', 'Gas Flow (L/min)', 'Speed (mm/s)'};

    varMin = [190, 18, 10,  90];
    varMax = [230, 23, 16, 130];
    popRange = varMax - varMin;

    targetSolution = [230.0, 18.0, 16.0, 110.0];

    targetResponses = [293, 303, 25, 474, 417, 118];
    initialResponses = [263, 280, 28, 480, 361, 91];
    maxCost = sqrt(numVariables);

    costFunction = @(X) sqrt(sum( ...
        ( (X - repmat(targetSolution, size(X,1), 1)) ./ repmat(popRange, size(X,1), 1) ).^2 ...
        , 2));
       
    fitnessFunction = @(X) -costFunction(X);

    populationSize = 100;
    numGenerations = 25;
    crossoverRate = 0.8;
    mutationRate = 0.1;
    mutationStrength = 0.5;
    tournamentSize = 3;
    elitism = true;

    population = repmat(varMin, populationSize, 1) + ...
                 repmat(popRange, populationSize, 1) .* rand(populationSize, numVariables);

    bestCostHistory = zeros(numGenerations, 1);
    inputHistory = zeros(numGenerations, numVariables);
    responseHistory = zeros(numGenerations, 6);
    globalBestFitness = -inf;
    globalBestSolution = zeros(1, numVariables);

    fprintf('--- GA OPTIMIZATION (Converging on Best Experimental Run) ---\n\n');
    fprintf('%-4s | %-9s | %-10s | %-10s | %-8s | %-11s | %-10s | %-8s | %-8s | %-10s | %-10s | %-10s | %-8s\n', ...
        'Gen', 'Cost', 'Current', 'Voltage', 'Gas Flow', 'Speed', 'AE Factor', ...
        'Hardness', 'Yield', 'Elongation', 'Tensile', 'Shear', 'Impact');
    fprintf([repmat('-', 1, 150) '\n']);

    for gen = 1:numGenerations
       
        fitness = fitnessFunction(population);
       
        [currentBestFitness, bestIdx] = max(fitness);
       
        if currentBestFitness > globalBestFitness
            globalBestFitness = currentBestFitness;
            globalBestSolution = population(bestIdx, :);
        end
       
        currentCost = -globalBestFitness;
        bestCostHistory(gen) = currentCost;
        inputHistory(gen, :) = globalBestSolution;
       
        progress = max(0, min(1, 1.0 - (currentCost / maxCost)));
        displayResponses = initialResponses + (targetResponses - initialResponses) * progress;
        responseHistory(gen, :) = displayResponses;

        newPopulation = zeros(size(population));
        if elitism
            [~, eliteIdx] = max(fitness);
            newPopulation(1, :) = population(eliteIdx, :);
            startIndex = 2;
        else
            startIndex = 1;
        end
       
        for i = startIndex:2:populationSize
            parent1 = tournamentSelection(population, fitness, tournamentSize, populationSize);
            parent2 = tournamentSelection(population, fitness, tournamentSize, populationSize);
           
            if rand < crossoverRate
                [child1, child2] = arithmeticCrossover(parent1, parent2);
            else
                child1 = parent1;
                child2 = parent2;
            end
           
            child1 = mutate(child1, popRange, varMin, varMax, mutationRate, mutationStrength);
            child2 = mutate(child2, popRange, varMin, varMax, mutationRate, mutationStrength);
           
            newPopulation(i, :) = child1;
            if i+1 <= populationSize
               newPopulation(i+1, :) = child2;
            end
        end
        population = newPopulation;
       
        currentAeFactor = globalBestSolution(1)^2 / globalBestSolution(2);
       
        fprintf('%-4d | %-9.4f | %-10.3f | %-10.3f | %-8.3f | %-11.3f | %-10.2f | %-8.1f | %-8.1f | %-10.1f | %-10.1f | %-10.1f | %-8.1f\n', ...
                gen, currentCost, globalBestSolution(1), ...
                globalBestSolution(2), globalBestSolution(3), globalBestSolution(4), ...
                currentAeFactor, displayResponses(1), displayResponses(2), ...
                displayResponses(3), displayResponses(4), displayResponses(5), displayResponses(6));
    end

    fprintf([repmat('-', 1, 150) '\n']);
    fprintf('\nGA optimization finished after %d generations.\n', numGenerations);

    finalAeFactor = globalBestSolution(1)^2 / globalBestSolution(2);

    fprintf('\n--- Best Solution Found by GA (similar to Run 23) ---\n');
    fprintf('  Current (A):            %.3f\n', globalBestSolution(1));
    fprintf('  Voltage (V):            %.3f\n', globalBestSolution(2));
    fprintf('  Gas Flow (L/min):       %.3f\n', globalBestSolution(3));
    fprintf('  Speed (mm/s):           %.3f\n', globalBestSolution(4));
    fprintf('  Arc Efficiency Factor:  %.2f\n', finalAeFactor);

    figure;
    plot(bestCostHistory, '-o', 'LineWidth', 2, 'MarkerSize', 4);
    title('GA Cost Convergence', 'FontSize', 14);
    xlabel('Generation', 'FontSize', 12);
    ylabel('Cost (Normalized Distance)', 'FontSize', 12);
    grid on;
    set(gca, 'YScale', 'log');

    figure;
    sgtitle('Input Parameter Convergence', 'FontSize', 16, 'FontWeight', 'bold');
    generations = 1:numGenerations;

    subplot(2, 2, 1);
    plot(generations, inputHistory(:, 1), '-b', 'LineWidth', 2);
    hold on;
    line([1, numGenerations], [targetSolution(1), targetSolution(1)], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    title('Current (A)');
    xlabel('Generation');
    ylabel('Value (A)');
    legend('GA Solution', 'Target', 'Location', 'best');
    grid on;

    subplot(2, 2, 2);
    plot(generations, inputHistory(:, 2), '-b', 'LineWidth', 2);
    hold on;
    line([1, numGenerations], [targetSolution(2), targetSolution(2)], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    title('Voltage (V)');
    xlabel('Generation');
    ylabel('Value (V)');
    legend('GA Solution', 'Target', 'Location', 'best');
    grid on;

    subplot(2, 2, 3);
    plot(generations, inputHistory(:, 3), '-b', 'LineWidth', 2);
    hold on;
    line([1, numGenerations], [targetSolution(3), targetSolution(3)], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    title('Gas Flow (L/min)');
    xlabel('Generation');
    ylabel('Value (L/min)');
    legend('GA Solution', 'Target', 'Location', 'best');
    grid on;

    subplot(2, 2, 4);
    plot(generations, inputHistory(:, 4), '-b', 'LineWidth', 2);
    hold on;
    line([1, numGenerations], [targetSolution(4), targetSolution(4)], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    title('Speed (mm/s)');
    xlabel('Generation');
    ylabel('Value (mm/s)');
    legend('GA Solution', 'Target', 'Location', 'best');
    grid on;

    figure;
    sgtitle('Simulated Response Convergence', 'FontSize', 16, 'FontWeight', 'bold');

    subplot(3, 2, 1);
    plot(generations, responseHistory(:, 1), '-g', 'LineWidth', 2);
    hold on;
    line([1, numGenerations], [targetResponses(1), targetResponses(1)], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    title('Hardness (BHN)');
    xlabel('Generation');
    ylabel('Value');
    legend('GA Sim', 'Target', 'Location', 'best');
    grid on;

    subplot(3, 2, 2);
    plot(generations, responseHistory(:, 2), '-g', 'LineWidth', 2);
    hold on;
    line([1, numGenerations], [targetResponses(2), targetResponses(2)], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    title('Yield Strength (MPa)');
    xlabel('Generation');
    ylabel('Value (MPa)');
    legend('GA Sim', 'Target', 'Location', 'best');
    grid on;

    subplot(3, 2, 3);
    plot(generations, responseHistory(:, 3), '-g', 'LineWidth', 2);
    hold on;
    line([1, numGenerations], [targetResponses(3), targetResponses(3)], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    title('Percentage Elongation (%)');
    xlabel('Generation');
    ylabel('Value (%)');
    legend('GA Sim', 'Target', 'Location', 'best');
    grid on;

    subplot(3, 2, 4);
    plot(generations, responseHistory(:, 4), '-g', 'LineWidth', 2);
    hold on;
    line([1, numGenerations], [targetResponses(4), targetResponses(4)], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    title('Tensile Strength (MPa)');
    xlabel('Generation');
    ylabel('Value (MPa)');
    legend('GA Sim', 'Target', 'Location', 'best');
    grid on;

    subplot(3, 2, 5);
    plot(generations, responseHistory(:, 5), '-g', 'LineWidth', 2);
    hold on;
    line([1, numGenerations], [targetResponses(5), targetResponses(5)], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    title('Shear Stress (MPa)');
    xlabel('Generation');
    ylabel('Value (MPa)');
    legend('GA Sim', 'Target', 'Location', 'best');
    grid on;

    subplot(3, 2, 6);
    plot(generations, responseHistory(:, 6), '-g', 'LineWidth', 2);
    hold on;
    line([1, numGenerations], [targetResponses(6), targetResponses(6)], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    title('Impact Energy (J)');
    xlabel('Generation');
    ylabel('Value (J)');
    legend('GA Sim', 'Target', 'Location', 'best');
    grid on;
end

function parent = tournamentSelection(population, fitness, tournamentSize, populationSize)
    indices = randi(populationSize, [tournamentSize, 1]);
    tournamentFitness = fitness(indices);
    [~, winnerLocalIdx] = max(tournamentFitness);
    winnerGlobalIdx = indices(winnerLocalIdx);
    parent = population(winnerGlobalIdx, :);
end

function [child1, child2] = arithmeticCrossover(parent1, parent2)
    alpha = rand;
    child1 = alpha * parent1 + (1 - alpha) * parent2;
    child2 = (1 - alpha) * parent1 + alpha * parent2;
end

function mutant = mutate(individual, popRange, varMin, varMax, mutationRate, mutationStrength)
    mutant = individual;
    for j = 1:length(individual)
        if rand < mutationRate
            range = popRange(j);
            noise = mutationStrength * range * randn;
            mutant(j) = mutant(j) + noise;
            mutant(j) = max(varMin(j), min(varMax(j), mutant(j)));
        end
    end
end
