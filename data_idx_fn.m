function [trainIdx,valIdx,testIdx] = data_idx_fn(s_num,num)

train = round(num * 0.8);
test = round(num * 0.1);
valid = num-(train+test);

% sum = train+test+valid

trainIdx = [s_num+1:1:train+s_num];
valIdx = [(train+s_num+1):1:(train+s_num+valid)];
testIdx = [(train+s_num+valid+1):1:s_num+num];