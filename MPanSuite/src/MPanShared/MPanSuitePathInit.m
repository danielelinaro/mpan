function MPanSuitePathInit()
%
% Angelo Brambilla - Federico Bizzarri - Daniele Linaro
% Copyright (c) 2015.
% Revision: 2.0 $Date: 2022/03/10$
tmp = pwd;
tmp = [tmp '/mexANDso'];
setenv('PAN_SHL_PATH',tmp);
tmp = genpath('./');
addpath(tmp);