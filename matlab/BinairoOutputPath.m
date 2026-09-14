function [pdfPath, sourceName] = BinairoOutputPath(file)
% BINAIROOUTPUTPATH Derive the PDF beside these runtime functions.
% The input is the source PNG path/name; it need not be opened by MATLAB.
% AI-assisted team implementation, 2026. Human attribution: project report.
if isstring(file) && isscalar(file)
    file = char(file);
end
if ~ischar(file) || size(file, 1) ~= 1 || isempty(file) || ...
        any(file == char(0) | file == char(10) | file == char(13))
    error('Binairo:SourceFile', 'sourceFile must be a nonempty single PNG path.');
end
[~, name, ext] = fileparts(file);
if isempty(name) || ~strcmpi(ext, '.png')
    error('Binairo:SourceFile', 'sourceFile must have a basename and .png extension.');
end
sourceName = [name ext];
runtimeDir = fileparts(mfilename('fullpath'));
pdfPath = fullfile(runtimeDir, [name '.pdf']);
end
