function DisplayBinairo(Original, Solution, file, feasible)
% DISPLAYBINAIRO Save the course-styled PDF in this runtime directory.
% Exact signature from current MATLAB exercise 1 p1.
% AI-assisted team implementation, 2026. Human attribution: project report.
[pdfPath, ~] = BinairoOutputPath(file);
if exist(pdfPath, 'file') == 2
    delete(pdfPath);
end
fig = CreateBinairoFigure(Original, Solution, file, feasible);
closeFigure = onCleanup(@() close(fig)); %#ok<NASGU>
temporary = [tempname(fileparts(pdfPath)) '.pdf'];
removeTemporary = onCleanup(@() DeleteTemporary(temporary)); %#ok<NASGU>
print(fig, temporary, '-dpdf', '-painters');
info = dir(temporary);
if isempty(info) || info.bytes == 0
    error('Binairo:PDFWrite', 'MATLAB did not create a nonempty PDF.');
end
[ok, message] = movefile(temporary, pdfPath, 'f');
if ~ok
    error('Binairo:PDFWrite', 'Could not save PDF: %s', message);
end
fprintf('PDF written: %s\n', pdfPath);
end

function DeleteTemporary(file)
if exist(file, 'file') == 2
    delete(file);
end
end
