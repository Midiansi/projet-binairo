# Binairo project audit — 16 November 2026

Branch `audit/2026-11-16-conformite`, based on `main` at `4540e28`. Nothing was merged or pushed.

Sources used: project statement `P00.PPI_Projet.2026.4.pdf` (rev. 4, 30.10.2026), submission addendum `P00.PPI_Projet_soumission.26.3.pdf` (rev. 3, 30.10.2026), syllabus `000.PPI_Syllabus.26.r3.pdf`, the six Binairo exercise sheets, `ExempleDocumentationProjet.2026.pdf`, `SolveBinairoHeader.m`, all 2026 C/MATLAB/LabVIEW slides and demo archives, the ICC (CS-119a) C lectures 1–14 and code examples, and the 37 EdStem threads.

What "verified" means here: the C was compiled and run on macOS 27.2 (Apple clang 21, arm64). **No MATLAB, LabVIEW, Visual Studio or Windows was available**, so nothing in this report is a Windows or MATLAB execution result. The MATLAB solver logic was checked through a line-by-line Python transliteration, which is evidence about the algorithm and not about the `.m` files running.

---

## A. Executive verdict

**Was the original on track for 6/6?** The C and MATLAB code was already correct against every testable requirement I could reconstruct. I found no functional bug and no confirmed hors-programme technique. The gaps were around the code: the build and submission procedure would have produced an archive missing a required item and laid out against the course's "everything in one folder" rule.

**Most important problems found**

1. The recipe compiled the C from the command line only, so the archive would have contained no project files, which the addendum requires.
2. The recipe's submission layout nested `BinairoSolver.vi` under `temp/Execution` and duplicated the sources in `c/` and `matlab/`.
3. The professor's rectangular test image has thin grey grid lines. The recipe's line count works at LabVIEW's conversion threshold with only a small margin, and this was not known or tested.
4. Two decision rules in the C are free choices that differ from the most likely reference behaviour in corner cases (see D-9, D-10). They are allowed if documented.

**Fixed in this audit:** the C empty-cell percentage now matches the Moodle reference to the last digit; a legacy `print` option was removed from MATLAB; the recipe gained a Visual Studio project procedure, a flat submission layout, a measured account of the black/white conversion with a fallback, removal of a dead front-panel control, and current document references. A 49-case Windows test runner, a MATLAB test script and a documentation draft were added.

**Is the corrected project technically on track?** For C and MATLAB, yes, as far as can be established without the VM. The project grade depends mostly on things that do not exist yet: the LabVIEW VIs, the run on the VM, the documentation and the AI transcripts.

**Confidence.** High for C correctness (executed, sanitizer-clean, 400+ runs). Moderate-to-high for MATLAB logic (transliteration matches the professor's two published solutions and a brute-force solver on 700 random grids; the `.m` files themselves were not run). Unknown for LabVIEW: the recipe is internally consistent and its numeric checkpoints match my independent measurements, but no recipe is proof of a working VI.

---

## B. Requirements compliance matrix

Status codes: **V** verified satisfied · **I** satisfied by inspection, not runtime-tested · **P** partially satisfied · **PEND** pending implementation · **U** unverifiable with current resources.

Sources: *St* = statement 2026.4 slide; *Ad* = addendum 26.3 slide; *OCR/ML1/ML2/LV1/LV2* = exercise sheets; *Ed #n* = EdStem thread.

### C — OCR

| Requirement | Source | Implementation | Status | Evidence | Action |
|---|---|---|---|---|---|
| Read `Cell.bin`: height (uint32 LE), width, then H×W bytes | St 15–16, 22; Ed #29, #30 | `LireCellule`, `reconnaissance.c:133` | V | 8 Moodle cells + `asym.bin` (55×60) | — |
| Little-endian only | Ed #20 | `LireEntier32PetitBoutiste` | V | `bigendian.bin` → code 3 | — |
| Pixels stored in a dynamic array, read in one call, no VLA | St 18, 20; Ad 7 | `malloc` + one `fread` | V | `-Wvla` clean, ASan clean | — |
| Width/height outside [50..1000] is an error | Ad 9 | `parametres_ocr.h`, `LireCellule` | V | 49, 1001, 0, 4294967196 → code 3; 50, 1000 accepted | — |
| Not enough pixels is an error | Ad 9 | `LireCellule` | V | `BadCell_1.bin`, `trunc1.bin` → code 3 | — |
| Cannot read input is an error | Ad 9 | `LireCellule` | V | missing file → code 4 | — |
| Cannot write `CellValue.txt` is an error | Ad 9 | `main.c:177–191` | V | read-only file and directory → code 6 | — |
| Wrong number of arguments is an error | Ad 9 | `main.c:141` | V | 0, 1, 3, 5 arguments → code 2 | — |
| Threshold outside [1..99] is an error | Ad 9 | `ConvertirSeuil` | V | 0, 100, −5, 88.5, abc → code 2; 1, 99 accepted | — |
| Argument order: path, empty, 0, 1; thresholds are integers | Ad 10; Ed #19 | `main.c:158` | V | runs above | — |
| Path given between apostrophes | St 23 | `main.c:148–153` | V | `'Cell0.bin'` and `"Cell0.bin"` both work | — |
| Count identical pixels, black and white, 32×32 template slid 1 px at a time | St 8–10; Ed #7, #16 | `ReconnaitreCellule` | V | reference percentages reproduced exactly | — |
| Digit kept when score ≥ threshold | St 18 | `ChoisirChiffre` | V | — | — |
| Test digits first, then empty | Ad 10; Ed #28, #30 | `ReconnaitreCellule` | V | `Cell1_rect.bin` (94.9 % white) → `1` | — |
| Empty = white ratio above empty threshold; output `-1` with white ratio | St 10; Ed #16 | `reconnaissance.c:302–311` | V | `CellEmpty.bin` → `d:'-1', 88.166542%` | — |
| Equal percentages for 0 and 1 is an error reported to LabVIEW | Ed #7 | code 7 | I | not reachable with real cells | — |
| `CellValue.txt` format `d:'digit', percent%` + newline | St 17; Ad 7 | `EcrireResultat` | V | byte dump | — |
| Digit not centred but entirely inside the cell | Ed #14 | full sweep of offsets | V | digits in all four corners | — |
| At least one function | OCR; Ad 7 | 11 functions besides `main` | V | — | — |
| Warnings: behaviour chosen and documented | Ad 9 | codes 3, 5, 7 / margin rule | P | behaviour verified; **documentation not written** | Roadmap 5 |
| Comments, author names in sources | Ad 7; doc template | file and function headers | I | — | — |
| No absolute path in code | Ad 7 | none | V | `grep`, runs from other folders | — |
| Source files **and project files** | Ad 3 | sources only | PEND | no project in repo | Roadmap 2 |
| Executable compiled for Windows | Ad 3 | none yet | PEND | — | Roadmap 2 |
| Path up to 260 characters | Ed #26 | limit 1023 | V | — | — |

### MATLAB

| Requirement | Source | Implementation | Status | Evidence | Action |
|---|---|---|---|---|---|
| `[grid, valid] = SolveBinairo(grid)`, recursive, guesses 0 then 1 | St 29, 34–35; ML2 | `SolveBinairo.m:26` | I | transliteration: both course grids match the professor's PDFs | Roadmap 3 |
| Header functions `DirectValues`, `CheckValidMove`, `CheckVectorOk`, `CheckVectorUniqueOk`, `printGrid` with given signatures | `SolveBinairoHeader.m` | same file, local functions | I | signatures identical | — |
| Rules: no three in a row, n/2 of each, unique rows and columns, n even | St 28; Ed #31 | `CheckVectorOk`, `CheckVectorUniqueOk`, `GrilleBinairoValide` | I | 700 random grids vs brute force, 0 mismatch | Roadmap 3 |
| Infeasible grid reported | St 33 | `valid = false` | I | `Binairo_4x4_Bad` → false | Roadmap 3 |
| `DisplayBinairo(Original, Solution, file, feasible)` saves a PDF | St 33; ML1 | `DisplayBinairo.m`, `CreerFigureBinairo.m` | I | not executed | Roadmap 3 |
| Original digits black bold, solved digits blue bold, all lines drawn | St 33 | `CreerFigureBinairo.m:31–42` | I | matches reference PDF layout by reading | Roadmap 3 |
| Source file name top left, date and time top right | St 33 | lines 43–50 | I | — | Roadmap 3 |
| `== Error ==` centred if not feasible | St 33 | lines 51–55 | I | — | Roadmap 3 |
| PDF named after the PNG (`Binairo_XXX.pdf`) | Ad 8 | `CheminPdfBinairo.m` | I | — | Roadmap 3 |
| Minimal (≈ no) loops | Ad 6 | no `for`/`while` in any file | V | `grep` | — |
| At least one function; comments | Ad 7 | 7 files | V | — | — |

### LabVIEW and integration

| Requirement | Source | Recipe section | Status | Action |
|---|---|---|---|---|
| Main VI named `BinairoSolver.vi`; files `Cell.bin`, `CellValue.txt`, `solve.m` | Ad 8 | §17, §12, §13 | PEND | Roadmap 1 |
| UI: Binairo path, Solve with Matlab, Show pdf, image at the right size, errors shown | St 24–25 | §17.1 | PEND | Roadmap 1 |
| Read PNG, validate size, colour → B&W | St 25; LV1 | §7 | PEND | Roadmap 1, 4 |
| Count rows/columns by transitions ~10 px inside the border; even and equal | St 27; LV1 p. 22 | annex G5 | PEND | Roadmap 1 |
| Cut the cell, write `Cell.bin`, call OCR with parameters, read `CellValue.txt` | St 25; LV1 | §9–§12 | PEND | Roadmap 1 |
| Build matrix string, generate `solve.m`, launch MATLAB | St 26; LV2 | §13, §15, §17 | PEND | Roadmap 1 |
| Error cases: OCR missing, OCR error, no PNG, cannot write `solve.m`, MATLAB missing, script error | St 37; Ad 5 | §12, §15, §17, V06–V17 | PEND | Roadmap 1, 6 |
| Invalid image (`BadBinairo.png`) and renamed executable reported | Ad 6, 11 | V07, V09 | PEND | Roadmap 6 |
| At least one sub-VI; comments; default values saved | Ad 7, 11, 14 | §2.6, §21.1 | PEND | Roadmap 1 |
| No absolute paths; all files in one folder | Ad 7; LV1 p. 10 | §17.2, §21.3 | PEND | Roadmap 7 |
| Runs on the class VM | Ad 11 | §19 | U | Roadmap 6 |

### Submission

| Requirement | Source | Status | Action |
|---|---|---|---|
| `.zip` named with the group members | Ad 2–3 | PEND | Roadmap 7 |
| Short PDF documentation following the template, 5 pages maximum | Ad 3; Ed #35 | PEND (draft added) | Roadmap 5 |
| Generated files for every provided image: `Cell.bin`, `CellValue.txt`, `solve.m`, PDF | Ad 3 | PEND | Roadmap 6 |
| Source images **not** in the archive | Ad 3 | PEND | Roadmap 7 |
| PDF transcripts of every AI conversation about the project | Ad 7; syllabus 42 | PEND | Roadmap 8 |
| Internet sources and collaboration with other groups declared | Ad 7 | PEND | Roadmap 5 |
| Archive re-downloaded and tested elsewhere | Ad 3, 7 | PEND | Roadmap 9 |

---

## C. Curriculum compliance audit

Classification: **T** explicitly taught · **D** clearly derived · **?** uncertain. No element was classified as confirmed hors-programme.

### C

| Technique | Where | Evidence | Class |
|---|---|---|---|
| `goto` to one cleanup label placed after the gotos | `main.c:144–186`, `reconnaissance.c:153–200` | ME-213 C4 slides 20–22: goto allowed "uniquement pour la gestion des erreurs", one explicit label per function, after the gotos | T |
| `enum` for return codes | `reconnaissance.h:12` | ICC lecture 11, "Enumérations" | T |
| `typedef struct`, `->` | `reconnaissance.h` | ICC lectures 8, 11; C6 | T |
| `malloc` / `free` | both files | ICC 7–9; C5; statement slide 18 | T |
| `fopen`, `fread`, `fgetc`, `ferror`, `fclose`, `fprintf(stderr, …)` | both files | C3 slides; statement slide 20 | T |
| `fflush` | `main.c:116` | ICC lecture 12 | T |
| `strlen`, `strcmp`, `memcpy` | `main.c` | ICC lecture 12 and examples | T |
| `uint32_t`, `int32_t`, `size_t` | headers | C3; provided `FontRasterized_0_1.h` | T |
| Bit shifts and masks | `GetDigitBitmapBit`, header decoding | C2; statement slides 13–14 | T |
| `static const` array, `const` parameters | `main.c:19` | C5 | T |
| `argc` / `argv` | `main.c` | ICC lecture 10; statement slide 23 | T |
| `.h`/`.c` split, `#ifndef` guards | all headers | ICC lecture 10 (multi-file, preprocessor directive list) | T / D |
| Ternary `? :` | `reconnaissance.c:150` | ICC lectures 1, 3 | T |
| Pointer to pointer (`const char **description`) | all error paths | ICC lectures 8, 10, 11 | T |
| Manual digit parsing instead of `atoi` | `ConvertirSeuil` | the statement suggests `atoi`; manual parsing uses only loops and characters and rejects `88.5` or `90x` | D |
| `#define _CRT_SECURE_NO_WARNINGS` | top of both `.c` | not found in the course text; a Visual Studio setting, not an algorithmic technique | ? (harmless) |

### MATLAB

| Technique | Where | Evidence | Class |
|---|---|---|---|
| `find`, `ind2sub`, `isnan`, `sum`, `any`, `isequal` | solver | named in `Exo.Proj.Binairo.Matlab.2` | T |
| `text`, `axis`, `datetime`, `num2str`, `meshgrid`, `print` | display | named in `Exo.Proj.Binairo.Matlab.1` | T |
| Logical indexing, matrix products, transpose, `end` | everywhere | M1, M2 | T |
| Recursion | `SolveBinairo`, `DirectValues`, `ParcourirCases` | recursion exercise sheet; statement slide 34 | T |
| `isa`, `numel`, `isempty`, `floor`, `line`, `drawnow`, `error` | validation, drawing | M2 slide (`isa`); `Demo_matlab.zip` files | T |
| `mod`, `max`, `min`, `ones`, `zeros`, cell arrays | various | exercise sheets; M1–M3 | T |
| `figure`/`axes` with property pairs, `'Interpreter','none'` | `CreerFigureBinairo.m` | M2 graphics slides; ML1 says text attributes are set in `text()` and points to `doc` | D |
| `uiopen(file, 1)` | generated `solve.m` | addendum slide 13 | T |
| `print(…, '-painters')` | `DisplayBinairo.m:8` (original) | not in any course file; legacy renderer flag | ? → **removed** |

The removal is safer pedagogically because the remaining call, `print(figure, file, '-dpdf')`, is the form the exercise sheet points to.

One style point is not a compliance issue but a grader may notice it: the scan over empty cells is written as a divide-and-conquer recursion (`ParcourirCases`) purely to avoid a loop, while the professor's own header describes that step as "do until no grid change". It satisfies "utilisation minimale (~ absence) de boucles" literally. I left it unchanged; see D-12.

### LabVIEW recipe

The recipe uses Case and For structures, shift registers, auto-indexed and conditional tunnels, clusters and type definitions, sub-VIs with connector panes, error clusters, text and binary file I/O, `Format Into String` / `Scan From String`, `System Exec`, and the picture functions from the project exercise (`Read PNG File`, `Draw Flattened Pixmap`, `Picture to Pixmap`, `Unflatten Pixmap`, `Index Array`, `Array Subset`). All of these appear in LV1–LV3 or in the two project exercise sheets. The remaining nodes are single palette primitives (comparisons, `Search 1D Array`, `Reverse 1D Array`, `Transpose 2D Array`, `Reshape Array`, `In Range and Coerce`, `Merge Errors`, `File/Directory Info`, `Delete`): class **D**. The recipe uses no property nodes, local variables, event structures, queues, IMAQ, DLL calls, .NET or regular expressions.

I checked the terminal names the recipe relies on for `Read PNG File` (including `Transparency Thresh`), `Picture to Pixmap` and `Unflatten Pixmap` against NI's current reference pages; they match.

---

## D. Technical findings and corrections

### D-1 · Minor · fixed — empty-cell percentage differed from Moodle in the sixth decimal
- **Where:** `c/reconnaissance.c:304` (original).
- **Evidence:** Moodle states `CellEmpty.bin` → `d:'-1', 88.166542%`. The original printed `88.166545%`. 4828 white pixels of 5476 is 88.1665449…; the Moodle value is what single-precision arithmetic gives.
- **Impact:** the addendum tolerates small variations, so this was not a rule violation, but an automatic comparison against the published value would have shown a difference.
- **Correction:** the white ratio is computed in `float`. Digit percentages are multiples of 100/1024 and are unaffected.
- **Verification:** all three Moodle reference lines now match exactly. Old and new binaries compared on 351 runs: 0 changes of symbol or return code, 16 changes limited to the sixth decimal of an empty-cell percentage.

### D-2 · Minor · fixed — `print` used a legacy option
- **Where:** `matlab/DisplayBinairo.m:8`. `-painters` is not in the course and MathWorks replaced it with `-vector` in R2022a.
- **Correction:** `print(figureBinairo, cheminPdf, '-dpdf')`.
- **Verification:** not executed. To check on the VM with `TestBinairo.m`.

### D-3 · Major · recipe fixed — no C project files would have been submitted
- **Evidence:** addendum slide 3 lists "le(s) fichier(s) source(s) c et fichier(s) projet relatif". Recipe §1.1 offered `gcc` or `cl` one-liners and stated that no project file was provided.
- **Correction:** §1.1 now has a six-step Visual Studio procedure (Empty Project in `Execution`, Release x64, `/O2`, `/MT`, sources added by relative path) and says which files to keep. `/MT` removes the dependency on Visual Studio runtime DLLs.
- **Verification:** not executed; Visual Studio is only on the VM.

### D-4 · Major · recipe fixed — submission layout
- **Evidence:** recipe §21.3 built `c/`, `matlab/` and `temp/Execution/` inside the zip, with two copies of every source. LV1 sheet p. 10: "TOUS vos fichiers doivent se trouver dans le même dossier". Addendum slide 4: the grader unzips, opens the LabVIEW file, runs.
- **Correction:** §21.3–21.4 now describe one flat folder with `BinairoSolver.vi` at its root, plus `Resultats/`, `Transcripts_IA/` and optionally `Tests/`.

### D-5 · Major risk · measured, fallback documented — line detection on `Binairo_6x6_rect.v2.png`
- **Evidence:** I located the professor's `Cell0.bin`, `Cell1.bin` and `CellEmpty.bin` inside `Binairo_6x6.png` with zero mismatching pixels when "black" means Rec. 601 luminance below a threshold between 126 and 130. LabVIEW's 1-bit conversion therefore behaves like a threshold near 128. In the rectangular image the inner horizontal lines are one pixel thick with luminance 88–127; the recipe's scan finds seven lines only if the threshold is at least 120.
- **Impact:** it works at the measured threshold, with a margin of about 6 grey levels. If the VM's conversion differs slightly, one line disappears, the VI reports a 5-row grid, and the professor's own test image fails.
- **Correction:** new recipe §7.6 with the exact expected line positions and a three-node fallback (24-bit pixmap, isolate the green channel, compare to 140) to apply only if the check fails.
- **Verification:** simulation only. With the LabVIEW-equivalent threshold, the simulated pipeline plus the real `OCR` recognises all 152 cells of the four valid grids and rejects `Binaro_5x6_Bad.png`; the same holds for the fallback at thresholds 120–140.

### D-6 · Minor · recipe fixed — dead control on the graded front panel
`LanceurFourni` existed only to raise error 7009. §15.3 and §17.1 now say to delete it unless the option is really built.

### D-7 · Minor · recipe fixed — outdated references
The recipe cited statement 2026.2 and addendum 26.1/26.2, an older documentation template, and no page limit. Updated to 2026.4, 26.3, `ExempleDocumentationProjet.2026.pdf` and the 5-page maximum from Ed #35.

### D-8 · Minor · recipe fixed — picture indicator smaller than the largest test image
650×620 against `Binaro_5x6_Bad.png` at 862×676. Now "at least 870×690".

### D-9 · Uncertainty · not changed — which digit wins when both pass their threshold
- **Evidence:** statement slide 10 and the OCR exercise pseudo-code say highest percentage; statement slide 18 says largest `percentage − threshold`. The code follows slide 18. Ed #10 asked exactly this and got no answer. The addendum lists this case under warnings, "à vous de choisir et documenter".
- **Reproduction:** `OCR Cell0.bin 88 90 1` prints `d:'1', 83.789062%` for a cell that is clearly a 0 (0 scores 97.17 with margin 7.17; 1 scores 83.79 with margin 82.79).
- **Impact:** none with equal thresholds, which is the provided default. Visible only if the grader passes very different digit thresholds.
- **Why not changed:** the sources contradict each other and the addendum makes it a free choice. See roadmap item 10.

### D-10 · Uncertainty · not changed — "too many pixels" is fatal
The addendum lists it as a warning with free behaviour; the documentation template's example reads "Trop de pixels → ignoré et continue". The code stops with code 3. Allowed if documented. The draft documentation states it.

### D-11 · Observation — `CellValue.txt` is written next to `Cell.bin`
Not in the working directory. Consistent with the recipe, which passes the full path and reads the result from the same folder. Stated in the documentation draft.

### D-12 · Observation — MATLAB readability
Every helper re-validates its inputs with `isa`/`numel` checks, and a loop is replaced by a recursive split. This is correct and loop-free, but it is the part of the code a reader will find least natural, and each author must be able to explain it. Not changed: it works, and rewriting it would trade one criterion ("absence de boucles") against another ("élégance et lisibilité").

### D-13 · Observation — build type matters for speed
On a 1000×1000 cell: 0.4 s at `-O2`, 7.6 s at `-O0` (Apple M4). A Debug build on the VM will be several times slower again. The executable must be the Release build.

### D-14 · Risk outside the code — the GitHub repository is public
It contains the full C and MATLAB solution and the course's test images. Another group copying it would put both groups in the "travaillé avec un autre groupe sans l'indiquer" situation, and the images are course material. See roadmap item 11.

---

## E. Testing and verification results

Environment: macOS 27.2.1, arm64, Apple clang 21.0.0. Python 3 with NumPy and Pillow for the simulations.

| Test | Expected (derived from the specification) | Result |
|---|---|---|
| Build `-std=c11 -O2 -Wall -Wextra -Wpedantic -Wvla -Wconversion -Wshadow -Wdouble-promotion` | no diagnostics | pass, 0 warnings |
| All runs below under AddressSanitizer + UBSan | no report | pass |
| `Cell0.bin`, `Cell1.bin`, `CellEmpty.bin` at 88 90 90 | Moodle: `d:'0', 97.167969%`, `d:'1', 97.753906%`, `d:'-1', 88.166542%` | pass, identical |
| `Cell0_rect`, `Cell1_rect`, `CellEmpty_rect` | 0, 1, −1 | pass |
| `BadCell_1.bin` (too few), `Bad_Cell0_morepx.bin` (too many) | error / documented choice | code 3, `CellValue.txt` emptied |
| 26 generated cells: sizes 49/50/1000/1001, negative, zero, big-endian, truncated, header only, 3-byte header, empty file, extra byte, pixel value 2, all black, checkerboard, digit in each corner, 50×1000 and 1000×50 | per `temp/Tests/attendu_ocr.txt` | pass |
| Argument count 0, 1, 3, 5; thresholds 0, 100, −5, abc, 88.5, empty, `90x`, `1e1`, `0x5A`, 21 digits; 1, 99, `+90`, `090` | code 2; last four accepted | pass |
| Read-only `CellValue.txt`; directory named `CellValue.txt` | write error | code 6 |
| Path with spaces, relative and absolute; apostrophes and quotes around the path | works; result next to the input | pass |
| Old binary vs new binary, 351 runs | same symbol and return code | pass; 16 sixth-decimal differences on empty cells |
| Simulated LabVIEW pipeline + real `OCR`, 5 images, luminance thresholds 120–140 | matrices of recipe §18; 5×6 rejected | pass, 50 of 50 runs |
| Professor's three cells located in `Binairo_6x6.png` | exact match at some threshold | 0 mismatching pixels for thresholds 126–130 |
| MATLAB logic (Python transliteration): 6×6 and 8×8 | solutions printed in the professor's PDFs | identical |
| Same: `Binairo_4x4_Bad` | no solution | pass; brute force confirms 0 solutions |
| Same: 400 random 4×4 and 300 random 6×6 grids against an independent brute-force enumerator | same solvability; returned grid valid and consistent with the clues | 0 mismatches |

**Not performed:** compilation with Visual Studio; any run on Windows; execution of any `.m` file; PDF generation and its appearance; `uiopen` in batch mode; every LabVIEW step; `TestOCR.bat` and `TestBinairo.m` themselves.

---

## F. Repository modifications

| File | Change | Reason | Checked by |
|---|---|---|---|
| `c/reconnaissance.c` | white ratio in `float`; 4 lines | D-1 | rebuild, 351-run comparison |
| `matlab/DisplayBinairo.m` | `-painters` removed; 1 line | D-2 | not executed |
| `temp/Recette_LabVIEW_Binairo_audit-16-11.md` (+ `.html`, `.pdf`), **new separate files**; the original `Recette_LabVIEW_Binairo.*` is untouched | corrected copy of the recipe, 17 passages marked *(audit 16.11)*: summary block, references, Visual Studio project, expected value, test kit, §7.6, launcher interface and control, picture size, PDF-viewer blocking note, documentation, flat archive | D-3 to D-8 | text comparison old/new: only these passages differ |
| `temp/Changements_audit-16-11.md` (+ `.pdf`), **new separate file**; `Changements_LabVIEW.*` is untouched | two pages for teammates already following the original recipe: what to adjust, by progress | — | — |
| `temp/Audit/Checklist_remise_audit-16-11.md` (new) | remaining actions and the readiness checklist, extracted from this report | — | — |
| `temp/Tests/` (new) | `TestOCR.bat`, `attendu_ocr.txt`, 26 cell files, `TestBinairo.m`, `README.md` | mechanical VM verification | expected values produced by the real binary; scripts not run |
| `temp/docs/Documentation_projet_BROUILLON.md` (new) | documentation skeleton following the 2026 template; C and MATLAB parts filled from the code | documentation must agree with the code (addendum slide 6) | read against the code |
| `temp/Audit/Rapport_audit_2026-11-16.md` (new) | this report | — | — |

**Deliberately left unchanged:** the digit selection rule (D-9), the too-many-pixels policy (D-10), the MATLAB structure (D-12), the recipe's architecture of sub-VIs, and all official course files. The corrected recipe is a separate set of files so that teammates who are mid-way through the original are not disturbed; its HTML and PDF were generated from the Markdown with the original stylesheet and script.

---

## G. LabVIEW recipe verdict

Followed exactly, the corrected recipe describes a system that meets every LabVIEW requirement in section B: named files, the three options, native PNG reading, transition counting 10 px inside the border, even-and-equal check, per-cell `Cell.bin` in the height-then-width format the C expects, the command line in the addendum's argument order, strict parsing of `CellValue.txt`, generation of `solve.m`, a MATLAB launch that waits and checks the return code, and an error path for each of the six situations in the addendum.

What I could confirm independently: the image sizes, the line positions, the first-cell rectangles (72×68 for 6×6 and 8×8), the `Cell.bin` byte counts, the three expected matrices, and the 5×6 rejection all match my own measurements on the PNG files.

What only the built VIs can show:

1. `Binairo_6x6_rect.v2.png` gives n = 6 (§7.6). Do this check first; it decides whether the fallback is needed.
2. Polarity of the 1-bit pixmap (§7.4–7.5).
3. `System Exec` launches `OCR.exe` from a folder with spaces and returns its code and `stderr`.
4. `matlab -wait -sd "…" -batch "run('solve.m')"` is found on the VM's PATH, waits, and returns non-zero on a script error.
5. `uiopen` opens the PDF from batch mode, and the VI does not stay blocked while the viewer is open (§18.3 items 6–7).
6. Decimal separator: the recipe uses `%.;` in its formats, so it should not depend on the OS setting; confirm on the VM.

One caution about effort: the recipe defines 18 VIs and 4 type definitions with nested error cases. It is precise, but it is many hours of careful wiring for beginners. I did not simplify it, because parts may already be built.

---

## H. Final grading outlook

The course gives no numeric rubric. The statement (slide 38) and addendum (slides 4–7) say: a correct one-click run guarantees at least the average; then automatic tests of the C with valid and invalid inputs, then source reading for elegance, exactness and documentation, with assured penalties for absolute paths, missing files, wrong formats, missing references, missing AI transcripts and VLAs. I therefore give no grade breakdown.

**A. Original C and MATLAB.** Functionally complete and within the curriculum. One sixth-decimal deviation from a published value and one legacy option. No penalty item triggered by the code itself.

**B. Corrected C and MATLAB.** C: verified on every requirement except Windows compilation. MATLAB: logic verified indirectly; execution pending.

**C. Projected final project.** If the VIs follow the corrected recipe and pass its validation list on the VM, and the documentation, results and transcripts are in the archive, I know of no remaining technical reason to lose marks. The residual risks are the two free-choice rules (D-9, D-10), the readability of the MATLAB (D-12), and whether each author can explain code that was largely written with AI assistance.

### The sixteen questions

| # | Question | Answer |
|---|---|---|
| 1 | C satisfies every requirement? | Every behavioural one, verified. Project files and a Windows executable are still missing. |
| 2 | MATLAB satisfies every requirement? | By inspection and transliteration, yes. Not executed. |
| 3 | All C techniques in the curriculum? | Yes; each mapped in section C. |
| 4 | All MATLAB techniques in the curriculum? | Yes after removing `-painters`. |
| 5 | Techniques at risk of being judged hors-programme? | None confirmed. `goto` is the one a reader might question; C4 slides 20–22 allow exactly this use. |
| 6 | All confirmed bugs corrected? | No functional bug was found. The two code deviations found were corrected. |
| 7 | Corrected code passes the tests? | C: yes, all. MATLAB: not run. |
| 8 | Recipe implements all required behaviour? | Yes on paper. |
| 9 | Recipe precise enough to follow? | Yes; it names every node, terminal and constant, with a checkpoint per VI. |
| 10 | Proposed LabVIEW within the curriculum? | Yes. |
| 11 | Three components compatible? | Yes on formats, order of dimensions, argument order, file names and locations, exit codes. Simulated end to end for the C side. |
| 12 | Will it work on the VM? | Not demonstrated. Versions, PATH, PDF viewer and conversion threshold are all to be observed there. |
| 13 | Overlooked requirements? | Project files for the C; flat folder; 5-page limit; current template; results for the rectangular image. All now in the recipe. |
| 14 | Ambiguous or misunderstood requirements? | D-9, D-10, and the meaning of "Solve with Matlab" unchecked (Category 4). |
| 15 | What remains beyond LabVIEW, documentation, AI declaration? | Visual Studio project and build, VM test runs, result files, archive assembly and re-download test, repository visibility. |
| 16 | Anything still likely to cost marks? | An untested VM run and missing transcripts are the two that carry assured penalties. |

---

# Roadmap to 6/6

## Category 1 — Completed and verified

| Item | Evidence |
|---|---|
| C reads the 30.10 format and recognises the eight Moodle cells with the published values | executed; byte-identical output lines |
| C reports each of the six addendum errors with a non-zero code and a message on `stderr` | executed, 49-case table |
| C has no VLA, no absolute path, no memory error | `-Wvla`, `grep`, ASan/UBSan |
| C handles rectangular cells and digits anywhere in the cell | executed |
| MATLAB sources contain no loop and keep the professor's function signatures | `grep`; comparison with `SolveBinairoHeader.m` |
| Every C and MATLAB technique maps to ICC or ME-213 material | section C |
| The recipe's numeric checkpoints for the five images are right | independent measurement |

Verified only indirectly (not in this category): MATLAB solver logic.

## Category 2 — Fixed during this audit

| What was wrong | Change | Why it is compliant | How verified |
|---|---|---|---|
| Empty-cell percentage `88.166545` vs Moodle `88.166542` | `float` arithmetic for the white ratio | basic type; same formula | executed |
| `print` with `-painters` | option removed | form given by the exercise sheet | not executed |
| No C project files in the procedure | Visual Studio steps in §1.1 | the course's own IDE | to do on VM |
| Nested archive with duplicated sources | flat layout in §21.3 | LV1 sheet p. 10 | — |
| Unknown behaviour on the rectangular image | measurement, check and fallback in §7.6 | fallback uses `And` and `Less?` on an array | simulation |
| Dead `Lanceur fourni` control | removal instruction | — | — |
| Outdated references, template, page limit, indicator size | updated | — | — |
| No mechanical test procedure for the VM | `temp/Tests` | test tools, outside the graded program | expected values from the real binary |

## Category 3 — Remaining mandatory actions

Ordered by importance for the grade.

**1 · Critical · colleagues (LabVIEW) — build the VIs from the corrected recipe**

- *Action:* keep following the recipe you are already using (`temp/Recette_LabVIEW_Binairo.pdf`, unchanged) and apply the two-page `temp/Changements_audit-16-11.pdf`. Anyone starting fresh uses the corrected copy `temp/Recette_LabVIEW_Binairo_audit-16-11.pdf` instead. Chapter numbers are the same in both.
- *Reason:* the LabVIEW part does not exist; it drives the whole evaluation.
- *Done when:* `BinairoSolver.vi` has an unbroken run arrow and every sub-VI checkpoint in the recipe gives the listed values.
- *Verification:* recipe tests V01–V04 and V26 give the matrices of §18 and the expected PDFs.

**2 · Critical · me (C) — Visual Studio project and Release build on the VM**

- *Action:* recipe §1.1, six steps. Then copy the eight Moodle cells into `temp\Tests\cellules`, copy `OCR.exe` into `temp\Tests`, run `TestOCR.bat`.
- *Reason:* project files and a Windows executable are required; the C has never been compiled with the course compiler.
- *Done when:* build shows 0 errors (and ideally 0 warnings at `/W4`); the script prints `RESULTAT : tous les cas sont identiques a attendu_ocr.txt`; the `z1000.bin` case takes a few seconds.
- *Verification:* keep `resultats_vm.txt`. If a line differs, send me that line.

**3 · Critical · me (MATLAB) — run the MATLAB code on the VM**

- *Action:* copy the seven `.m` files and `temp/Tests/TestBinairo.m` into one folder, type `TestBinairo`.
- *Reason:* no `.m` file has been executed in this audit.
- *Done when:* only `PASS` lines and `Nombre d'echecs : 0`.
- *Verification:* open `Test_6x6.pdf` next to Moodle's `Binairo_6x6.pdf`: same digits, original ones black bold, added ones blue bold, all grid lines, file name top left, date and time top right. `Test_4x4_Bad.pdf` shows the four original zeros and a centred `== Error ==`. Note the two solve times printed.

**4 · Critical · colleagues — rectangular image check, before building further**

- *Action:* as soon as `LireImage.vi` and `ComputeRowsCols.vi` exist, run them on `Binairo_6x6_rect.v2.png`.
- *Reason:* finding D-5.
- *Done when:* n = 6 and `debutY` = 0, 62, 120, 179, 238, 296, 354 (or 355).
- *Verification:* if n ≠ 6, apply the fallback of §7.6 and redo checkpoints 7.5 and G5.6 on all five images.

**5 · Critical · team — write the documentation**

- *Action:* complete `temp/docs/Documentation_projet_BROUILLON.md` (every **À COMPLÉTER**), export to PDF as `Documentation.pdf`, 5 pages at most.
- *Reason:* required deliverable; the C is "comparé avec … votre documentation".
- *Done when:* versions are the ones read on the VM (`winver`, Visual Studio `Help > About`, MATLAB `version`, LabVIEW `Help > About`); the LabVIEW error table lists the behaviour actually observed; "Le projet doit être évalué sur : VM"; the three "vérifié" lines are true.
- *Verification:* each row of the C error table reproduced once with `OCR.exe` on the VM.

**6 · Critical · team — full validation on the VM and result files**

- *Action:* recipe chapter 19, tests V01–V26, with the Release `OCR.exe`. After each of the four valid images (6×6, 6×6 rect v2, 8×8, 4×4 Bad) copy `Cell.bin`, `CellValue.txt`, `solve.m` and the PDF to `Resultats/<image>/` before running the next.
- *Reason:* addendum slides 3–6 and 11.
- *Done when:* V01–V04, V07, V09, V26 pass at minimum: the three solvable grids give a solved PDF, 4×4 gives `== Error ==`, 5×6 and `BadBinairo.png` give a visible LabVIEW error and no MATLAB launch, a renamed `OCR.exe` gives a visible error and no result reused.
- *Verification:* `Preuves/validation.txt` with date, versions and PASS/FAIL per test.

**7 · Critical · team — assemble the archive**

- *Action:* recipe §21.3: one flat folder `Pedelaborde_MugnierDeAlmeida_Pical` with VIs, `.ctl`, `.lvproj`, seven `.m`, five C files, `OCR.exe`, `OCR/OCR.sln` + `.vcxproj` + `.filters`, `Documentation.pdf`, `Resultats/`, `Transcripts_IA/`. No PNG, no `.git`, no `.vs`, no `x64`, no recipe.
- *Done when:* the file list matches §21.3 and the zip carries the three names.
- *Verification:* item 9.

**8 · Critical · team — AI transcripts as PDF**

- *Action:* export every AI conversation used for this project to PDF: the Codex and Claude sessions that produced the C, the MATLAB and the recipe, and this audit session.
- *Reason:* addendum slide 7, assured penalty otherwise.
- *Done when:* `Transcripts_IA/` holds one PDF per conversation and the documentation lists the tools.

**9 · High · team — test the uploaded archive**

- *Action:* after uploading to Moodle, download it again, unzip into a different folder whose name contains a space, open `BinairoSolver.vi`, choose `Binairo_6x6.png`, press Run once.
- *Done when:* the PDF is produced with no path edited and no missing-VI dialog.

**10 · Medium · me — settle or document the two free choices**

- *Action:* post on Ed (thread #10 is unanswered): when both digits pass, is the winner the highest percentage or the largest margin over its threshold? If the answer is "highest percentage", change `ChoisirChiffre` to compare `scores` directly and rerun `TestOCR.bat`. In either case keep the sentence about it in the documentation, and keep the sentence that too many pixels is treated as an error.
- *Done when:* the documentation states both behaviours exactly as the executable behaves.

**11 · Medium · me — make the GitHub repository private until grades are out**

- *Reason:* D-14.

**12 · Medium · each author — be able to explain the code**

- *Action:* each member reads `reconnaissance.c`, `SolveBinairo.m` and their VIs until they can explain `goto nettoyage`, the margin rule, `ParcourirCases` and the matrix-product uniqueness test in `GrilleBinairoValide`.
- *Reason:* the group is "responsable de l'entier du code" (syllabus slide 37).

**13 · Low · colleagues — authors and descriptions in every VI**

- *Action:* `VI Properties > Documentation` for each VI; default values 88/90/90 and both options TRUE saved with `Make Current Values Default`; PNG path left empty.

## Category 4 — Unresolved uncertainties

| Question | Needs | Safest course meanwhile |
|---|---|---|
| Highest percentage or largest margin (D-9) | instructor | keep the current rule, document it, default thresholds are equal so results are identical |
| Is stopping on too many pixels acceptable (D-10) | instructor, or nothing | documented choice; allowed by the addendum's wording |
| "Solve with Matlab" unchecked: no MATLAB at all, or an unsolved PDF | instructor | current behaviour (MATLAB draws the recognised grid unsolved) produces a file in both readings; document it |
| MATLAB version and whether `matlab` is on the PATH of the VM | VM | recipe allows choosing `matlab.exe`; never save that path as default |
| LabVIEW bitness and exact 1-bit conversion on the VM | VM | check of item 4; fallback ready |
| Does `System Exec` stay blocked while the PDF viewer or `MathWorksServiceHost` is open (Ed #34) | VM | recipe §18.3 items 6–7 |
| Does `uiopen` open the viewer in `-batch` mode | VM | same fallback |
| Does `TestOCR.bat` itself run as written | VM | if not, run the cases by hand against `attendu_ocr.txt` |
| Appearance of the PDF produced by the VM's MATLAB | VM | compare with Moodle's PDFs |
| Submission date | Moodle ("Remise projets : tba") | watch Moodle and Ed weekly |

## Final readiness checklist

### Mandatory

**C**

- [ ] `OCR.sln` opens and builds in Release x64 with 0 errors on the VM
- [ ] `TestOCR.bat` prints `RESULTAT : tous les cas sont identiques a attendu_ocr.txt`
- [ ] `OCR.exe` in the archive is that Release build

**MATLAB**

- [ ] `TestBinairo` prints `Nombre d'echecs : 0`
- [ ] The three test PDFs look right and were deleted afterwards
- [ ] The seven `.m` files in the archive are the ones tested

**LabVIEW**

- [ ] Main VI is named `BinairoSolver.vi` and sits at the archive root
- [ ] `Binairo_6x6.png` → solved PDF `Binairo_6x6.pdf`, same solution as Moodle
- [ ] `Binairo_6x6_rect.v2.png` → n = 6, solved PDF `Binairo_6x6_rect.v2.pdf`
- [ ] `Binairo_8x8.png` → solved PDF, same solution as Moodle
- [ ] `Binairo_4x4_Bad.png` → PDF with `== Error ==`
- [ ] `Binaro_5x6_Bad.png` → LabVIEW error, MATLAB not launched
- [ ] `BadBinairo.png` → LabVIEW error
- [ ] `OCR.exe` renamed → LabVIEW error, no old result reused; name restored
- [ ] Both options tested in their four combinations
- [ ] Defaults saved: 88 / 90 / 90, options TRUE, empty PNG path, no error
- [ ] No absolute path in any diagram or default value
- [ ] Authors and description in every VI; at least one sub-VI

**Documentation and declarations**

- [ ] `Documentation.pdf`, 5 pages at most, follows the 2026 template
- [ ] Versions in it were read on the VM
- [ ] C error table matches what `OCR.exe` does
- [ ] "Le projet doit être évalué sur : VM"
- [ ] AI tools listed; every conversation exported to `Transcripts_IA/`
- [ ] Other sources and collaboration declared, or stated as none by the team

**Archive**

- [ ] Named with the three members' names
- [ ] One flat folder; no `c/`, `matlab/`, `temp/`
- [ ] `Resultats/` has `Cell.bin`, `CellValue.txt`, `solve.m` and the PDF for each of the four valid images
- [ ] No source PNG, no `.git`, `.vs`, `x64`
- [ ] Re-downloaded from Moodle, unzipped elsewhere, run once successfully

### Optional
- [ ] Ed answer on the digit rule (D-9) obtained and reflected
- [ ] Repository set to private
- [ ] `Tests/` folder included in the archive
- [ ] Zero warnings at `/W4`
