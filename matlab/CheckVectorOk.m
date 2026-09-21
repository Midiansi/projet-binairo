function ok = CheckVectorOk(vector, n)
  % Check if the current vector (row or col) is valid
  % Test if a row/col has 3 indentical following cells (different than NaN) -> not ok
  % Test if the numbers of a given symbol > n/2 -> not ok
  % ok = true if valid
ok = false;
if ~isa(n, 'double') || numel(n) ~= 1 || imag(n) ~= 0 || ...
        ~(n >= 2) || mod(n, 2) ~= 0 || ~isa(vector, 'double')
    return
end
if numel(vector) ~= n || ...
        ~(isequal(size(vector), [1 n]) || isequal(size(vector), [n 1]))
    return
end
v = vector(:).';
ok = ~any(imag(v) ~= 0) && ~any(~isnan(v) & v ~= 0 & v ~= 1) && ...
    sum(v == 0) <= n / 2 && sum(v == 1) <= n / 2 && ...
    ~any(v(1:end-2) == v(2:end-1) & v(2:end-1) == v(3:end));
end
