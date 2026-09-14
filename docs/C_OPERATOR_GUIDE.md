# C build and test - literal operator steps

The delivered tested executable is macOS ARM64 only. Windows needs a native build; no Windows execution is claimed. C uses the standard library plus file-only deletion via unlink on POSIX / _unlink on Windows, to preserve accidental output directories. Supplied packed bitmaps stay unchanged in course_materials/FontRasterized_0_1.h. Compiler/runtime source is c/main.c + c/ocr.c; c/test_ocr.c is a development test, not another runtime executable entry point.

## Windows (provisional team target)

1. Obtain the complete project, preserving its folder structure. Restore course_materials if cloning from GitHub. In File Explorer open the project root; Shift-right-click inside it and Copy as path if needed.
2. Install Visual Studio Build Tools with Desktop development with C++, Windows SDK and MSVC C11 support, using an existing institutional/free entitlement. No paid service or API is needed.
3. Start menu: open `x64 Native Tools Command Prompt for VS 2022` (or the installed newer matching version). Do not use the ordinary command prompt for this compile step.
4. Type `cd /d `, paste the quoted project-root path, Enter. Example manual location only: `cd /d "C:\Coursework\epfl-me213-binairo-2026"`. The source code contains no such personal path.
5. Paste `c\build_windows.cmd > state\WINDOWS_C_BUILD.txt 2>&1` then `type state\WINDOWS_C_BUILD.txt`.
6. Expected: no compiler warnings/errors; `C unit tests: 49 checks, 0 failures (margin policy=1)`; `OCR.exe` and test executable in build/. On failure return WINDOWS_C_BUILD.txt without editing error text.
7. With Python 3.10 or later installed, paste `py -3 tests\test_c.py --exe build\OCR.exe --report state\WINDOWS_C_TEST_RESULTS.json > state\WINDOWS_C_TEST_RUN.txt 2>&1` then `type state\WINDOWS_C_TEST_RUN.txt`. Expected 69 PASS, 0 FAIL. If Python is unavailable this affects development tests only; the runtime does not call Python.
8. Paste `py -3 tools\prepare_runtime.py`. Expected runtime/OCR.exe plus the MATLAB files and supplied launcher. Later re-run this after VI construction.
9. For a supplied single-cell check, paste `build\OCR.exe "course_materials\Cell0.bin" 88 90 90` then `echo %ERRORLEVEL%` (expected 0) then `type course_materials\CellValue.txt` (expected digit 0). The precise percentage is in state/C_TEST_RESULTS.json evidence and can vary only if input/algorithm changed. Repeat the automatic runner instead of inventing thresholds.

## macOS/Linux rebuild

1. Open Terminal, type `cd ` and drag the project-root folder from Finder, Enter.
2. Ensure a native C11 compiler and make are available. On macOS, `xcode-select --install` is the manual developer-tools installation if absent.
3. Paste `make -C c test`. Expect 49 checks, 0 failures and build/OCR.
4. Paste `python3 --version`; use Python >=3.10 for the test runner. Then `python3 tests/test_c.py --exe build/OCR`. Expect 69 PASS, 0 FAIL.
5. Optional memory/undefined-behavior checks on a compiler supporting them: `make -C c sanitize`, then `python3 tests/test_c.py --exe build/OCR_sanitize --report state/C_SANITIZER_RESULTS.json`.
6. Paste `python3 tools/prepare_runtime.py`. The copied executable is valid only for its compiled OS/architecture.

## Runtime protocol and errors

All four arguments are mandatory: cell-file path, empty threshold, zero threshold, one threshold. Use dot decimals. The two presets are intentional: 88/90/90 for the supplied bordered cell fixtures; 98/90/90 for the native interior crop pipeline. These are provisional measured development choices, not official threshold constants.

No stdout or stderr is produced on success. Result is beside the input path: `CellValue.txt`. A blank symbol is one ASCII space. Thresholds compare full precision; text prints four decimal places. Malformed/truncated files return 3; actual stream/open/allocation failures return 4; no-match returns5; output failures6; argument errors2. Old results are removed before processing a discoverable nonreserved input path. `CellValue.txt.tmp` is written/closed first, then renamed. Never use CellValue.txt or CellValue.txt.tmp as input basenames. LabVIEW checks process return code AND stderr AND error cluster before reading a result.

## Evidence to return

Return WINDOWS_C_BUILD.txt, WINDOWS_C_TEST_RUN.txt, WINDOWS_C_TEST_RESULTS.json (or corresponding native build/test logs), the exact compiled executable, compiler version, OS/CPU and complete files for any failed case. Save evidence in a dated evidence/ subfolder or return a zip to this task for inspection/commit/push. Do not add supplied course files to GitHub. Read-only/error-permission behavior can differ between OSes and remains a native acceptance test.
