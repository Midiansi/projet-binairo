function ok = CheckVectorUniqueOk(grid, r, c, n)
% CHECKVECTORUNIQUEOK Comparer une ligne ou colonne complete aux autres.
% Des vecteurs incomplets peuvent avoir les memes indices connus.
% Implementation avec assistance de Codex, 2026.
ok = FormatGrilleValide(grid) && isnumeric(n) && isscalar(n) && ...
    isreal(n) && n == size(grid, 1) && ...
    isnumeric(r) && isreal(r) && isscalar(r) && r >= 1 && r <= n && r == fix(r) && ...
    isnumeric(c) && isreal(c) && isscalar(c) && c >= 1 && c <= n && c == fix(c);
if ~ok
    return
end
ligneValide = true;
colonneValide = true;
if ~any(isnan(grid(r, :)))
    identiques = all(bsxfun(@eq, grid, grid(r, :)), 2);
    identiques(r) = false;
    ligneValide = ~any(identiques);
end
if ~any(isnan(grid(:, c)))
    identiques = all(bsxfun(@eq, grid, grid(:, c)), 1);
    identiques(c) = false;
    colonneValide = ~any(identiques);
end
ok = ligneValide && colonneValide;
end
