function ok = CheckValidMove(grid, r, c, v, n)
% CHECKVALIDMOVE Try a value on a copy, checking its row and column rules.
% Caller maintains validity of unaffected rows/columns. A clue cannot change.
% AI-assisted team implementation, 2026. Human attribution: project report.
ok = BinairoShapeOK(grid) && isnumeric(n) && isreal(n) && isscalar(n) && ...
    n == size(grid, 1) && isnumeric(v) && isreal(v) && isscalar(v) && ...
    (v == 0 || v == 1) && ...
    isnumeric(r) && isreal(r) && isscalar(r) && r >= 1 && r <= n && r == fix(r) && ...
    isnumeric(c) && isreal(c) && isscalar(c) && c >= 1 && c <= n && c == fix(c);
if ~ok
    return
end
if ~isnan(grid(r, c)) && grid(r, c) ~= v
    ok = false;
    return
end
grid(r, c) = v;
ok = CheckVectorOk(grid(r, :), n) && ...
    CheckVectorOk(grid(:, c), n) && CheckVectorUniqueOk(grid, r, c, n);
end
