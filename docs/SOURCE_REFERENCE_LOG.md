# Source-reference log

Revision: 2026-09-14. All PDF page references are **physical pages**, counting the cover as page 1. They are not the printed slide numbers. Original files remain unchanged in the separate local course-material backup; `state/SOURCE_HASHES.json` records their provenance. Course files are excluded from GitHub until redistribution permission is established.

## Authority

The user's execution request authorizes this implementation and reports that the professor permits unrestricted AI use and confirmed that last year's grading criteria apply. Accordingly, the project inherits general grading, documentation and penalty rules from 2025 while retaining the technical architecture and methods of Binairo 2026. Assignment documents are evidence about the assignment; they do not override the user's prohibition on the agent operating MATLAB, LabVIEW, a VM or computer-use tools.

Current technical source priority: latest Binairo 2026 main deck plus the specific Binairo exercises and supplied assets. The newer main deck prevails over its earlier revision where they differ. Contradictions within current materials are resolved explicitly in [AMBIGUITIES_DECISIONS.md](AMBIGUITIES_DECISIONS.md). The frozen implementation policy is [INTERFACE_CONTRACT.md](INTERFACE_CONTRACT.md); a policy choice is not an official clarification.

## Current assignment and supporting assets

| ID | Exact supplied file | Relevant physical pages / content | Use and limits |
|---|---|---|---|
| P26 | `P00.PPI_Projet.2026.2.pdf` | p1 identifies Rev. 2026.2; pp2,6 architecture; pp7–23 C; pp24–27 LabVIEW; pp28–35 MATLAB; p36 integration errors | Primary current main specification. p36 explicitly promises a later complete error list. |
| P26b | `P00.PPI_Projet.2026_b1.pdf` | p1 identifies Rev. 2026.1; pp7–36 same broad sections | Earlier source for revision comparison; no new authoritative requirements inferred from stale wording. |
| OC | `Exo.Proj.Binairo.OCR.2026.pdf` | p1 C scope/function requirement; p2 packed-bit access and 1D cell indexing; p3 empty-first nested matching algorithm | Confirms genuine C helper function and bitwise extraction. p3 raw-score/strict-threshold wording conflicts with P26 p18 margin/inclusive threshold. |
| L1 | `Exo.Proj.Binairo.LabVIEW.1.pdf` | pp2–9 native image-to-cell pipeline; pp10–11 paths; pp12–14 text/process/error flow; p15 `ComputeRowsCols.vi`; p16 `ComputeCellRect.vi`; p17 tests | Primary native LabVIEW extraction exercise. Diagram p14 is explicitly a nonfunctional mockup. Array-write diagram p9 is not proof of rectangular dimension order. |
| L2 | `Exo.Proj.Binairo.LabVIEW.2.pdf` | pp2–5 accumulation/script generation; p6 supplied launcher; p7 final validation | Requires LabVIEW to generate the MATLAB script. p3 says not all wires are drawn and other VI organizations are allowed. Launcher native terminal interface remains uninspected without LabVIEW. |
| M1 | `Exo.Proj.Binairo.Matlab.1.pdf` | p1 display signature, rules and exact 6x6 example; p2 suggested MATLAB functions | Display source. Prose says `DispBinairo`, signature says `DisplayBinairo`; compatibility wrapper resolves the naming conflict. |
| M2 | `Exo.Proj.Binairo.Matlab.2.pdf` | p1 solver and helper signatures, direct deductions before recursive 0/1 guesses | Primary function-interface and solver-method source. |
| MR | `Exo.Proj.Binairo.Matlab.Recursion.pdf` | p1 factorial and recursive-tree exercises | Recursion pedagogy; factorial/tree tasks are not additional Binairo deliverables. |
| SH | `SolveBinairoHeader.m` | File header and six function skeletons; no PDF page | Supplied function signatures and intended logic preserved. Header's “n MUST be odd” conflicts with current explicit even-size rules and equal symbol counts; treated as a typo. Source says rename this skeleton. |
| FH | `FontRasterized_0_1.h` | Two `int32_t` arrays of 32 rows; width/height constants 32; no PDF page | Required original packed digit bitmaps. Included unchanged from restored course material at C build time; bit-column order explicitly fixed by contract. |
| CH | `Cell_0.h` | 75x75 one-dimensional byte array; no PDF page | Separate illustrative cell with noise for access/printing; not the same object as `Cell0.bin`. |
| CF | `Cell0.bin`, `Cell1.bin`, `CellEmpty.bin` | Binary assets; no PDF page | Each is 5,484 bytes: 8-byte header plus 74x74 byte pixels. First 8 bytes `4a 00 00 00 4a 00 00 00`; payload only 0/1. Square fixtures cannot reveal width/height inversion. |
| GP | `Binairo_6x6.png`, `Binairo_8x8.png`, `Binairo_4x4_Bad.png`, `Binaro_5x6_Bad.png` | Image assets; no PDF page | Native image integration fixtures. Preserve exact misspelling `Binaro_5x6_Bad.png`. “Bad” names are labels, not substitute validation evidence. |
| GD | `Binairo_6x6.pdf`, `Binairo_8x8.pdf`, `Binairo_4x4_Bad.pdf` | Each supplied puzzle/reference PDF p1 | Visual reference assets. Do not claim a native-generated project PDF is validated because a supplied PDF exists. |
| MLVI | `MP_LaunchMatlabScript4.vi` | Binary VI, described in L2 p6 | Retained unchanged; native connector inspection must be done manually. Do not invent terminal names/order/types from filename or screenshots of another VI. |

## Inherited grading and documentation sources

| ID | Exact supplied file | Physical pages | Inherited general requirements |
|---|---|---|---|
| R6 | `P0.PPI_Projet.25.r6.pdf` | pp37–38 submission/archive; pp39–43 evaluation; pp48–54 report/code documentation | Portable complete archive; code and generated outputs; independent C testing; error handling; code readability/comments/author headers; no VLA; minimum C/MATLAB functions and LV subVI; references, collaboration disclosure and AI PDF transcripts. |
| R6 | Same | pp40,43 | MATLAB minimum/absence of loops is inherited conservatively: assessed MATLAB implementation uses no explicit `for` or `while`; recursive propagation still implements P26/M2's required method. |
| A2 | `P0.PPI_Projet_addendum.25.r2.pdf` | pp3–7 archive/evaluation/penalties; p14 invalid PNG and missing executable tests; p17 saved LV defaults; p18 decimal separator | Latest addendum general guidance. p7 repeats attribution/transcript/portability/minimum-helper/no-VLA rules. p18 supports decimal-point-safe MATLAB text. |
| A1 | `P0.PPI_Projet_addendum.25.r1.pdf` | pp3–7,14,17–18 | Compared with A2. A2 p14 newly explicitly calls out the renamed Word-as-PNG and renamed executable checks. Use A2 where revised. |
| EXD | `Ex. Documentation projet.pdf` | p1 | Example structure only: author/platform/compiler/software versions, file list/dataflow/algorithms/errors. Its example names, versions, error numbers and billiard behavior must not be copied as facts about this team. |
| HIST | `P0.PPI_Projet.25.r1.pdf`, `.r2.pdf`, `.r4.pdf`, `.r5.pdf` | Earlier historical revisions preserved | Superseded by supplied r6 for applicable general grading sections. No billiard technical rules imported from these versions. |
| OLDVI | `Billard2025_ConPane.vi` | Binary old assignment connector | Historical material only. It is not a current Binairo connector contract and must not be substituted for one. |

The user's confirmed inheritance makes general criteria applicable; it does not change a billiard-specific algorithm, dimension range, parameter count, output name or connector into a Binairo requirement. In particular, do not inherit billiard RGB ranges, ball-size limits, 29+1 CLI arguments, `[100,1000]` cell bounds, `Pixmap.bin`/`Pos.txt`/`SummaryXX.txt`, a three-ball warning policy or the old main VI connector. P26 p19's exact payload count prevails over the old extra-pixel warning. The old submission procedure's grade assurance is not a guarantee for this project.

## Revision and diagram checks

- P26 p27 adds an explicit square/even requirement missing from P26b p27; L1 p15 independently confirms it. A square grid count does not require a square pixel image.
- P26 p11 fixes the b1 heading about digits 1–9 to symbols 0–1 and names the supplied font header.
- P26 p35 corrects `solves.m` to `solve.m` and changes function-name capitalization; inconsistent `Solve.m` / `solve.m` and display-function names remain elsewhere.
- Visually inspected original P26 p17: quoted digit, comma, percent sign and newline; no blank-token example. P26 pp21–22: four-byte little-endian dimensions, width then height, then one-byte pixels.
- Visually inspected L1 p9: prepend-array-size TRUE and native/little-endian advice. L1 p15: square/even errors and edge-border handling. L1 p16: independent border X/Y, cell width/height, line/column index and rectangle outputs. Approximate border widths in prose/screenshots are not fixed production constants.
- Plain-text extraction alone was not used to infer a functional wiring recipe from course mockups. Any project's wiring recipe still requires later native construction and execution evidence.

## Evidence limits

Local C build/test results belong in the test-evidence record and `state/C_TEST_RESULTS.json`; this source log is not a test-pass record. MATLAB and LabVIEW native execution, graphical VIs, launcher interface, native PDF rendering and full pipeline tests remain pending human evidence. Current complete error rules, Binairo connector and final 2026 submission instructions have not been supplied. No grade is guaranteed.

## Additional primary API checks during the final recipe review

These establish primitive behavior, not execution of our VIs. Checked2026-09-14/15; release-specific native verification remains required.

- NI [Write to Binary File](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/functions/write-to-binary-file.html): explicit little-endian choice, prepend-array-size control and shared refnum positioning.
- NI [Check if File or Folder Exists](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/vi-lib/utility/libraryn-llb/check-if-file-or-folder-exists-vi.html) plus [File/Directory Info](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/functions/file-directory-info.html): existence alone does not distinguish a directory; the guide uses the separate directory result before Delete.
- NI [System Exec](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/vi-lib/platform/system-llb/system-exec-vi.html): wait setting, working directory, exit code/stdout/stderr and error terminals.
- NI [Format Into String](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/functions/format-into-string.html): formatting errors must be retained; initial string and growable argument positions explicitly defined.
- MathWorks [MATLAB startup on Windows](https://www.mathworks.com/help/matlab/ref/matlabwindows.html): direct Windows adapter uses `-wait -batch` to wait for process completion and obtain exit status.
- Geometry's full primary API list appears in LABVIEW_GEOMETRY_GUIDE section8, covering PNG threshold, native picture/rectangle/depth/palette terminals, search and row/column primitives.
