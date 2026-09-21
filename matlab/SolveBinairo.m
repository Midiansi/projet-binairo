% SolveBinaro  solve a Binairo/Binoxxo/BinarySudoku/Takuzu/etc.
%
%   [SOLUTION, SOLVED] = SolveBinaro(PUZZLE) solve a Binairo PUZZLE reccursively
%    by 1) checking all constrains and when not sufficient
%       2) make guess [0,1] in the first empty cell and
%           continue while valid until solution is found
%           or backtrack to previous state
%
%   Rules
%     1. each cell is '0' or '1'.
%     2. never 3x '0' nor 3x '1' consecutive (rows or col)
%     3. each row/col contains the same numner of '0', '1'
%     4. each row/col are unique

%   Input
%     PUZZLE  n x n Grid of floats (n MUST be odd), NaN defines empty case
%
%   Output
%     SOLUTION  grid solved or last partialy solved grid
%     SOLVED    true is a full and valid solution is found
%
%   v. 8.9.2026/ca
%
%   Renommer ce fichier!
%

%% ------------------------------------------------------------------------------------------------------
function [grid, valid] = SolveBinairo(grid)
% Projet Binairo - ME-213
% Auteurs : Louis Pédelaborde, Romeo Mugnier de Almeida, Raphael Raphaël Pical
% Resoudre par deductions puis par essais recursifs de 0 et de 1.
  % this function can call itself recursively
  %
  % 1) Try all possible direct solutions (no guess) until it converges to a stable solution or error
  % 2) If error backtrack (= back on call in the recursion) if top call the Binairo has an error
  % 3) If no error and the grid is completed -> done
  % 4) If no error (and not completed)
  %    select next empty cell and "Guess" its value by setting it to '0'
  % Check if the guess is possible
  % if yes
  % duplicate the current grid
  % solve the new Binairo (recursive call)
  % if no (i.e. '0' returns an error,
  % set the cell to '1'
  % duplicate the current grid
  % solve the new Binairo (recursive call)
  %
  % Uses
  %    DirectValues()
% La taille est paire selon les regles ; "odd" dans le commentaire fourni est une coquille.
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
% Conserver la grille avant les essais pour abandonner completement une branche en echec.
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
