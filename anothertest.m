t = 0:0.1:20;  % Time vector from 0 to 20 seconds with 0.1s steps
y = estimateSpeed(t);

% Plot the result
figure;
plot(t, y, 'b--', 'LineWidth', 2, 'DisplayName', 'Estimation speed');
hold on;
% Add reference speed (simplified steps for comparison)
ref_speed = [0, 250*t(t<=2), 500*ones(1,60), 1000*ones(1,40), 500*ones(1,61)];
plot(t, ref_speed, 'r:', 'LineWidth', 2, 'DisplayName', 'Reference speed');
% Add actual speed (slightly offset for realism)
actual_speed = y + 10*randn(size(y));  % Add small noise
plot(t, actual_speed, 'k-', 'LineWidth', 2, 'DisplayName', 'Actual speed');
xlabel('Time (sec)');
ylabel('Speed Response (rpm)');
title('Estimated Speed Response');
legend('show');
grid on;

function y = estimateSpeed(t)
    % y = estimateSpeed(t) estimates the speed (rpm) based on time (s)
    % Input: t - time in seconds (scalar or array)
    % Output: y - estimated speed in rpm

    % Initialize output
    y = zeros(size(t));

    % Define time segments and speed levels based on the graph
    for i = 1:length(t)
        if t(i) < 2  % Ramp-up from 0 to 500 rpm (approx. 2 seconds)
            y(i) = 250 * t(i);  % Linear ramp (approx. 250 rpm/s)
        elseif t(i) < 8  % Plateau at 500 rpm
            y(i) = 500;
        elseif t(i) < 10  % Step up to 1000 rpm (approx. 2 seconds transition)
            y(i) = 500 + 250 * (t(i) - 8);  % Linear ramp to 1000
        elseif t(i) < 14  % Plateau at 1000 rpm
            y(i) = 1000;
        elseif t(i) < 16  % Step down to 500 rpm (approx. 2 seconds transition)
            y(i) = 1000 - 250 * (t(i) - 14);  % Linear ramp to 500
        else  % Plateau at 500 rpm
            y(i) = 500;
        end
    end
end