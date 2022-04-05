function options = MPanOptions(varargin)
%
% Angelo Brambilla - Federico Bizzarri - Daniele Linaro
% Copyright (c) 2022.
% Revision: 2.0 $Date: 2022/03/10$

if rem(nargin,2) ~= 0
  error('MPanSuiteError: Arguments must be key-value pairs.');
end

% Initialize the output options structure
options = [];
for i = 1:2:nargin
  options.(varargin{i}) = [];
end
% Process each key-value pair

np = (nargin)/2;
j = 1;
for i = 1:np
  
  % Get the value
  val = varargin{j+1};

  % Set the proper field in options
  options.(varargin{j}) = val;
  
  % move to next pair  
  j = j+2;
  
end