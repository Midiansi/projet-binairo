# MATLAB operator guide - no code design required

Status: all supplied MATLAB functions and this test runner have been written and source-reviewed; NONE has been executed in MATLAB or Octave by the agent. Tests below must be run by a teammate. Windows with English MATLAB is provisional; exact installed release must be recorded. Use licensed MATLAB already available to the group. No toolboxes or paid API are intended.

## 1. Files and location

Obtain the complete binairo folder. Keep matlab/, tests/native/, resources/, docs/, evidence/, tools/ and course_materials/ in their delivered relative locations. In particular, do not copy only SolveBinairo.m: it calls the other functions. In the group runtime, all .m files, BinairoSolver.vi, subVIs, MP_LaunchMatlabScript4.vi, OCR.exe/OCR and generated disk files are placed together by `python tools/prepare_runtime.py`. Python only assembles development files; it does not perform runtime solving or image processing.

## 2. Start MATLAB and select the project root

1. Open MATLAB manually from the Start menu/application launcher. Wait until the Command Window prompt `>>` appears.
2. In MATLAB's Current Folder address bar, click the folder chooser and select the delivered **binairo project root**, the folder containing matlab/, docs/ and tests/. Do not select matlab/ itself.
3. Click the Command Window. Paste the following command and press Enter:

```matlab
pwd
```

The displayed folder must be your project root. Paste these commands in order:

```matlab
assert(isfolder('matlab') && isfolder(fullfile('tests','native')), 'Select the binairo project ROOT folder first.');
addpath(fullfile(pwd,'tests','native'));
version
computer
```

No command contains a personal path. If the assertion fails, select the correct root and repeat it.

## 3. Automatic native tests

Paste this whole block once:

```matlab
try
    results = run_native_tests(true);
catch ME
    report = getReport(ME,'extended','hyperlinks','off');
    disp(report);
    fid = fopen(fullfile(pwd,'MATLAB_STARTUP_FAILURE.txt'),'w');
    if fid >= 0, fprintf(fid,'%s\n',report); fclose(fid); end
end
```

The runner deliberately triggers some invalid-input errors to check recovery. A captured expected error is a PASS; the final summary is the criterion. It may open up to two PDF browser windows. Let it finish; do not close MATLAB mid-run. Expected successful summary: **NATIVE MATLAB RESULTS: 24 PASS, 0 FAIL, 24 TOTAL**. This is an expectation, not a claim it already occurred. If the browser/PDF viewer is unavailable, the last two cases can fail even if PDF generation works; return their errors without changing code or suppressing failures. The agent decides the repair. Running `run_native_tests(false)` is a separate 22-case diagnostic only, not a substitute for the two viewer cases.

Each test saves its own output/error report. The runner creates `evidence/matlab_native_<actual timestamp>/` containing:

- environment.txt: actual release, platform, installed products and function resolution;
- SUMMARY.txt, results.json and results.mat;
- numbered per-test .txt logs, including full error details when a test fails;
- runtime/: the exact tested .m copies and produced PDFs/FIG/solve.m/status files;
- scenarios/: copies of status/error/diary files for individual pipeline scenarios.

`evidence/LATEST_MATLAB_NATIVE.txt` contains the exact latest evidence-folder path. No agent-created placeholder result is labelled native.

## 4. Open and visually check the PDFs

1. In File Explorer/Finder, open the folder named inside evidence/LATEST_MATLAB_NATIVE.txt, then runtime/.
2. Double-click Native_style_6.pdf. Check six rows/columns, all interior/exterior grid lines, no missing/clipped numbers, original clues black bold and new digits blue bold. The source basename is upper left; current timestamp upper right. White page, readable centered digits.
3. Open Native_style_8.pdf and check the same styling for eight rows/columns.
4. Open Native_bad4.pdf. Expect four original black zero clues and large **red `== Error ==`** centered on the grid. There must be no invented solution digits.
5. Open Native_alias_partial.pdf and Native_original_only.pdf. Expect only original clues, no new blue digits, and no error for the incomplete original when solving was disabled.
6. Open Native_solved.pdf, Native_view_solved.pdf and Native_view_original.pdf. Their content must match the options named in the filename. Viewer cases should have opened the relevant PDFs automatically.
7. Capture one full-page screenshot each of6x6,8x8,error and original-only results; include the entire header and grid, not only a crop. Keep the real PDF files too. A screenshot is not a replacement for the PDFs.

## 5. Source examples and manual reference driver

The runner already tests helpers separately and the full solver. After it finishes, select the project root again. For the manual reference, paste:

```matlab
addpath(fullfile(pwd,'matlab'));
e = BinairoExamples();
[S, valid] = SolveBinairo(e.original6);
disp(valid); disp(S);
```

Expect logical1 and:

```text
1 0 0 1 1 0
0 1 0 1 0 1
1 0 1 0 1 0
1 1 0 1 0 0
0 0 1 0 1 1
0 1 1 0 0 1
```

Then paste:

```matlab
sample_driver
```

Expected: MATLAB writes matlab/Binairo_6x6.pdf, MatlabStatus.txt with OK, and MatlabRun.log; the PDF viewer is requested. This is only a reference demonstration. **LabVIEW still must generate its own solve.m from actual OCR cell results.** Do not hand-copy this reference matrix into the final VI.

The supplied bad4 matrix must return false and unchanged input; bad6x5 must be rejected. The 8x8 runner verifies all rules and source clues even if multiple valid solutions exist. No uniqueness guarantee is inferred from a first solution.

## 6. Test the actual script generated by LabVIEW later

1. Finish the LabVIEW guide's BuildML section; verify runtime/solve.m exists and comes from current OCR cells.
2. In MATLAB Current Folder choose runtime/ (all .m functions are beside solve.m).
3. Paste:

```matlab
which SolveBinairo -all
which RunBinairo -all
try
    run(fullfile(pwd,'solve.m'));
catch ME
    report = getReport(ME,'extended','hyperlinks','off');
    disp(report);
    fid = fopen('MATLAB_GENERATED_SCRIPT_FAILURE.txt','w');
    if fid >= 0, fprintf(fid,'%s\n',report); fclose(fid); end
end
```

Function resolution should point to this runtime directory, not an old clone. A syntax error before RunBinairo can execute may produce no status file; the catch writes MATLAB_GENERATED_SCRIPT_FAILURE.txt. In the full LabVIEW pipeline, stale status files are deleted before launch and a missing fresh status is an error.

## 7. Save Command Window output and return evidence

Automatic logs are primary. If something fails before the runner creates them, use the printed full report saved as MATLAB_STARTUP_FAILURE.txt. Also click in the Command Window, select all visible output (Ctrl+A within the Command Window, Ctrl+C), paste into a plain text file named COMMAND_WINDOW.txt. Do not replace the full error with only its last line. If copying the pane is difficult, the saved getReport output is already sufficient for error text; add a screenshot with the complete error and selected folder.

Zip and return the **entire latest evidence folder**, plus COMMAND_WINDOW.txt/startup failure files if present, the four PDF screenshots, the actual MATLAB release/OS, and current git commit. For actual LabVIEW-generated testing also include runtime/solve.m, Cell.bin, CellValue.txt, MatlabStatus.txt, MatlabError.txt (if created), MatlabRun.log and the generated PDF. Do not email a guessed PASS. The agent will analyze, repair, commit and push returned project evidence. Until pushed or returned for a verified push, new teammate-only files are not backed up on GitHub.
