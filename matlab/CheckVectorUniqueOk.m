function ok = CheckVectorUniqueOk(grid, r, c, n)
% Projet Binairo - ME-213
% Auteurs : Louis Pédelaborde, Romeo Mugnier de Almeida, Raphaël Pical
% Comparer les lignes et colonnes completes, sans comparer une ligne a elle-meme.
  % Check that all full rows are unique, check current row against all the other rows
  % Check that all full cols are unique, idem.
ok = false;
if ~FormatGrilleValide(grid) || ~isa(n, 'double') || numel(n) ~= 1 || ...
        n ~= size(grid, 1) || ~isa(r, 'double') || ~isa(c, 'double') || ...
        numel(r) ~= 1 || numel(c) ~= 1
    return
end
if ~any(r == 1:n) || ~any(c == 1:n)
    return
end
ok = true;
if ~any(isnan(grid(r, :)))
    % Le produit matriciel repete la ligne courante pour comparer toutes les lignes.
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
