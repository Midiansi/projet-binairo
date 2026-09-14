# Reproducible tests and evidence

## What has actually run
C: 49 unit checks plus 69 CLI acceptance cases, both normal and AddressSanitizer/UndefinedBehaviorSanitizer builds on macOS ARM64. The CLI oracle uses Python integer bitsets, independently of C's per-pixel loops. See state/C_TEST_RESULTS.json and C_SANITIZER_RESULTS.json. Source review found no assessed functionality outsourced to another environment.

The development Pillow experiment in tests/check_png_surrogate.py detects borders and calls C on source images. It verifies exact recognized clue matrices for supplied 6x6,8x8,4x4 and rejects supplied nonsquare6x5. This experiment is NOT LabVIEW: native PNG color reduction, alpha handling, array order and VI wiring remain unexecuted. Native MATLAB has never been run by the agent.

## Run local C tests
Follow C_OPERATOR_GUIDE.md. `python tests/test_c.py --exe build/OCR.exe` on Windows; `python3 tests/test_c.py --exe build/OCR` on macOS/Linux. Use Python>=3.10. Supplied fixtures must be restored into course_materials. The tests create temporary binary cases and delete them; the output JSON retains test names, pass/fail and environment.

Generated cases are AI-designed, not official course tests. They cover: exact template cells, bottom/right translated rectangles, minimum and maximum sizes, small empty/nonempty cells, strict empty equality, inclusive digit equality, tie ordering, margin/raw disagreement, no match, deterministic noise, short header/payload, excess bytes, wrong endian, invalid pixels, bad threshold syntax, every relevant CLI arity, input absence, output-directory failure, and output placement with spaces/apostrophe. Expected policy-specific results come from INTERFACE_CONTRACT.md; raw-score-vs-margin remains provisional.

## Native MATLAB
Use MATLAB_OPERATOR_GUIDE.md without writing your own test code. `run_native_tests` runs individual validation helpers, propagation, recursive solver, source examples, bad cases, independent PDF display and option branches, then saves diagnostics. Actual generated-file names and exact commands are in that guide. Return all outputs regardless of pass/fail; a screenshot alone cannot validate matrix/file content.

## Native LabVIEW acceptance sequence
Use the complete LABVIEW_CONSTRUCTION_GUIDE.md checkpoints. Do these tests in order after construction:

1. On supplied 6x6: preview original image, binary polarity, bounds and run arrays. Expect 6 rows/6cols; first crop72x68, eight-byte header `48 00 00 00 44 00 00 00`, payload4896, file4904 bytes. The first cell is blank. Compare native bitmaps against source visually.
2. Full6x6: compare generated B with the course matrix in MATLAB_OPERATOR_GUIDE; see expected PDF, preserve source black clues and new blue bold digits.
3. Full8x8: image has top/left offsets, so absolute scan10 fails; expected8x8 after detected bounds offset. Compare all clues, not only grid size.
4. Bad4x4: OCR succeeds; MATLAB returns UNSOLVABLE and produces centered red error on original clues. No guessed solution is reported.
5. Binaro_5x6_Bad.png: reject unequal/odd dimensions before OCR; no fresh solve.m/PDF is accepted. Exact filename spelling is Binaro.
6. Four Solve with Matlab / Show PDF combinations: script is generated in every case; semantics in contract. Never read a stale PDF as success.
7. Rename OCR executable with LabVIEW closed, run once, expect displayed launch error, no read of old result. Restore original filename afterward.
8. Copy a plain text file with .png extension, select it, run. Expect PNG decode error. Missing PNG also errors. Do not rename/modify supplied originals.
9. Make the output runtime test-copy folder read-only using OS properties; run and record write failure. On administrator accounts this may not deny writes; record actual behavior, do not label it pass without denial. Restore permissions.
10. Temporarily edit a COPY of solve.m to contain `error('Binairo:Injected','intentional native test')`; use the manual MATLAB launch diagnostic. Expect full exception and ERROR status, no misleading success. Restore by regenerating script. Test a missing MATLAB path via the configured launcher option and capture process + status errors.
11. Parser: test blank,0,1 plus missing LF, decimal comma, unrecognized symbol, >100, garbage suffix, two lines. Malformed results are errors, never NaN defaults.
12. Binary serialization: use asymmetric 40x35 synthetic cell and verify width-first header. The guide includes a manual small-array verification before full grid; avoid square-only tests which cannot detect a transpose.
13. Relocation: copy complete final runtime to a new directory with a space in its name; run6x6 again. No path edits inside source are allowed. Windows command-sensitive characters are rejected according to the documented provisional path policy.

## Native failure evidence packet

Record actual OS, CPU, LabVIEW and MATLAB versions, compiler/version and last git commit. Save main front panel showing inputs/status/error; relevant diagram including object IDs; Context Help for the failing terminal; every error cluster status/code/source; OCR return code/stdout/stderr; Cell.bin and CellValue.txt; generated solve.m; MatlabStatus.txt, MatlabError.txt and MatlabRun.log; PDF if any. Return a zip named with date and test ID. Keep the original input separately with its filename/hash. Native results have no effect on verification status until inspected; failures are expected to lead to repairs, not manual code improvisation.
