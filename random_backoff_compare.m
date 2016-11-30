%%
timing = [21	50	31	15	26	44	6	29	40];

m = max(timing);
tmp = size(timing);
k = tmp(2);

mu = (m-1)*(k-1)/(k-2);
sigma = sqrt((k-1)*(m-1)*(m-k+1)/ ((k-3)*(k-2)^2));

fprintf('%2.5ius +/- %2.5ius\n\r', mu, sigma);

%% mean and std
clear;
timing = [];

mean_val = mean(timing);

std_dev = std(timing);

fprintf('%2.5ius +/- %2.5ius\n\r', mean_val, std_dev*2);
fprintf('Max: %2.5ius (95%)', mean_val + std_dev*2);