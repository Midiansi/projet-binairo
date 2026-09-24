% SolveBinairo  solve a Binairo/Binoxxo/BinarySudoku/Takuzu/etc.
%
%   [SOLUTION, SOLVED] = SolveBinairo(PUZZLE) solve a Binairo PUZZLE reccursively
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
%     PUZZLE  n x n Grid of floats (n MUST be even), NaN defines empty case
%
%   Output
%     SOLUTION  grid solved or last partialy solved grid
%     SOLVED    true is a full and valid solution is found
%
%   v. 8.9.2026/ca
%

%% ------------------------------------------------------------------------------------------------------
function [grid, valid] = SolveBinairo(grid)
% Projet Binairo - ME-213
% Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
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

function [grid, ok] = DirectValues(grid, n)
% Projet Binairo - ME-213
% Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
% Appliquer les deductions certaines jusqu'a stabilisation ou contradiction.
% 1) Direct solution:
%   Do until no grid change or error
%     find next empty cell
%     check if empty cells can get '0' and/or '1'
%     if both possible -> ignore and next cell
%     if none possible -> error -> exit and backtrack
%     if '0' or '1' *exclusively* possible -> set and next cell
%   repeat
%
% Uses
%    CheckValidMove()
ok = isa(n, 'double') && numel(n) == 1 && ...
    GrilleBinairoValide(grid) && n == size(grid, 1);
if ~ok
    return
end
indicesVides = find(isnan(grid));
[grid, ok, modifiee] = ParcourirCases(grid, n, indicesVides, 1, numel(indicesVides));
if ok && modifiee
    [grid, ok] = DirectValues(grid, n);
end
end

function [grille, ok, modifiee] = ParcourirCases(grille, n, indicesVides, debut, fin)
% Sans boucle : diviser en deux limite la profondeur de ce parcours recursif.
ok = true;
modifiee = false;
if debut > fin
    return
end
% Parcourir les deux moities dans l'ordre, en transmettant les deductions deja faites.
if debut < fin
    milieu = floor((debut + fin) / 2);
    [grille, ok, gaucheModifiee] = ParcourirCases(grille, n, indicesVides, debut, milieu);
    modifiee = gaucheModifiee;
    if ~ok
        return
    end
    [grille, ok, droiteModifiee] = ParcourirCases(grille, n, indicesVides, milieu + 1, fin);
    modifiee = modifiee || droiteModifiee;
    return
end
[r, c] = ind2sub([n n], indicesVides(debut));
zeroPossible = CheckValidMove(grille, r, c, 0, n);
unPossible = CheckValidMove(grille, r, c, 1, n);
if ~zeroPossible && ~unPossible
    ok = false;
    return
end
if zeroPossible ~= unPossible
    grille(r, c) = 1 * unPossible;
    modifiee = true;
end
end

function ok = CheckValidMove(grid, r, c, v, n)
% Projet Binairo - ME-213
% Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
% Tester une valeur sans modifier la grille de l'appelant.
  % Set the chosen cell to v;
  % Then check is the new grid is valid according to Binairo rules
  %      check row ok, col ok, unique ok
  % ok = true if valid
  %
  % Uses
  %     CheckVectorOk() for r
  %     CheckVectorOk() for c
  %     CheckVectorUniqueOk()
ok = false;
if ~FormatGrilleValide(grid) || ~isa(n, 'double') || numel(n) ~= 1 || ...
        n ~= size(grid, 1) || ~isa(v, 'double') || numel(v) ~= 1 || ...
        ~(v == 0 || v == 1)
    return
end
if ~isa(r, 'double') || ~isa(c, 'double') || numel(r) ~= 1 || numel(c) ~= 1
    return
end
if ~any(r == 1:n) || ~any(c == 1:n)
    return
end
if ~isnan(grid(r, c)) && grid(r, c) ~= v
    return
end
grid(r, c) = v;
ok = CheckVectorOk(grid(r, :), n) && ...
    CheckVectorOk(grid(:, c), n) && CheckVectorUniqueOk(grid, r, c, n);
end

function ok = CheckVectorOk(vector, n)
% Projet Binairo - ME-213
% Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
% Verifier les comptes et les suites de trois dans une ligne ou une colonne.
  % Check if the current vector (row or col) is valid
  % Test if a row/col has 3 indentical following cells (different than NaN) -> not ok
  % Test if the numbers of a given symbol > n/2 -> not ok
  % ok = true if valid
ok = false;
if ~isa(n, 'double') || numel(n) ~= 1 || n ~= numel(vector) || ...
        ~(n >= 2) || mod(n, 2) ~= 0 || ~isa(vector, 'double')
    return
end
if ~(isequal(size(vector), [1 n]) || isequal(size(vector), [n 1]))
    return
end
% Avec NaN, les comparaisons restent fausses : les cases vides ne forment pas de suite.
v = vector(:).';
ok = ~any(~isnan(v) & v ~= 0 & v ~= 1) && ...
    sum(v == 0) <= n / 2 && sum(v == 1) <= n / 2 && ...
    ~any(v(1:end-2) == v(2:end-1) & v(2:end-1) == v(3:end));
end

function ok = CheckVectorUniqueOk(grid, r, c, n)
% Projet Binairo - ME-213
% Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
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

function printGrid(grid)
% Projet Binairo - ME-213
% Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
% Afficher la matrice dans la fenetre de commande.
     % print the current grid for debugging
disp(grid);
end
