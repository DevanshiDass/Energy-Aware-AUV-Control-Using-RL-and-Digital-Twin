%% 1) Model and Block Path
mdl = 'Remus_AUV_twin';
blk = [mdl '/RL Agent']; 

%% 2) Define Observation and Action Sizes
Nobs = 12;   % Observation vector size
Nact = 2;    % Action: [Thruster; Rudder]

%% 3) Define Observation & Action Specs
obsInfo = rlNumericSpec([Nobs 1], 'Name','observation');

% Define Action Limits (Thruster -1 to 1, Rudder -1 to 1)
actInfo = rlNumericSpec([Nact 1], 'Name','action', ...
    'LowerLimit',[-1; -1], ...
    'UpperLimit',[ 1;  1]);

%% 4) Create RL Simulink Environment
env = rlSimulinkEnv(mdl, blk, obsInfo, actInfo);
env.ResetFcn = @(in) in;

%% 5) Create Networks (Dual-Output Architecture)

% --- Common Shared Layers ---
commonLayers = [
    featureInputLayer(Nobs, 'Name', 'obs')
    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(128, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
];

% --- Create Critic (Value Function) ---
criticNet = layerGraph(commonLayers);
criticNet = addLayers(criticNet, fullyConnectedLayer(1, 'Name', 'V'));
criticNet = connectLayers(criticNet, 'relu2', 'V');

critic = rlValueFunction(criticNet, obsInfo, ...
    'ObservationInputNames', 'obs');

% --- Create Actor (Continuous Gaussian with 2 Outputs) ---
actorNet = layerGraph(commonLayers);

% Output 1: Mean (The main action decision)
actorNet = addLayers(actorNet, fullyConnectedLayer(Nact, 'Name', 'Mean'));
actorNet = connectLayers(actorNet, 'relu2', 'Mean');

% Output 2: Standard Deviation (Exploration noise)
% Must use 'softplus' to ensure standard deviation is always positive
actorNet = addLayers(actorNet, [
    fullyConnectedLayer(Nact, 'Name', 'std_fc')
    softplusLayer('Name', 'Std') 
]);
actorNet = connectLayers(actorNet, 'relu2', 'std_fc');

% Create Object: We now explicitly link both outputs
actor = rlContinuousGaussianActor(actorNet, obsInfo, actInfo, ...
    'ActionMeanOutputNames', 'Mean', ...
    'ActionStandardDeviationOutputNames', 'Std', ...
    'ObservationInputNames', 'obs');

%% 6) PPO Agent Options
opts = rlPPOAgentOptions( ...
    ClipFactor=0.2, ...
    ExperienceHorizon=512, ...
    MiniBatchSize=256, ...
    DiscountFactor=0.995, ...
    EntropyLossWeight=0.01);

%% 7) Create the Agent
agentObj = rlPPOAgent(actor, critic, opts);

disp('Success: Agent created with Mean & Std outputs.');