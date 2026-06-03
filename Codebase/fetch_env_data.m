% fetch_env_data.m
disp('Downloading Environment Data (Once)...');

try
    % Fetch Weather Data
    url = "https://api.open-meteo.com/v1/forecast?latitude=28.7&longitude=77.1&hourly=temperature_2m,relative_humidity_2m";
    data = webread(url);
    
    % Save to struct
    envCache.temp = data.hourly.temperature_2m;
    envCache.humid = data.hourly.relative_humidity_2m;
    envCache.time = 0; % Reset time
    
    disp('Success: Weather data saved to "envCache" variable.');
catch
    disp('Error: Could not fetch data. Using defaults.');
    envCache.temp = 25 * ones(1000,1);
    envCache.humid = 50 * ones(1000,1);
end