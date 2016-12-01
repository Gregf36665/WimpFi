%% mean and std
clear
timing = [7842, 7282, 6922, 4162, 2282, 7842, 9162, 9362, 5522,...
        7242, 6882, 6762, 4202, 2922, 2242, 1922, 1802, 9322, 5442,...
        3562, 2602, 2042, 9482, 8042, 4882, 3242, 2442, 9682, 5602,...
        11200,6402, 3962, 10400, 8482, 7522, 7002, 4362, 10560, 6042,...
        3802, 2722, 9762, 8082, 7362, 4442, 3002, 9922, 5682, 3642,...
        10200, 5922, 11400, 8962, 5242, 11400, 8762, 7722, 4642, 10760,...
        8642, 5202, 3402, 10040, 9162, 7802, 7242, 6882, 6722, 4242, ...
        2882, 2242, 1882, 1722, 9362, 5482, 3642, 2602, 2082, 9482, 8002,...
        4842, 3282, 2402, 9642, 5682, 11240, 6442, 4042, 10400, 8442,...
        7562, 7042, 4322, 10520, 6082, 3842, 2722, 9842, 8202, 7442,...
        4482, 3122, 9962, 5802, 3682, 10200, 5962, 9122, 7842];

max_time = max(timing);
tmp = size(timing);
k = tmp(2);

predicted_max_time = (k+1)/k * max_time - 1;

variance = 1/k*(predicted_max_time-k)*(predicted_max_time+1)/(k+2);

std_dev = sqrt(variance);

max_time_95percentSure = predicted_max_time + 2*std_dev;
mean_timing = mean(timing);
error_percent = std_dev/sqrt(k);

fprintf('Max time: %4.0fus, Limit: 11840us\n', max_time_95percentSure)
fprintf('Mean time: %4.0fus, Expected: 6780us\n', mean_timing);
fprintf('Error on mean: %5.2f%%, Target: 10%%\n', error_percent);
fprintf('\n');

% Max 11840
% Min 1720
% Expected average 6780
