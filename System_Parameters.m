% pedal_params.m
% Parameters for pedal input AUTOSAR model

% Sampling time
Ts = 2.5000e-05; % 10 ms

T_total = 20;

% Pedal position range (0 = released, 1 = fully pressed)
Pedal_min = 0.0;
Pedal_max = 1.0;

% Pedal sensor scaling parameters
Pedal_gain = 100; % Convert normalized position to percentage
Pedal_offset = 0;

% Simulated driver input dynamics
Ramp_rate = 0.05; % per second increase

% Initial pedal position
Pedal_init = 0;