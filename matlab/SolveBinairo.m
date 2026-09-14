function [grid, valid] = SolveBinairo(grid)
% SOLVEBINAIRO Solve an even square double matrix of 0,1 and NaN.
% [grid,valid] returns the first solution, or the unchanged input and false.
% Source: SolveBinairoHeader.m (8.9.2026), MATLAB 2 p1, P00 2026.2 pp29,34.
% The header's "n MUST be odd" is corrected to even, per current P00 p27.
% AI-assisted team implementation, 2026. Human attribution: project report.
% Required method: direct deductions, then genuine recursive backtracking.
% MATLAB find selects the first empty cell in column-major order. There is
% no claim of a unique solution and no explicit for/while loop.
original = grid;
valid = false;
if ~BinairoGridValid(grid)
    return
end
n = size(grid, 1);
[direct, ok] = DirectValues(grid, n);
if ~ok
    return
end
first = find(isnan(direct), 1, 'first');
if isempty(first)
    grid = direct;
    valid = true; % DirectValues validates the complete grid before returning.
    return
end
[r, c] = ind2sub([n n], first);
if CheckValidMove(direct, r, c, 0, n)
    trial = direct;
    trial(r, c) = 0;
    [candidate, valid] = SolveBinairo(trial);
    if valid
        grid = candidate;
        return
    end
end
if CheckValidMove(direct, r, c, 1, n)
    trial = direct; % Restore the branch base; discard every failed deduction.
    trial(r, c) = 1;
    [candidate, valid] = SolveBinairo(trial);
    if valid
        grid = candidate;
        return
    end
end
grid = original;
valid = false;
end
