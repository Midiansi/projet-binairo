function ok = BinairoGridValid(grid)
% BINAIROGRIDVALID Validate every initial clue, including completed grids.
% AI-assisted team implementation, 2026. Human attribution: project report.
ok = BinairoShapeOK(grid);
if ~ok
    return
end
n = size(grid, 1);
ok = all(arrayfun(@(k) CheckVectorOk(grid(k, :), n) && ...
    CheckVectorOk(grid(:, k), n), 1:n));
if ~ok
    return
end
fullRows = grid(all(~isnan(grid), 2), :);
fullCols = grid(:, all(~isnan(grid), 1)).';
ok = size(unique(fullRows, 'rows'), 1) == size(fullRows, 1) && ...
    size(unique(fullCols, 'rows'), 1) == size(fullCols, 1);
end
