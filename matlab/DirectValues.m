function [grid, ok] = DirectValues(grid, n)
% DIRECTVALUES Propagate uniquely possible values until a fixed point.
% Source: current MATLAB exercise 2 p1; P00 2026.2 physical pp29,34.
% AI-assisted team implementation, 2026. Human attribution: project report.
% Independent candidate checks are vectorized with arrayfun. Every forced
% value is necessary in any extension, so assigning a batch is sound. The
% recursive next pass validates interactions and repeats until unchanged.
% Each recursive call fills at least one cell: depth <= initially empty cells.
original = grid;
ok = isnumeric(n) && isreal(n) && isscalar(n) && ...
    BinairoGridValid(grid) && n == size(grid, 1);
if ~ok
    return
end
empty = find(isnan(grid));
if isempty(empty)
    return
end
[rows, cols] = ind2sub([n n], empty);
canZero = arrayfun(@(r, c) CheckValidMove(grid, r, c, 0, n), rows, cols);
canOne = arrayfun(@(r, c) CheckValidMove(grid, r, c, 1, n), rows, cols);
if any(~canZero & ~canOne)
    ok = false;
    return
end
forced = xor(canZero, canOne);
if ~any(forced)
    return
end
grid(empty(forced)) = double(canOne(forced));
[grid, ok] = DirectValues(grid, n);
if ~ok
    grid = original;
end
end
