function ok = CheckVectorOk(vector, n)
% CHECKVECTOROK Check triples and symbol counts, allowing empty NaN cells.
% Supplied interface: SolveBinairoHeader.m, 8.9.2026.
% AI-assisted team implementation, 2026. Human attribution: project report.
ok = isnumeric(n) && isreal(n) && isscalar(n) && isfinite(n) && ...
    n >= 2 && n == fix(n) && mod(n, 2) == 0 && ...
    isa(vector, 'double') && isreal(vector) && isvector(vector) && ...
    numel(vector) == n;
if ~ok
    return
end
v = vector(:).';
ok = all(isnan(v) | v == 0 | v == 1) && ...
    sum(v == 0) <= n / 2 && sum(v == 1) <= n / 2 && ...
    ~any(v(1:end-2) == v(2:end-1) & v(2:end-1) == v(3:end));
% NaN never equals NaN, so an unfinished triple is not a violation.
end
