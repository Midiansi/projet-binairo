function [grid, valid] = SolveBinairo(grid)
valid = false;
if ~GrilleBinairoValide(grid)
    return
end
n = size(grid, 1);
[grid, ok] = DirectValues(grid, n);
if ~ok
    return
end
indicesVides = find(isnan(grid));
if isempty(indicesVides)
    valid = true;
    return
end
[r, c] = ind2sub([n n], indicesVides(1));
baseEssais = grid;
if CheckValidMove(baseEssais, r, c, 0, n)
    essai = baseEssais;
    essai(r, c) = 0;
    [grid, valid] = SolveBinairo(essai);
    if valid
        return
    end
end
if CheckValidMove(baseEssais, r, c, 1, n)
    essai = baseEssais;
    essai(r, c) = 1;
    [grid, valid] = SolveBinairo(essai);
end
end
