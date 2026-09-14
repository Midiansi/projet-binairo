# C OCR build and behavior

Source is C11; tested platform is macOS arm64 with Apple clang. The supplied
`FontRasterized_0_1.h` must be restored unchanged in `course_materials/` before
building. It defines the actual templates and is included in exactly one source
file. No course bitmap is copied into project source. Windows execution remains
pending until a teammate builds and runs the tests there.

## macOS or Linux

Open a terminal in the project root, then run:

```sh
make -C c test
make -C c sanitize
python3 tests/test_c.py --exe build/OCR
python3 tests/test_c.py --exe build/OCR_sanitize --report state/C_SANITIZER_RESULTS.json
```

The first command produces `build/OCR` and runs the C unit tests. The second
builds AddressSanitizer/UndefinedBehaviorSanitizer variants; it requires compiler
sanitizer support. A local binary is specific to its operating system and CPU.
Use `python3 tools/prepare_runtime.py` from the project root to assemble runtime
files after the build. For a manual call, quote a real cell path:

```sh
./build/OCR "course_materials/Cell0.bin" 88 90 90
```

The result is `course_materials/CellValue.txt`, because output always goes beside
the input. The supplied historical fixtures use thresholds 88/90/90; native
LabVIEW border-free crops use the provisional 98/90/90 preset.

## Windows, without using the Mac binary

1. Install Visual Studio Build Tools with **Desktop development with C++**,
   including a modern MSVC toolset with `/std:c11` support (VS 2019 16.8 or later).
2. Open **x64 Native Tools Command Prompt for VS** from the Windows Start menu.
3. Type `cd /d "C:\your\project\binairo"`, replacing only the project path.
4. Type `c\build_windows.cmd`. Expected last lines include
   `C unit tests: 49 checks, 0 failures (margin policy=1)` and a success message.
   Save the entire output if any error appears. This creates `build\OCR.exe`.
5. With Python 3 installed, run
   `py -3 tests\test_c.py --exe build\OCR.exe` from that same project root.
6. Assemble runtime using `py -3 tools\prepare_runtime.py` as directed by the
   operator guide, then use the Windows executable in native LabVIEW testing.

These are source-reviewed build instructions, not evidence of a Windows build.
Use an ordinary local project path for the first native validation; treatment of
non-ASCII filenames depends on the Windows command-line/runtime encoding.

## Input, errors and cleanup

The authoritative byte/text rules and policy decisions are in
`docs/INTERFACE_CONTRACT.md`. In particular, there are four user arguments, all
thresholds are required, and the CLI uses ordinary signed base-10 decimals without
whitespace or exponent notation. Success is silent. Errors appear on stderr and
return 2 (arguments/path), 3 (binary dimensions/format), 4 (input I/O/allocation),
5 (unrecognized), or 6 (output I/O). A premature EOF is a malformed file (3); an
actual stream read error is an I/O failure (4).

Once the input path identifies its directory, the old `CellValue.txt` and
`CellValue.txt.tmp` are removed before argument/file validation. Basenames equal
to either reserved output name, ignoring ASCII case, are rejected as input to
avoid deleting the input itself. Cleanup preserves directories: it uses POSIX
`unlink` or the corresponding MSVC `_unlink`; all other work uses C11 facilities.

The result is written in binary mode to `CellValue.txt.tmp`, flushed and closed,
then renamed to `CellValue.txt`. A failed write never publishes a partial result.
A failed temporary cleanup can leave a `.tmp` file; the next run tries to remove
it and fails clearly if that is impossible. A machine crash can also leave this
temporary file. Only consume the result after exit 0 and empty stderr. Never run
two OCR processes against the same directory simultaneously.

`ocr_policy.h` isolates dimension bounds and margin/raw-score selection. To test
the documented alternative policy on macOS/Linux without changing source:

```sh
cc -std=c11 -Wall -Wextra -Wpedantic -Werror -Wvla -DOCR_SELECT_BY_MARGIN=0 -Icourse_materials c/test_ocr.c c/ocr.c -o build/test_ocr_raw
./build/test_ocr_raw
```

The root CLI oracle deliberately checks the selected default margin policy.
