% evaluate_and_plot.m
% Run deterministic evaluation episodes and produce evaluation plots.
% Usage: edit params below if needed, then run evaluate_and_plot

clear; close all; clc;
rng(0,'twister');

%% ---------- User config ----------
agentFile = 'Remus_AUV_twin';   % trained agent file (change if needed)
mdl = 'Remus_AUV_twin';           % Simulink model name
StopTime = 200;                   % simulation stop time (seconds) per episode
N = 30;                           % number of evaluation episodes to run
savePlots = true;                 % save PNGs
plotFolder = fullfile(pwd,'eval_plots');
if ~exist(plotFolder,'dir'), mkdir(plotFolder); end

%% ---------- Load agent ----------
if ~exist(agentFile,'file')
    error('evaluate_and_plot: Could not find %s in folder %s', agentFile, pwd);
end
S = load(agentFile);
% Try to pick agent variable automatically (first RL object found)
agentNames = fieldnames(S);
agent = S.(agentNames{1});

%% ---------- Ensure envCache in base workspace if present ----------
if exist('envCache.mat','file')
    tmp = load('envCache.mat','envCache');
    assignin('base','envCache', tmp.envCache);
elseif evalin('base','exist(''envCache'',''var'')') == 0
    warning('envCache not found. For reproducible tests run fetch_env_data.m first.');
end

%% ---------- Prepare storage ----------
episodeRewards = nan(N,1);
episodeEnergy  = nan(N,1);
episodeSuccess = false(N,1);
timeToGoal     = nan(N,1);
trajectories = cell(N,1);
depthProfiles = cell(N,1);
batteryProfiles = cell(N,1);
timeProfiles = cell(N,1);

%% ---------- Helper: safe get logs element ----------
function dat = getLogElement(logsout, possibleNames)
    dat = [];
    if isempty(logsout), return; end
    if ischar(possibleNames), possibleNames = {possibleNames}; end
    for k=1:numel(possibleNames)
        name = possibleNames{k};
        try
            el = logsout.getElement(name);
            dat = el.Values;
            return;
        catch
            % skip
        end
    end
end

%% ---------- Run episodes ----------
disp('Starting evaluation episodes...');
for ep = 1:N
    fprintf('Episode %d/%d ... ', ep, N);
    try
        % clear persistents (avoid reward function carryover)
        clear rewardFcn rewardFcn_debug
        
        % Run sim
        simOut = sim(mdl, 'StopTime', num2str(StopTime), 'SimulationMode','normal', 'ShowProgress','off');
        
        % Attempt to find logsout
        logsout = [];
        try
            if isprop(simOut,'logsout')
                logsout = simOut.logsout;
            elseif isfield(simOut,'logsout')
                logsout = simOut.logsout;
            end
        catch
            logsout = [];
        end
        
        % 1) Episode reward (try common names)
        rVals = getLogElement(logsout, {'episodeReward','totalReward','reward','cumulativeReward','EpisodeReward'});
        if ~isempty(rVals)
            % If it's a timeseries, take last sample
            try
                episodeRewards(ep) = rVals.Data(end);
            catch
                episodeRewards(ep) = rVals(end);
            end
        else
            % Fallback: compute from state if possible later
            episodeRewards(ep) = NaN;
        end
        
        % 2) Energy (try common names)
        eVals = getLogElement(logsout, {'energy_total','energy_used','energy','Energy','battery_consumed'});
        if ~isempty(eVals)
            try
                episodeEnergy(ep) = eVals.Data(end);
            catch
                episodeEnergy(ep) = eVals(end);
            end
        else
            episodeEnergy(ep) = NaN;
        end
        
        % 3) Get positions (for trajectories); try a few likely names
        posVals = getLogElement(logsout, {'Pos_XYZ','pos','position','Position','AUV_Pos'});
        if ~isempty(posVals)
            % posVals.Data could be Nx3 or 3xN — normalize to Tx3
            dat = posVals.Data;
            if size(dat,2) == 3 && size(dat,1) > 3
                traj = dat; % Tx3
            elseif size(dat,1) == 3
                traj = dat'; % convert 3xT to Tx3
            else
                traj = dat; % whatever it is
            end
            trajectories{ep} = traj;
            timeProfiles{ep} = posVals.Time;
        else
            trajectories{ep} = [];
        end
        
        % 4) Depth profile
        depthVals = getLogElement(logsout, {'depth','Depth','z','pos_z','Pos_Z'});
        if ~isempty(depthVals)
            d = depthVals.Data;
            if size(d,2)>1 && size(d,1)>size(d,2)
                d = d';
            end
            depthProfiles{ep} = d;
        else
            depthProfiles{ep} = [];
        end
        
        % 5) Battery profile (or battery level)
        batVals = getLogElement(logsout, {'battery_level','Battery','Battery_Level','battery'});
        if ~isempty(batVals)
            b = batVals.Data;
            batteryProfiles{ep} = b;
        else
            batteryProfiles{ep} = [];
        end
        
        % 6) Success detection: try direct or compute by final distance to target
        succVals = getLogElement(logsout, {'isSuccess','success','ReachedTarget'});
        if ~isempty(succVals)
            try
                episodeSuccess(ep) = any(succVals.Data(:));
            catch
                episodeSuccess(ep) = logical(succVals.Data(end));
            end
        else
            % fallback: compute if pos and target present
            targVals = getLogElement(logsout, {'Target_XYZ','Target','target'});
            if ~isempty(trajectories{ep}) && ~isempty(targVals)
                try
                    finalPos = trajectories{ep}(end,1:2);
                    targ = targVals.Data(end,:);
                    if size(targ,1) == 1 && numel(targ) >= 2
                        episodeSuccess(ep) = norm(finalPos(:)-targ(1:2)') < 5;
                    else
                        episodeSuccess(ep) = false;
                    end
                catch
                    episodeSuccess(ep) = false;
                end
            else
                episodeSuccess(ep) = false; % unknown
            end
        end
        
        % 7) Time to goal: detect when distance < threshold during episode
        if ~isempty(trajectories{ep}) && ~isempty(targVals)
            try
                traj = trajectories{ep}(:,1:2);
                targ = targVals.Data(end,1:2);
                dists = vecnorm(traj(:,1:2) - targ(:)',2,2);
                idx = find(dists < 5, 1, 'first');
                if ~isempty(idx)
                    timeToGoal(ep) = timeProfiles{ep}(idx);
                else
                    timeToGoal(ep) = NaN;
                end
            catch
                timeToGoal(ep) = NaN;
            end
        end
        
        fprintf('done. Reward=%.2f, Energy=%.2f, Success=%d\n', episodeRewards(ep), episodeEnergy(ep), episodeSuccess(ep));
    catch ME
        fprintf('Episode %d failed: %s\n', ep, ME.message);
        episodeRewards(ep) = NaN;
        episodeEnergy(ep) = NaN;
        episodeSuccess(ep) = false;
    end
end

%% ---------- Save raw metrics ----------
eval_results.episodeRewards = episodeRewards;
eval_results.episodeEnergy = episodeEnergy;
eval_results.episodeSuccess = episodeSuccess;
eval_results.timeToGoal = timeToGoal;
eval_results.trajectories = trajectories;
eval_results.depthProfiles = depthProfiles;
eval_results.batteryProfiles = batteryProfiles;
eval_results.timeProfiles = timeProfiles;
save('eval_results.mat','eval_results');

%% ---------- Plot 1: Episode rewards ----------
figure('Name','Episode Rewards','Units','normalized','Position',[0.1 0.1 0.6 0.4]);
plot(1:N, episodeRewards, '-o','LineWidth',1.5); grid on;
xlabel('Episode'); ylabel('Total Reward'); title('Total Reward per Episode');
if savePlots, saveas(gcf, fullfile(plotFolder,'episode_rewards.png')); end

%% ---------- Plot 2: Episode energy ----------
figure('Name','Episode Energy','Units','normalized','Position',[0.1 0.1 0.6 0.4]);
plot(1:N, episodeEnergy, '-s','LineWidth',1.5); grid on;
xlabel('Episode'); ylabel('Energy Used'); title('Energy Used per Episode');
if savePlots, saveas(gcf, fullfile(plotFolder,'episode_energy.png')); end

%% ---------- Plot 3: Success rate ----------
figure('Name','Success Rate','Units','normalized','Position',[0.1 0.1 0.5 0.35]);
bar(1:N, double(episodeSuccess));
xlabel('Episode'); ylabel('Success (1/0)'); title(sprintf('Success per Episode (Rate = %.1f%%)', mean(episodeSuccess)*100));
if savePlots, saveas(gcf, fullfile(plotFolder,'success_per_episode.png')); end

% moving average success
window = max(1,round(N/10));
movAvg = movmean(double(episodeSuccess), window);
figure('Name','Success Moving Avg','Units','normalized','Position',[0.1 0.1 0.5 0.35]);
plot(1:N,movAvg,'-','LineWidth',1.8); grid on; xlabel('Episode'); ylabel('Moving Avg Success'); title('Moving average success');
if savePlots, saveas(gcf, fullfile(plotFolder,'success_moving_avg.png')); end

%% ---------- Plot 4: Example trajectories ----------
maxExamples = min(4,N);
figure('Name','Trajectories','Units','normalized','Position',[0.05 0.05 0.9 0.6]); hold on; grid on;
legendEntries = {};
for k=1:maxExamples
    traj = trajectories{k};
    if ~isempty(traj)
        plot(traj(:,1), traj(:,2), '-','LineWidth',1.5);
        legendEntries{end+1} = sprintf('Ep %d',k); %#ok<SAGROW>
    end
end
xlabel('X'); ylabel('Y'); title('XY Trajectories (example episodes)');
legend(legendEntries,'Location','best');
if savePlots, saveas(gcf, fullfile(plotFolder,'trajectories_examples.png')); end

%% ---------- Plot 5: depth & battery for first episode with data ----------
epiShow = find(~cellfun(@isempty, depthProfiles), 1, 'first');
if ~isempty(epiShow)
    tVec = timeProfiles{epiShow};
    figure('Name','Depth & Battery (example)','Units','normalized','Position',[0.1 0.1 0.7 0.5]);
    yyaxis left
    plot(tVec, depthProfiles{epiShow}, '-','LineWidth',1.5); ylabel('Depth');
    yyaxis right
    if ~isempty(batteryProfiles{epiShow})
        plot(tVec, batteryProfiles{epiShow}, '--','LineWidth',1.5); ylabel('Battery Level');
    end
    xlabel('Time (s)'); title(sprintf('Depth & Battery (Episode %d)', epiShow));
    grid on;
    if savePlots, saveas(gcf, fullfile(plotFolder,sprintf('depth_battery_ep%d.png',epiShow))); end
end

%% ---------- Summary printed ----------
fprintf('\nEVALUATION SUMMARY (N=%d)\n', N);
fprintf('Success rate: %.1f%% (%d/%d)\n', mean(episodeSuccess)*100, sum(episodeSuccess), N);
fprintf('Mean reward: %.3f (std %.3f)\n', nanmean(episodeRewards), nanstd(episodeRewards));
fprintf('Mean energy: %.3f (std %.3f)\n', nanmean(episodeEnergy), nanstd(episodeEnergy));
fprintf('Results saved to eval_results.mat and plots to %s\n', plotFolder);
