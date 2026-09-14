function results = run_native_tests(testViewer)
% RUN_NATIVE_TESTS Native MATLAB acceptance runner, not assessed runtime work.
% Run from project root: addpath(fullfile(pwd,'tests','native')); results=run_native_tests(true);
% AI-assisted test design, 2026. This file has NOT been executed by Codex.
% true tests both automatic browser-opening branches. Visual PDF review is
% still manual; browser launch success does not prove its displayed content.
if nargin == 0
    testViewer = true;
end
assert(islogical(testViewer) && isscalar(testViewer), 'Use true or false.');
runnerDir = fileparts(mfilename('fullpath'));
if exist(fullfile(fileparts(runnerDir), 'docs', 'INTERFACE_CONTRACT.md'), 'file') == 2
    projectRoot = fileparts(runnerDir); % Also works in prepared runtime/.
else
    projectRoot = fileparts(fileparts(runnerDir)); % tests/native/.
end
assert(exist(fullfile(projectRoot, 'matlab', 'SolveBinairo.m'), 'file') == 2, ...
    'Cannot locate project matlab/ directory. Restore the whole project.');
stamp = char(datetime('now'), 'yyyyMMdd_HHmmss_SSS');
evidenceDir = fullfile(projectRoot, 'evidence', ['matlab_native_' stamp]);
testRuntime = fullfile(evidenceDir, 'runtime');
mkdir(testRuntime);
copyfile(fullfile(projectRoot, 'matlab', '*.m'), testRuntime);
copyfile([mfilename('fullpath') '.m'], fullfile(evidenceDir, 'run_native_tests.m'));
oldPath = path;
oldFolder = pwd;
restoreEnvironment = onCleanup(@() RestoreEnvironment(oldPath, oldFolder)); %#ok<NASGU>
addpath(testRuntime, '-begin');
cd(testRuntime);
% Store the exact functions tested; native evidence remains tied to this copy.
info = sprintf('Native MATLAB acceptance\nStarted: %s\nMATLAB: %s\nPlatform: %s\nViewer requested: %d\nRuntime: %s\n', ...
    char(datetime('now')), version, computer, testViewer, testRuntime);
info = [info evalc('ver') evalc('which SolveBinairo -all')];
WriteLocal(fullfile(evidenceDir, 'environment.txt'), info);
cases = { ...
    '01_shape_and_symbols', @TestInputValidation; ...
    '02_vector_rules', @TestVectorRules; ...
    '03_complete_vector_uniqueness', @TestUniqueness; ...
    '04_candidate_checks', @TestMoves; ...
    '05_direct_fixed_point', @TestDirect; ...
    '06_source_6x6_solution', @TestSix; ...
    '07_source_8x8_solution', @TestEight; ...
    '08_complete_and_unsatisfiable', @TestFinalAndFailure; ...
    '09_exhaustive_2x2_inputs', @TestAllTwo; ...
    '10_backtracking_restores_original', @TestBacktracking; ...
    '11_empty_4x4_first_solution', @TestEmptyFour; ...
    '12_figure_colors_geometry_labels', @TestFigure; ...
    '13_partial_and_error_figures', @TestPartialAndErrorFigure; ...
    '14_display_pdf_and_alias', @TestPDFs; ...
    '15_display_rejects_bad_arguments', @TestDisplayErrors; ...
    '16_run_solve_true_show_false', @() TestRun(evidenceDir, true, false, 'Native_solved'); ...
    '17_run_solve_false_show_false', @() TestRun(evidenceDir, false, false, 'Native_original_only'); ...
    '18_run_unsolvable_status', @() TestRunUnsolvable(evidenceDir); ...
    '19_run_error_and_full_report', @() TestRunError(evidenceDir); ...
    '20_run_stale_output_cleanup', @() TestStale(evidenceDir); ...
    '21_paths_spaces_quotes_and_cwd', @() TestPaths(evidenceDir); ...
    '22_generated_solve_script', @() TestGenerated(projectRoot, evidenceDir) ...
    };
if testViewer
    cases = [cases; { ...
        '23_run_solve_true_show_true', @() TestRun(evidenceDir, true, true, 'Native_view_solved'); ...
        '24_run_solve_false_show_true', @() TestRun(evidenceDir, false, true, 'Native_view_original') }];
end
entries = cellfun(@(name, task) RunCase(name, task, evidenceDir), ...
    cases(:, 1), cases(:, 2), 'UniformOutput', false);
results = [entries{:}];
passed = sum([results.passed]);
failed = numel(results) - passed;
summary = sprintf('NATIVE MATLAB RESULTS: %d PASS, %d FAIL, %d TOTAL\n', passed, failed, numel(results));
lines = arrayfun(@(r) sprintf('%s\t%s\n', StatusWord(r.passed), r.name), results, 'UniformOutput', false);
summary = [summary strjoin(lines, '') sprintf('\nEvidence folder: %s\n', evidenceDir)];
summary = [summary sprintf('Visual PDF review and LabVIEW end-to-end execution are separate pending checks.\n')];
WriteLocal(fullfile(evidenceDir, 'SUMMARY.txt'), summary);
WriteLocal(fullfile(evidenceDir, 'results.json'), jsonencode(results));
save(fullfile(evidenceDir, 'results.mat'), 'results', 'testViewer', 'projectRoot');
WriteLocal(fullfile(projectRoot, 'evidence', 'LATEST_MATLAB_NATIVE.txt'), [evidenceDir char(10)]);
fprintf('\n%s\n', summary);
fprintf('Return the ENTIRE evidence folder, including runtime PDFs and per-test logs.\n');
end

function result = RunCase(name, task, evidenceDir)
result = struct('name', name, 'passed', false, 'seconds', 0, 'report', '');
start = tic;
try
    captured = evalc('task();');
    result.passed = true;
    result.report = captured;
catch exception
    result.report = getReport(exception, 'extended', 'hyperlinks', 'off');
end
result.seconds = toc(start);
WriteLocal(fullfile(evidenceDir, [name '.txt']), ...
    sprintf('%s %s (%.3f seconds)\n%s\n', StatusWord(result.passed), name, result.seconds, result.report));
fprintf('%s %s (%.3f s)\n', StatusWord(result.passed), name, result.seconds);
end

function TestInputValidation()
e = BinairoExamples();
invalid = {[], zeros(1), nan(3), nan(2, 4), e.bad6x5, single(nan(4)), ...
    true(4), complex(ones(4), ones(4)), repmat(Inf, 4), repmat(2, 4), 'abcd', struct()};
cellfun(@RejectInput, invalid);
assert(BinairoShapeOK(nan(2)) && BinairoShapeOK(e.original6));
end

function RejectInput(input)
[output, ok] = SolveBinairo(input);
assert(~ok && isequaln(input, output), 'Invalid input must return unchanged with false.');
end

function TestVectorRules()
assert(CheckVectorOk([0 1], 2));
assert(CheckVectorOk([NaN NaN], 2));
assert(CheckVectorOk([0 0 1 1 0 1], 6));
assert(CheckVectorOk([0 NaN 0 NaN NaN NaN], 6));
assert(~CheckVectorOk([0 0 0 NaN NaN NaN], 6));
assert(~CheckVectorOk([NaN 1 1 1 NaN NaN], 6));
assert(~CheckVectorOk([NaN NaN NaN 1 1 1], 6));
assert(~CheckVectorOk([1 1 0 1 0 1 1 NaN], 8));
assert(~CheckVectorOk([0 0 1 0 1 0 0 NaN], 8));
assert(~CheckVectorOk([NaN 2], 2));
assert(~CheckVectorOk([0 1], 4));
assert(~CheckVectorOk([0 1], Inf));
end

function TestUniqueness()
g = nan(4); g(1, :) = [0 0 1 1]; g(3, :) = [0 0 1 1];
assert(~CheckVectorUniqueOk(g, 1, 1, 4));
assert(~CheckVectorUniqueOk(g.', 1, 1, 4));
g = nan(4); g(1, :) = [0 NaN NaN 1]; g(3, :) = [0 NaN NaN 1];
assert(CheckVectorUniqueOk(g, 1, 1, 4), 'Incomplete similar rows are not duplicates.');
assert(~CheckVectorUniqueOk(g, 0, 1, 4));
end

function TestMoves()
g = nan(6); g(1, 1:2) = 0;
assert(~CheckValidMove(g, 1, 3, 0, 6));
assert(CheckValidMove(g, 1, 3, 1, 6));
assert(~CheckValidMove(g, 1, 1, 1, 6), 'A fixed clue cannot be overwritten.');
assert(~CheckValidMove(g, 1, 3, 2, 6));
assert(~CheckValidMove(g, 7, 3, 1, 6));
assert(~CheckValidMove(g, 1, 3, 1, 4));
assert(~CheckValidMove(g.', 3, 1, 0, 6));
g = nan(4); g(1, :) = [0 0 1 1]; g(3, :) = [0 0 1 NaN];
assert(~CheckValidMove(g, 3, 4, 1, 4), 'Completing a duplicate row must fail.');
end

function TestDirect()
[g, ok] = DirectValues(nan(4), 4);
assert(ok && all(isnan(g(:))), 'Ambiguous cells must remain empty.');
s = [0 0 1 1; 0 1 0 1; 1 0 1 0; 1 1 0 0];
g = s; g(1, 1) = NaN;
[out, ok] = DirectValues(g, 4);
assert(ok && isequal(out, s));
e = BinairoExamples();
[direct, ok] = DirectValues(e.original6, 6);
assert(ok && sum(isnan(direct(:))) < sum(isnan(e.original6(:))));
[again, ok] = DirectValues(direct, 6);
assert(ok && isequaln(again, direct), 'DirectValues did not reach a fixed point.');
empty = find(isnan(direct)); [r, c] = ind2sub([6 6], empty);
assert(all(arrayfun(@(rr, cc) CheckValidMove(direct, rr, cc, 0, 6) && ...
    CheckValidMove(direct, rr, cc, 1, 6), r, c)));
[out, ok] = DirectValues(e.bad4, 4);
assert(~ok && isequaln(out, e.bad4));
end

function TestSix()
e = BinairoExamples(); [s, ok] = SolveBinairo(e.original6);
assert(ok && isequal(s, e.solution6), '6x6 result differs from supplied example.');
AssertSolution(e.original6, s);
printGrid(s);
end

function TestEight()
e = BinairoExamples(); [s, ok] = SolveBinairo(e.original8);
assert(ok); AssertSolution(e.original8, s);
fprintf('8x8 matches supplied PDF solution: %d (other valid solutions are permitted).\n', isequal(s, e.solution8));
printGrid(s);
end

function TestFinalAndFailure()
e = BinairoExamples(); [s, ok] = SolveBinairo(e.solution6);
assert(ok && isequal(s, e.solution6));
[s, ok] = SolveBinairo(e.bad4); assert(~ok && isequaln(s, e.bad4));
g = e.solution6; g(1, 1) = 0;
[s, ok] = SolveBinairo(g); assert(~ok && isequaln(s, g));
g = nan(6); g(1, 1:3) = 1;
[s, ok] = SolveBinairo(g); assert(~ok && isequaln(s, g));
end

function TestAllTwo()
% Independent oracle: only these two fully valid 2x2 solutions exist.
codes = 0:80;
arrayfun(@CheckTwoCode, codes);
fprintf('All 81 possible 0/1/NaN assignments on a 2x2 grid checked.\n');
end

function ok = CheckTwoCode(code)
values = mod(floor(code ./ (3 .^ (0:3))), 3);
values(values == 2) = NaN;
g = reshape(values, 2, 2);
a = [0 1; 1 0]; b = 1 - a;
clues = ~isnan(g);
expected = all(g(clues) == a(clues)) || all(g(clues) == b(clues));
[s, valid] = SolveBinairo(g);
assert(valid == expected, '2x2 exhaustive feasibility mismatch.');
if valid
    AssertSolution(g, s);
else
    assert(isequaln(s, g));
end
ok = true;
end

function TestBacktracking()
e = BinairoExamples(); [direct, ok] = DirectValues(e.original6, 6); assert(ok);
first = find(isnan(direct), 1, 'first');
assert(first == 1, 'Source example expects first remaining cell r1c1.');
trial = direct; trial(first) = 0;
[returned, ok] = SolveBinairo(trial);
assert(~ok && isequaln(returned, trial), 'The source example first guess must fail cleanly.');
[s, ok] = SolveBinairo(e.original6);
assert(ok && isequal(s, e.solution6), 'Solver did not recover from the first failed guess.');
end

function TestEmptyFour()
[s, ok] = SolveBinairo(nan(4)); assert(ok); AssertSolution(nan(4), s);
end

function AssertSolution(original, solved)
% Separate complete-grid oracle. This does not call runtime validity helpers.
n = size(original, 1);
assert(isequal(size(solved), size(original)) && all(solved(:) == 0 | solved(:) == 1));
assert(all(sum(solved, 1) == n / 2) && all(sum(solved, 2) == n / 2));
assert(~any(any(solved(:, 1:end-2) == solved(:, 2:end-1) & solved(:, 2:end-1) == solved(:, 3:end))));
assert(~any(any(solved(1:end-2, :) == solved(2:end-1, :) & solved(2:end-1, :) == solved(3:end, :))));
assert(size(unique(solved, 'rows'), 1) == n && size(unique(solved.', 'rows'), 1) == n);
clues = ~isnan(original); assert(all(solved(clues) == original(clues)));
end

function TestFigure()
e = BinairoExamples();
f = CreateBinairoFigure(e.original6, e.solution6, 'Native_style_6.png', true);
c = onCleanup(@() close(f)); %#ok<NASGU>
original = findall(f, 'Tag', 'OriginalDigit');
filled = findall(f, 'Tag', 'SolvedDigit');
assert(numel(original) == sum(~isnan(e.original6(:))));
assert(numel(filled) == sum(isnan(e.original6(:))));
assert(all(arrayfun(@(h) isequal(get(h, 'Color'), [0 0 0]) && strcmp(get(h, 'FontWeight'), 'bold'), original)));
assert(all(arrayfun(@(h) isequal(get(h, 'Color'), [0 0 1]) && strcmp(get(h, 'FontWeight'), 'bold'), filled)));
assert(numel(findall(f, 'Tag', 'GridLine')) == 14);
assert(isempty(findall(f, 'Tag', 'ErrorMessage')));
name = findall(f, 'Tag', 'SourceFilename'); stamp = findall(f, 'Tag', 'CreationTime');
assert(numel(name) == 1 && numel(stamp) == 1);
assert(~isempty(strfind(char(get(name, 'String')), 'Native_style_6.png'))); %#ok<STREMP>
assert(~isempty(regexp(get(stamp, 'String'), '^\d\d-[A-Za-z]{3}-\d{4} \d\d:\d\d:\d\d$', 'once')));
posName = get(name, 'Position'); posStamp = get(stamp, 'Position');
assert(posName(1) == 0 && posStamp(1) == 6 && posName(2) < 0 && posStamp(2) < 0);
% Save the native figure so visual defects can be inspected without rerunning.
savefig(f, fullfile(fileparts(which('RunBinairo')), 'Native_style_6.fig'));
end

function TestPartialAndErrorFigure()
e = BinairoExamples();
f = CreateBinairoFigure(e.original6, e.original6, 'Native_partial.png', true);
c = onCleanup(@() close(f)); %#ok<NASGU>
assert(isempty(findall(f, 'Tag', 'SolvedDigit')) && isempty(findall(f, 'Tag', 'ErrorMessage')));
f2 = CreateBinairoFigure(e.bad4, e.bad4, 'Native_bad4.png', false);
c2 = onCleanup(@() close(f2)); %#ok<NASGU>
h = findall(f2, 'Tag', 'ErrorMessage');
assert(numel(h) == 1 && strcmp(get(h, 'String'), '== Error =='));
assert(isequal(get(h, 'Color'), [1 0 0]) && strcmp(get(h, 'FontWeight'), 'bold'));
p = get(h, 'Position'); assert(isequal(p(1:2), [2 2]));
assert(numel(findall(f2, 'Tag', 'OriginalDigit')) == 4 && isempty(findall(f2, 'Tag', 'SolvedDigit')));
end

function TestPDFs()
e = BinairoExamples();
DisplayBinairo(e.original6, e.solution6, 'Native_style_6.png', true);
DisplayBinairo(e.original8, e.solution8, 'Native_style_8.png', true);
DisplayBinairo(e.bad4, e.bad4, 'Native_bad4.png', false);
DispBinairo(e.original6, e.original6, 'Native_alias_partial.png', true);
AssertPDF(BinairoOutputPath('Native_style_6.png'));
AssertPDF(BinairoOutputPath('Native_style_8.png'));
AssertPDF(BinairoOutputPath('Native_bad4.png'));
AssertPDF(BinairoOutputPath('Native_alias_partial.png'));
end

function TestDisplayErrors()
e = BinairoExamples();
ExpectError(@() CreateBinairoFigure(e.original6, nan(4), 'X.png', true), 'Binairo:DisplayGrid');
changed = e.solution6; changed(1, 2) = 1;
ExpectError(@() CreateBinairoFigure(e.original6, changed, 'X.png', true), 'Binairo:DisplaySolution');
ExpectError(@() CreateBinairoFigure(e.original6, e.solution6, 'X.png', NaN), 'Binairo:FeasibleFlag');
ExpectError(@() BinairoOutputPath('bad.txt'), 'Binairo:SourceFile');
ExpectError(@() BinairoOutputPath(['bad' char(10) '.png']), 'Binairo:SourceFile');
end

function TestRun(evidenceDir, solveFlag, viewerFlag, name)
e = BinairoExamples();
RunBinairo(e.original6, [name '.png'], solveFlag, viewerFlag);
AssertStatus('OK'); AssertPDF(BinairoOutputPath([name '.png']));
assert(exist(fullfile(fileparts(which('RunBinairo')), 'MatlabError.txt'), 'file') ~= 2);
Snapshot(evidenceDir, name);
end

function TestRunUnsolvable(evidenceDir)
e = BinairoExamples();
RunBinairo(e.bad4, 'Native_unsolvable.png', true, false);
AssertStatus('UNSOLVABLE'); AssertPDF(BinairoOutputPath('Native_unsolvable.png'));
Snapshot(evidenceDir, 'unsolvable');
end

function TestRunError(evidenceDir)
e = BinairoExamples();
ExpectError(@() RunBinairo(e.bad6x5, 'Native_invalid.png', true, false), 'Binairo:InputGrid');
AssertStatus('ERROR');
folder = fileparts(which('RunBinairo'));
report = fileread(fullfile(folder, 'MatlabError.txt'));
assert(~isempty(strfind(report, 'RunBinairo')) && ~isempty(strfind(report, 'even square'))); %#ok<STREMP>
assert(exist(BinairoOutputPath('Native_invalid.png'), 'file') ~= 2);
Snapshot(evidenceDir, 'invalid_shape');
ExpectError(@() RunBinairo(e.original6, 'Native_options.png', 1, false), 'Binairo:Options');
AssertStatus('ERROR'); Snapshot(evidenceDir, 'invalid_options');
end

function TestStale(evidenceDir)
e = BinairoExamples(); folder = fileparts(which('RunBinairo'));
WriteLocal(fullfile(folder, 'MatlabStatus.txt'), ['STALE' char(10)]);
WriteLocal(fullfile(folder, 'MatlabError.txt'), 'old failure');
WriteLocal(BinairoOutputPath('Native_stale.png'), 'this is not a PDF');
RunBinairo(e.original6, 'Native_stale.png', true, false);
AssertStatus('OK'); AssertPDF(BinairoOutputPath('Native_stale.png'));
assert(exist(fullfile(folder, 'MatlabError.txt'), 'file') ~= 2);
Snapshot(evidenceDir, 'stale_replaced');
% A new invalid run must remove the previous PDF rather than leave success.
ExpectError(@() RunBinairo(e.bad6x5, 'Native_stale.png', true, false), 'Binairo:InputGrid');
AssertStatus('ERROR'); assert(exist(BinairoOutputPath('Native_stale.png'), 'file') ~= 2);
Snapshot(evidenceDir, 'stale_removed_on_error');
end

function TestPaths(evidenceDir)
e = BinairoExamples(); oldFolder = pwd;
other = fullfile(evidenceDir, 'unrelated working folder'); mkdir(other);
c = onCleanup(@() cd(oldFolder)); %#ok<NASGU>
cd(other);
source = fullfile(other, 'source folder with space''s', 'Native quote''s input.png');
RunBinairo(e.original6, source, true, false);
AssertStatus('OK'); AssertPDF(BinairoOutputPath(source));
assert(exist(fullfile(other, 'MatlabStatus.txt'), 'file') ~= 2);
Snapshot(evidenceDir, 'spaces_quotes_other_cwd');
end

function TestGenerated(projectRoot, evidenceDir)
e = BinairoExamples(); folder = fileparts(which('RunBinairo'));
source = fullfile(folder, 'Native generated @SOLVE@ quote''s.png');
template = fileread(fullfile(projectRoot, 'resources', 'solve_template.txt'));
matrix = mat2str(e.original6);
matrix = matrix(2:end-1); % Template already has outer [ ].
script = strrep(template, '@MATRIX@', matrix);
script = strrep(script, '@SOLVE@', '1');
script = strrep(script, '@SHOW@', '0');
% Source LAST: a filename containing marker-looking text must stay literal.
script = strrep(script, '@SOURCE@', strrep(source, '''', ''''''));
file = fullfile(folder, 'solve.m');
WriteLocal(file, script);
ExecuteGenerated(file);
AssertStatus('OK'); AssertPDF(BinairoOutputPath(source));
Snapshot(evidenceDir, 'generated_script');
end

function ExecuteGenerated(file)
run(file); % Isolated workspace: generated clear B cannot affect the runner.
end

function AssertPDF(file)
fid = fopen(file, 'rb'); assert(fid >= 0, 'Missing PDF file.');
c = onCleanup(@() fclose(fid)); %#ok<NASGU>
signature = char(fread(fid, 5, '*uint8').');
assert(strcmp(signature, '%PDF-'), 'File has no PDF signature.');
info = dir(file); assert(info.bytes > 100, 'PDF unexpectedly small.');
end

function AssertStatus(expected)
folder = fileparts(which('RunBinairo'));
fid = fopen(fullfile(folder, 'MatlabStatus.txt'), 'rb'); assert(fid >= 0);
c = onCleanup(@() fclose(fid)); %#ok<NASGU>
bytes = fread(fid, Inf, '*uint8').';
assert(isequal(bytes, uint8([expected char(10)])), 'Status bytes/line ending mismatch.');
end

function Snapshot(evidenceDir, label)
folder = fileparts(which('RunBinairo'));
destination = fullfile(evidenceDir, 'scenarios', label); mkdir(destination);
items = {'MatlabStatus.txt', 'MatlabError.txt', 'MatlabRun.log'};
cellfun(@(name) CopyIfPresent(fullfile(folder, name), destination), items);
end

function CopyIfPresent(file, destination)
if exist(file, 'file') == 2
    copyfile(file, destination);
end
end

function ExpectError(task, expectedID)
caught = false;
try
    task();
catch exception
    caught = true;
    assert(strcmp(exception.identifier, expectedID), ...
        'Unexpected error identifier: %s; expected %s.\n%s', exception.identifier, expectedID, ...
        getReport(exception, 'extended', 'hyperlinks', 'off'));
end
assert(caught, 'Expected an error, but the function returned normally.');
end

function word = StatusWord(ok)
if ok
    word = 'PASS';
else
    word = 'FAIL';
end
end

function WriteLocal(file, content)
% Test-only writer independent of the runtime's atomic text writer.
fid = fopen(file, 'wb'); assert(fid >= 0, 'Cannot write native evidence.');
c = onCleanup(@() fclose(fid)); %#ok<NASGU>
bytes = unicode2native(content, 'UTF-8');
assert(fwrite(fid, bytes, 'uint8') == numel(bytes));
end

function RestoreEnvironment(oldPath, oldFolder)
diary('off');
cd(oldFolder);
path(oldPath);
end
