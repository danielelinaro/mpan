function MPanUpdateRawFilesList()
% MPanUpdateRawFilesList() updates the LIST of RAW FILES contained in the
% RAW FILES DIRECTORY of the currently loaded netlist
%
% Usage: MPanUpdateRawFilesList()
%
% Angelo Brambilla - Federico Bizzarri 
% Copyright (c) 2015.
% Revision: 1.0.0 $Date: 2015/02/10$

global MPanSuite_NETLIST_INFO

if isempty(MPanSuite_NETLIST_INFO) || ...
        isempty(MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_RAW_DIR)
    error(['PanSuiteError: it is not possible to update the RAW FILES ' ...
        'list in the GLOBAL variable MPanSuite_NETLIST_INFO since ' ...
        'either such variable is empty or '...
        'MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_RAW_DIR is empty.']);
end

D = dir(MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_RAW_DIR);

for k = 1:numel(D)
    if strcmp(D(k).name ,'.')
        D = [D(1:k-1); D(k+1:end)];
        break
    end
end
for k = 1:numel(D)
    if strcmp(D(k).name ,'..')
        D = [D(1:k-1); D(k+1:end)];
        break
    end
end
for k = 1:numel(D)
    if strcmp(D(k).name ,'rawindex')
        D = [D(1:k-1); D(k+1:end)];
        break
    end
end

for k = numel(D):-1:1
    tmp = rmfield(D(k),{'isdir','datenum'});
    MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_RAW_FILES(k,1) = tmp;
end
