function ok = CheckValidMove(grid, r, c, v, n)
% CHECKVALIDMOVE Essayer une valeur puis verifier sa ligne et sa colonne.
% Interface de SolveBinairoHeader.m ; indices et comparaisons de M1/M2.
ok = false;
if ~FormatGrilleValide(grid) || ~isa(n, 'double') || numel(n) ~= 1 || ...
        n ~= size(grid, 1) || ~isa(v, 'double') || numel(v) ~= 1 || ...
        ~(v == 0 || v == 1)
    return
end
if ~isa(r, 'double') || ~isa(c, 'double') || numel(r) ~= 1 || numel(c) ~= 1
    return
end
if imag(r) ~= 0 || imag(c) ~= 0 || ...
        ~(r >= 1 && r <= n && c >= 1 && c <= n) || ...
        mod(r, 1) ~= 0 || mod(c, 1) ~= 0
    return
end
if ~isnan(grid(r, c)) && grid(r, c) ~= v
    return
end
grid(r, c) = v;
ok = CheckVectorOk(grid(r, :), n) && ...
    CheckVectorOk(grid(:, c), n) && CheckVectorUniqueOk(grid, r, c, n);
end
