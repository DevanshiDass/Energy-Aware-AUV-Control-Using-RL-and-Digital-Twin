%% ROBUST RESULT GENERATION

% 1. SETUP
clear all; clear classes; close all;
setupAgent; 
% Load the agent (Check your filename)
if isfile('Trained_Remus_Agent_Final.mat')
    load('Trained_Remus_Agent_Final.mat', 'agentObj');
elseif isfile('Trained_Remus_Agent2.mat')
    load('Trained_Remus_Agent2.mat', 'agentObj');
else
    error('Agent file not found. Please check filename.');
end
fetch_env_data;

% 2. FORCE MODEL LOGGING SETTINGS
mdl = 'Remus_AUV_twin';
load_system(mdl);

% Force Simulink to save all states to 'xout' in Dataset format
set_param(mdl, 'SaveState', 'on');
set_param(mdl, 'StateSaveName', 'xout');
set_param(mdl, 'SaveFormat', 'Dataset');
set_param(mdl, 'LoggingToFile', 'off'); 

% 3. RUN LONG SIMULATION (FIXED)
T_stop = 150; % 150 seconds to see full path
assignin('base', 'agentObj', agentObj); 
assignin('base', 'T_stop_sim', T_stop);

disp('Running Simulation with Forced State Logging...');
% FIX: Calculate string value inside MATLAB before passing to Simulink
simOut = sim(mdl, 'StopTime', num2str(T_stop)); 
disp('Simulation Complete.');

% 4. SMART DATA FINDER
% We look for the variable with 5 columns (x, y, z, psi, energy)
found_data = [];
found_time = [];

try
    all_states = simOut.xout;
    num_elements = all_states.numElements;
    
    for i = 1:num_elements
        element = all_states{i};
        data = element.Values.Data;
        % Check if this element has 5 columns (The AUV State)
        if size(data, 2) == 5
            found_data = data;
            found_time = element.Values.Time;
            disp(['Success: Found AUV state data in element: ' element.Name]);
            break;
        end
    end
catch
    error('Could not parse simulation output. Check if simulation ran successfully.');
end

if isempty(found_data)
    error('CRITICAL: Simulation ran, but no 5-column state vector was found.');
end

% 5. PLOTTING FOR REPORT
X = found_data(:, 1);
Y = found_data(:, 2);
Z = found_data(:, 3);
Energy = found_data(:, 5);

% Normalize Energy to start at 0
Energy = Energy - Energy(1);

% Figure 1: Full Path
figure(1); clf;
plot(X, Y, 'b-', 'LineWidth', 2); hold on;
plot(X(1), Y(1), 'go', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Start');
plot(50, 50, 'rx', 'MarkerSize', 12, 'LineWidth', 2, 'DisplayName', 'Target');
legend('AUV Path', 'Start', 'Target', 'Location', 'best');
xlabel('X Position (m)'); ylabel('Y Position (m)');
title('Energy-Aware Autonomous Navigation (RL Agent)');
grid on; axis equal;
% Set limits to show the path clearly
xlim([-5 60]); ylim([-5 60]);

% Figure 2: Energy
figure(2); clf;
plot(found_time, Energy, 'r-', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Cumulative Energy (J)');
title('Energy Consumption Profile');
grid on;

% Figure 3: Convergence
dist = sqrt((X - 50).^2 + (Y - 50).^2);
figure(3); clf;
plot(found_time, dist, 'k-', 'LineWidth', 2);
yline(2.0, 'g--', 'Success Threshold');
xlabel('Time (s)'); ylabel('Distance to Target (m)');
title('Navigation Convergence');
grid on;

disp('Report figures generated successfully.');