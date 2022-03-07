function MPanSuitePathInit()
tmp = pwd;
tmp = [tmp '/mexANDso'];
setenv('PAN_SHL_PATH',tmp);
tmp = genpath('./');
addpath(tmp);