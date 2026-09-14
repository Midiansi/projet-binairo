% SAMPLE_DRIVER Manual reference; LabVIEW must generate its own solve.m.
% Source matrix: Exo.Proj.Binairo.Matlab.1.pdf physical page 1.
% AI-assisted team implementation, 2026. Human attribution: project report.
runtimeDir = fileparts(mfilename('fullpath'));
addpath(runtimeDir);
B = [NaN 0 NaN NaN NaN NaN; NaN NaN 0 NaN 0 NaN; ...
    NaN NaN NaN NaN 1 0; 1 1 NaN NaN NaN NaN; ...
    NaN 0 NaN 0 NaN NaN; NaN NaN NaN NaN 0 NaN];
sourceFile = fullfile(runtimeDir, 'Binairo_6x6.png');
solveWithMatlab = true;
showPDF = true;
RunBinairo(B, sourceFile, solveWithMatlab, showPDF);
