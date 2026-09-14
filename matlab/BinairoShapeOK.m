function ok = BinairoShapeOK(grid)
% BINAIROSHAPEOK Check the common even-square double/0/1/NaN contract.
% AI-assisted team implementation, 2026. Human attribution: project report.
% This checks representation only; contradictions are checked separately.
ok = isa(grid, 'double') && isreal(grid) && ismatrix(grid) && ...
    size(grid, 1) >= 2 && size(grid, 1) == size(grid, 2) && ...
    mod(size(grid, 1), 2) == 0;
if ok
    ok = all(isnan(grid(:)) | grid(:) == 0 | grid(:) == 1);
end
end
