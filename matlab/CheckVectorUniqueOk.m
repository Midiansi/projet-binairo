function ok = CheckVectorUniqueOk(grid, r, c, n)
% CHECKVECTORUNIQUEOK Compare the current completed row/column with peers.
% Incomplete vectors must not be rejected for sharing the same clues.
% AI-assisted team implementation, 2026. Human attribution: project report.
ok = BinairoShapeOK(grid) && isnumeric(n) && isscalar(n) && ...
    isreal(n) && n == size(grid, 1) && ...
    isnumeric(r) && isreal(r) && isscalar(r) && r >= 1 && r <= n && r == fix(r) && ...
    isnumeric(c) && isreal(c) && isscalar(c) && c >= 1 && c <= n && c == fix(c);
if ~ok
    return
end
rowOK = true;
colOK = true;
if ~any(isnan(grid(r, :)))
    same = all(bsxfun(@eq, grid, grid(r, :)), 2);
    same(r) = false;
    rowOK = ~any(same);
end
if ~any(isnan(grid(:, c)))
    same = all(bsxfun(@eq, grid, grid(:, c)), 1);
    same(c) = false;
    colOK = ~any(same);
end
ok = rowOK && colOK;
end
