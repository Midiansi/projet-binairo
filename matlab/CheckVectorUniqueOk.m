function ok = CheckVectorUniqueOk(grid, r, c, n)
ok = false;
if ~FormatGrilleValide(grid) || ~isa(n, 'double') || numel(n) ~= 1 || ...
        n ~= size(grid, 1) || ~isa(r, 'double') || ~isa(c, 'double') || ...
        numel(r) ~= 1 || numel(c) ~= 1
    return
end
if imag(r) ~= 0 || imag(c) ~= 0 || ...
        ~(r >= 1 && r <= n && c >= 1 && c <= n) || ...
        mod(r, 1) ~= 0 || mod(c, 1) ~= 0
    return
end
ok = true;
if ~any(isnan(grid(r, :)))
    identiques = sum(grid == ones(n, 1) * grid(r, :), 2) == n;
    identiques(r) = false;
    ok = ~any(identiques);
end
if ok && ~any(isnan(grid(:, c)))
    identiques = sum(grid == grid(:, c) * ones(1, n), 1) == n;
    identiques(c) = false;
    ok = ~any(identiques);
end
end
