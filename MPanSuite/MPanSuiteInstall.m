function [] = MPanSuiteInstall
% MPanSuiteInstall Interactive compilation and installation of MPanSuite

% Federico Bizzarri <federico.bizzarri@polimi.it>
% Copyright (c) 2015,
% $Revision: 1.1 $Date: 2015/04/10$

% MEX compiler command
% --------------------

mexcompiler = 'mex -ldl -outdir ./mex_so';

% Test mex and compile panet.c panget.c pansimc.c
% -----------------------------------------------

mex_ok = check_mex(mexcompiler);

if ~mex_ok
  return
else
    eval([mexcompiler ' ./mex_so/pannet.c']);
    eval([mexcompiler ' ./mex_so/panget.c']);
    eval([mexcompiler ' ./mex_so/pansimc.c']);
    eval([mexcompiler ' ./mex_so/panredraw.c']);
    eval([mexcompiler ' ./mex_so/panclearwav.c']);
end
fprintf('\n\nMEX files were successfully created.\n');

% Specify where to install MPanSuite
% ----------------------------------
answ = input('    Install MPanSuite? (y/n) ','s');
if answ ~= 'y'
  fprintf('\n\nOK. All done.\n');
  return
end

while true
  fprintf('\n\nSpecify the location where you wish to install MPanSuite.\n');
  fprintf('The suite will be installed in a subdirectory "MPanSuite".\n');
  fprintf('Enter return to cancel the installation.\n');
  where = input('    Installation directory: ','s');
  if strcmp(where,'..') || strcmp(where,'.')
      fprintf('. or .. ar not valid!\n');
      go = 0;
    break
  end
  if isempty(where)
    go = 0;
    break;
  end
  if exist(where,'dir')
    go = 1;
    break
  end
  fprintf('\n%s does not exist!\n', where);
end

if ~go
  fprintf('\n\nOK. Installation aborted.\n');
  return
end


% MPansuite root and subdirectories creation
% ------------------------------------------------------
stbi = fullfile(where,'MPanSuite');

go = 1;
if exist(stbi,'dir')
  fprintf('\n\nDirectory %s exists!\n',stbi);
  answ = input('    Replace? (y/n) ','s');
  if answ == 'y'
    rmdir(stbi,'s');
    go = 1;
  else
    go = 0;
  end
end

if ~go
  fprintf('\n\nOK. Installation aborted.\n');
  return
end

stbi = fullfile(where,'MPanSuite');
mkdir(stbi);
mkdir(fullfile(where,'MPanSuite/mex_so'));
mkdir(fullfile(where,'MPanSuite/src'));
mkdir(fullfile(where,'MPanSuite/src/MPanAlter'));
mkdir(fullfile(where,'MPanSuite/src/MPanShared'));
mkdir(fullfile(where,'MPanSuite/src/MPanTran'));
mkdir(fullfile(where,'MPanSuite/src/MPanShooting'));

% MPansuite files list creation
%------------------------------
mex_so_files = {
    fullfile('mex_so','panMat.so')
    fullfile('mex_so','panget.c')
    fullfile('mex_so','pannet.c')
    fullfile('mex_so','pansimc.c')
    fullfile('mex_so','panredraw.c')
    fullfile('mex_so','panclearwav.c')
    fullfile('mex_so','panget.mexa64')
    fullfile('mex_so','pannet.mexa64')
    fullfile('mex_so','pansimc.mexa64')
    fullfile('mex_so','panredraw.mexa64')
    fullfile('mex_so','panclearwav.mexa64')
};

src_shared_files = {
    fullfile('src/MPanShared','MPanLoadNet.m')
    fullfile('src/MPanShared','MPanOptions.m')
    fullfile('src/MPanShared','MPanSuitePathInit.m')
    fullfile('src/MPanShared','MPanUpdateRawFilesList.m')
    fullfile('src/MPanShared','MPanVarGetRawFile.m')
    fullfile('src/MPanShared','MPanVarInRawFile.m')
};

src_tran_files = {
    fullfile('src/MPanTran','MPanTran.m')
    fullfile('src/MPanTran','MPanTranSetOptions.m')
    fullfile('src/MPanTran','MPanTranSetOptionsShort.m')
};

src_alter_files = {
    fullfile('src/MPanAlter','MPanAlter.m')
    fullfile('src/MPanAlter','MPanAlterSetOptions.m')
};

src_shooting_files = {
    fullfile('src/MPanShooting','MPanShooting.m')
    fullfile('src/MPanShooting','MPanShootingSetOptions.m')
};

stb_files = [mex_so_files; src_shared_files; src_tran_files; src_alter_files; src_shooting_files];

% Now copying the MPanSuite files
%--------------------------------

stb = pwd;
cd('..');
cd(stb);

fprintf('\n\n');
for i=1:length(stb_files)
  src = fullfile(stb,stb_files{i});
  dest = fullfile(stbi,stb_files{i});
  fprintf('Install %s\n',dest);
  [success,msg] = copyfile(src,dest);
  if ~success
    disp(msg);
    break;
  end
end

% Create MPanSuiteInit.m (use the template MPanSuiteInit.in)
%-----------------------------------------------------------
stbi = fullfile(where,'MPanSuite');
stb = pwd;
cd(stbi);
MPanSuiteAbsolutePath = pwd;
cd(stb);
in_file = fullfile(stb,'MPanSuiteInit.in');
fi = fopen(in_file,'r');
out_file = fullfile(stbi,'MPanSuiteInit.m');
fo = fopen(out_file,'w');
while(~feof(fi))
  l = fgets(fi);
  i = strfind(l,'@MPS_PATH@');
  if ~isempty(i) %#ok<STREMP>
    l = sprintf('  stb = ''%s'';\n',MPanSuiteAbsolutePath);
  end
  fprintf(fo,'%s',l);
end
fclose(fo);
fclose(fi);

% Final comments
%---------------
fprintf('\n\nThe MPanSuite was installed in %s\n',stbi);
fprintf('\nA startup file, "MPanSuiteInit.m" was created in %s.\n',stbi);
fprintf('Use it as your Matlab startup file, or, if you already have a startup.m file,\n');
fprintf('add a call to %s\n',fullfile(stbi,'MPanSuiteInit.m'));
fprintf('\nEnjoy!\n\n');

%---------------------------------------------------------------------------------
% Check if mex works and if the user accepts the current mexopts
%---------------------------------------------------------------------------------

function mex_ok = check_mex(mexcompiler)

% Create a dummy file
fid = fopen('foo.c', 'w');
fprintf(fid,'#include "mex.h"\n');
fprintf(fid,'void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])\n');
fprintf(fid,'{return;}\n');
fclose(fid);

% Run mexcompiler on foo.c
mex_cmd = sprintf('%s foo.c\n', mexcompiler);
eval(mex_cmd);

% Remove dummy source file and resulting mex file
delete('foo.c')
delete(sprintf('./mex_so/foo.%s', mexext))

display([]);
disp('MEX files will be compiled and built using the above options');
display(mex_cmd);
display([]);

answ = input('    Proceed? (y/n) ','s');
if answ == 'y'
  mex_ok = true;
else
  fprintf('\n\nOK. Installation aborted.\n');
  mex_ok = false;
end

return
