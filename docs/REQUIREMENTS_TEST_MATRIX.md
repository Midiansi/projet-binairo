# Requirements and acceptance-test matrix

Revision: 2026-09-14. References below use the exact file IDs and **physical PDF pages** in [SOURCE_REFERENCE_LOG.md](SOURCE_REFERENCE_LOG.md). `U` means the user's authorized requirements, including the professor-confirmed inheritance of general 2025 grading rules. `IC` means a clearly labeled project policy from [INTERFACE_CONTRACT.md](INTERFACE_CONTRACT.md), not an official clarification.

Status key: **C PASS** = measured local C evidence, subject to limits stated below; **SOURCE** = requirement/source review, not native execution; **NATIVE PENDING** = human MATLAB/LabVIEW/target-platform evidence still required; **PACKAGE REVIEW** = verify final assembled delivery before submission. Acceptance IDs name expected checks; they are not invented claims that a native runner has already executed them.

Measured C baseline: `c/test_ocr.c` has 49 passing unit checks in normal and AddressSanitizer/UndefinedBehaviorSanitizer builds; `tests/test_c.py` has 69 passing CLI cases in normal and sanitized builds. Compiler: Apple clang 21.0.0, target arm64-apple-darwin25.6.0. JSON records: `state/C_TEST_RESULTS.json` and `state/C_SANITIZER_RESULTS.json`; review: `state/C_STAGE_REVIEW.md`. An earlier Python 3.9 run failed because the test oracle requires `int.bit_count`; the successful rerun used Python >=3.10. This is actual local C execution, not Windows, MATLAB or LabVIEW validation. Not every OS allocation/read/close/flush failure has been fault-injected.

Additional surrogate evidence: `state/PNG_SURROGATE_RESULTS.json` records Python Pillow image processing followed by the real C executable with 98/90/90 thresholds. After locating the black-pixel bounding rectangle and scanning top+10/left+10, it matches source matrices for 6x6, 8x8 and 4x4 and rejects the supplied 6-row/5-column grid. PNG alpha is composited against white. This useful geometry/OCR check does **not** execute LabVIEW conversion, cropping or serialization and does not make any L-row a native PASS.

## C OCR

| ID | Requirement and source | Implementation / expected test | Current status |
|---|---|---|---|
| C01 | Native C owns cell OCR; no delegated service. P26 pp2,6–7; U | `c/main.c`, `c/ocr.c`; review that algorithm uses local supplied bitmaps. | SOURCE; C PASS |
| C02 | Use two packed 32x32 course digit bitmaps and bitwise pixel access. P26 pp11–14; OC p2; FH | Restore unmodified FH; unsigned shift/mask; unit known-bit checks and exact32_digit0/1. | C PASS; source asset restoration check at packaging |
| C03 | Genuine helper functions, minimum one. OC p1; R6 pp41,43 | Functions for reading, matching/bit access, validation and result writing; inspect code, no nominal empty helper. | SOURCE |
| C04 | malloc, bulk payload read, cleanup; no VLA. P26 pp18,20; R6 p41 | `malloc`, one `fread` for W*H pixels; all path cleanup; unit tests and sanitizers. Allocation/final stream-failure fault injection remains partial. | C PASS for exercised paths; SOURCE for unforced OS failures |
| C05 | Width/height U32 LE then row-major U8 0/1. P26 pp16,20–22; CF | exact32_digit*, bottom_right_rectangular_digit*, big_endian_rejected; inspect bytes and first/last locations. | C PASS; LV write round-trip NATIVE PENDING |
| C06 | Complete header and exact payload count; invalid pixels rejected. P26 pp18–19 | short_header_0..7, short_payload, excess_payload, illegal_pixel. Premature EOF is E3; actual input I/O/open is E4. | C PASS |
| C07 | Validate dimensions. P26 p19; IC provisional [10,256] | invalid_width/height_*; upper_dimension_empty; small_empty; small_nonempty. Test low/upper boundaries and arithmetic before allocation. | C PASS; official maximum unresolved |
| C08 | Empty-first, whole-cell white ratio strictly above threshold. P26 pp8,10; OC p3 | supplied_CellEmpty.bin with historical 88/90/90; empty_equality_is_not_empty; blank_strict_greater. | C PASS |
| C09 | Count both black and white equality over template; translate one pixel; include final offsets. P26 pp8–12,18; OC p3 | exact32_digit*; bottom_right_rectangular_digit*; independent integer-bitset oracle_noise_*. | C PASS |
| C10 | Best score per digit and digit threshold comparison. P26 p18 | Exact template with threshold100 must be eligible; tests compare raw unrounded score. | C PASS |
| C11 | Margin selection provisional because sources conflict. P26 p18 vs p10; OC p3; IC | margin_vs_raw_disagreement; check policy isolated by OCR_SELECT_BY_MARGIN. | C PASS; official method unresolved |
| C12 | Deterministic tie; no-match cannot become guessed clue/blank. IC | exact_tie_select_zero; no_match; unit policy tests. Secondary raw-score tie preference also subject to source/unit review. | C PASS for exercised cases; provisional rule |
| C13 | CLI OCR path empty zero one; argc=5. P26 p23 | argc_user_arguments_*; actual command and build executable name. | C PASS |
| C14 | Thresholds finite strict decimals [0,100], no junk; all supplied. IC | bad_threshold_*; unit parser checks for accepted forms and boundaries. No silent atoi truncation. | C PASS; official defaults unresolved |
| C15 | CellValue.txt quoted symbol + percent + newline. P26 p17; IC exact grammar | Successful cases compare exact ASCII bytes, four decimals and LF; blank is one space. Percent is raw score/white ratio, not margin. | C PASS; blank/precision convention provisional |
| C16 | Errors in stderr, captured by LV; no interactive blocking. R6 p42; L1 p13; IC | Invalid inputs verify exit code, stderr prefix `OCR E<number>:` and empty stdout. | C PASS; LV capture NATIVE PENDING |
| C17 | Handle missing input and output creation problems. P26 p19 | missing_input; output_path_is_nonempty_directory; directory contents preserved. Target read-only/fault cases still required. | C PASS for exercised cases; remaining OS faults pending |
| C18 | Result is fresh, failed cell cannot reuse previous result. IC safety policy implementing error propagation | Seed STALE in invalid_bytes tests, verify removal; refuse output if precondition failed; never expose partial result. | C PASS for exercised cases; LV gating NATIVE PENDING |
| C19 | Portable dynamically derived paths; runtime full path allowed. P26 p23; L1 pp10–11; R6 p41 | output_beside_input_with_spaces_apostrophe; no personal paths; output beside input independent of working directory. | C PASS for argv paths; native shell quoting pending |
| C20 | Supplied assets recognized independently. OC p1; CF | supplied_Cell0.bin, supplied_Cell1.bin, supplied_CellEmpty.bin with documented historical thresholds. | C PASS |
| C21 | Target-specific executable and build instructions. R6 p38; U | Mac executable only where built; build Windows with documented target tools; rerun C suite there. | macOS ARM64 C PASS; Windows build/run NATIVE PENDING |

## Native LabVIEW construction and orchestration

All entries in this section are **NATIVE PENDING**. The construction recipe specifies implementation; until human construction evidence exists, it is not an executed VI or proof of correctness.

| ID | Requirement and source | Expected acceptance evidence |
|---|---|---|
| L01 | Main `BinairoSolver.vi`, native image reading/conversion, C and MATLAB orchestration. P26 pp24–26; U | Main VI opens without broken arrow; no assessed PNG/crop work moved into Python/C/MATLAB. Save actual VI files and full diagram/front-panel evidence. |
| L02 | Path, image at correct size, Solve with Matlab, Show pdf and errors accessible. P26 p25 | Defaults and controls visible; 6x6 and 8x8 image dimensions displayed correctly; all toggle combinations operate. |
| L03 | Read real PNG, not filename-extension-only validation. P26 p25; L2 p7; A2 p14 | Valid PNG loads; text/Word renamed .png, corrupt PNG, missing path and no PNG report an error without stale downstream output. |
| L04 | Convert to 1-bit pixmap and unflatten to 2D Boolean array. L1 pp4–5; IC | Composite PNG alpha against white; inspect known black, white and transparent-margin coordinates; true/1 black; exactly one polarity normalization if required. |
| L05 | ComputeRowsCols.vi counts transitions and handles edge strokes. P26 p27; L1 p15 | Supplied grids and supplemental border-at-edge grids give correct counts; FALSE-padding behavior demonstrated. |
| L06 | Square and even grid counts required. P26 p27; L1 p15 | 6x6/8x8 accepted; supplied Binaro_5x6_Bad.png rejected; supplemental odd square and even rectangular counts rejected. |
| L07 | Validate image geometry and cell rectangles. P26 p25; L1 p16; IC | Derive black-pixel bounding rectangle by row/column OR; scan top+10/left+10, not absolute row 10/col 10. Missing/merged strokes and invalid crop bounds fail; no out-of-range subset; transparent/large margins tested. |
| L08 | ComputeCellRect.vi considers cell width, height, row/column and border. L1 p16 | First/last and nonsquare-pixel cells compared with input; left/top correct and right/bottom exclusive; interior stroke pixels excluded. |
| L09 | Write explicit width then height U32 LE; row-major bytes. P26 pp16,22; L1 p9; IC | Capture a nonsquare Cell.bin, show first8 bytes and expected W*H bytes; compare decoded crop to original. No extra array prefix. |
| L10 | One cell at a time: write, launch, read, error handling. L1 p14 | Error-wire/sequence evidence; output writing finishes and closes before OCR starts; no concurrent pipeline in same runtime folder. |
| L11 | Correct CLI arguments and host quoting. P26 p23; L1 p13 | Native command succeeds with spaces and allowed punctuation. Windows unsupported metacharacters fail clearly before launch. No omitted thresholds or extra argument. |
| L12 | Capture error cluster, return code and stderr separately. L1 p13; R6 p42 | Missing executable, E3/E4/E5/E6, nonempty stderr and launch error each stop current pipeline and show source/error. No result read on failure. |
| L13 | Validate CellValue grammar and freshness. P26 p17; L2 p4; IC | Parse 0,1,space into correct values; reject missing/malformed/trailing/out-of-range output. Seed old file then fail process; no stale clue accepted. |
| L14 | Remember each symbol in multiline matrix; blank→NaN. P26 pp25,31; L2 pp4–5 | Known asymmetric matrix matches row/column layout exactly; row separators and commas correct; no transposed matrix. |
| L15 | Generate actual `solve.m` with selected image/options/function calls. P26 pp26,35; L2 p5 | Generated file opened as evidence; escaped sourceFile, exact B, dot decimals, correct toggles and `RunBinairo` call. Manual driver is not accepted as replacement. |
| L16 | Runtime co-location and paths derived from VI. L1 pp10–11; L2 p6; R6 p41 | Copy assembled runtime to new folder/machine and repeat; no code edit or personal path required. Keep input image elsewhere as allowed. |
| L17 | Supplied launcher unchanged, native terminals verified. L2 p6; U | Follow narrow inspection procedure, return Context Help/connector evidence, connect actual terminal types. No guessed terminal identity. |
| L18 | Script creation/MATLAB missing/exception handled. P26 p36; L2 p7 | Read-only runtime, missing MATLAB, deliberate script exception, missing fresh status file: clear failure with diagnostics; no old PDF reported as new. |
| L19 | Minimum subVI and understandable comments/layout. R6 pp41,43 | Required named subVIs present; connector patterns, terminal assignments, VI descriptions and wiring inspected. Current official main pane still missing. |
| L20 | Saved defaults and locale-safe decimals. A2 pp17–18 | Reopen VI and confirm saved provisional defaults; use non-dot locale test while generated MATLAB still uses dot. |
| L21 | Full pipeline completion/PDF and four options. P26 pp24–26,32,35; IC | Full C→LV→MATLAB run on valid6/8 and bad4 fixtures; source filename/output status correct; each of four solve/show combinations. |

## MATLAB solver and rendering

All native checks below are **NATIVE PENDING**. Source review can establish interface/algorithm intent and absence of explicit loops but cannot establish real MATLAB execution, version compatibility, figures or PDF rendering.

| ID | Requirement and source | Expected acceptance evidence |
|---|---|---|
| M01 | `SolveBinairo`, `DirectValues`, `CheckValidMove`, `CheckVectorOk`, `CheckVectorUniqueOk`, `printGrid` signatures. M2 p1; SH | Source interface comparison and native runner invocation of each function; outputs correct shape/logical meaning. |
| M02 | n-by-n even real grid, symbols 0/1/NaN; preserve original clues. P26 pp27,31; L1 p15; SH typo resolved | Native invalid shape/type/value/odd tests; original matrix unchanged after calls; solved grid retains each clue. |
| M03 | No three identical consecutive symbols; balanced full rows/cols. P26 pp28,34; SH | Partial-vector tests below/at/above n/2; row/column triples, including start/end; NaN never treated as 0/1. |
| M04 | Only completed rows/columns checked for duplicates. P26 p34; SH | Complete duplicate rows/cols fail; two equal-looking incomplete vectors with NaN do not fail prematurely. |
| M05 | Validate initial contradictions before searching. P26 pp29,34; IC | Complete invalid grid and contradictory clues rejected even if no empty cell remains; no false valid flag. |
| M06 | Direct deductions repeated to fixed point before a guess. P26 pp29,33–34; M2 p1 | Forced-only puzzle solved without incorrect guess; one/both/neither permissible values handled; multi-pass propagation observed by ready-made tests. |
| M07 | Recursive backtracking, first empty, 0 then 1; no omitted branch. P26 pp29,33–34; M2 p1 | Puzzle requiring backtrack, failed 0/successful 1, both-failed unsatisfiable. First empty follows frozen column-major `find` order. |
| M08 | Invalid/unsatisfiable returns false without corrupting caller original. P26 pp29,34; IC | Bad4/contradictory examples plus AI-designed unsatisfiable input; assert valid=false and caller original unchanged. |
| M09 | First valid result permitted; no uniqueness guarantee. IC | Empty or ambiguous puzzle yields a valid clue-preserving result; validator checks rules instead of demanding one unproven solution. |
| M10 | Inherited absence of explicit for/while, while preserving algorithm. U; R6 pp40,43 | Source scan of assessed MATLAB functions excluding comments/strings; recursive propagation/search and vectorized validity. Native runner still required. |
| M11 | DisplayBinairo signature with compatible DispBinairo. M1 p1; P26 pp32,35 | Both calls resolve from clean runtime; no case-only script duplicate; `solve.m` generated by LV calls primary entry consistently. |
| M12 | Original clues black bold; inferred blue bold; full inner/outer grid. M1 p1; P26 p32 | Open actual native PDF and inspect clues/solution distinction, grid completeness, orientation, legibility and clipping. |
| M13 | Source name upper left, current timestamp upper right, infeasible centered error. M1 p1; P26 p32 | Native solved and unsatisfiable PDFs, screenshot or returned PDF. Exact error text `== Error ==`; actual source name, no fabricated timestamp. |
| M14 | PDF written at required completion; options consistent. P26 pp24–26,35; IC | Four combinations: solve false renders original without false unsatisfiable message; show false suppresses opener only; PDF exists every launched run. |
| M15 | Generated script status/error/log freshness. IC; L2 p7 | OK, UNSOLVABLE, ERROR runs, deliberate exception, stale status/PDF removal, diary and extended error report; error rethrow reaches native launcher. |
| M16 | Reproducible native test runner and operator instructions. U | Human pastes provided commands only, saves Command Window/test log/PDFs/full errors and returns exact evidence set. No hand-written test design needed. |
| M17 | Supplied M1 6x6 example and independent supplemental cases. M1 p1; U | Exact example valid and clues retained; AI-designed tests labeled; 8x8 and bad4 pipeline expectations verified from native results. |

## Cross-component, documentation and submission

| ID | Requirement and source | Expected evidence / check | Status |
|---|---|---|---|
| X01 | All three assessed environments and disk contracts preserved. P26 pp2,6; U | Contract/code/LV recipe cross-review; then actual native chain evidence. | SOURCE; NATIVE PENDING |
| X02 | Full first package before requesting human construction. U | All C/MATLAB source, complete LV recipe, guides, tests, report, manifest/state delivered; no unexplained stubs. | PACKAGE REVIEW |
| X03 | Complete literal LV recipe; mockups not executable VIs. U; L1 p14/L2 p3 | Object IDs, exact types/arrays/clusters/constants, all wires/cases/shift registers/paths, copyable scripts; unresolved launcher inspection labeled narrowly. | PACKAGE REVIEW; NATIVE PENDING |
| X04 | Brief report 1–3 pages, max5. R6 pp48–50 | Author/platform/compiler/version fields truthful; file roles, dataflow, algorithms, errors, limitations included. | DRAFT; final native facts pending |
| X05 | Readable comments, author headers, VI descriptions, minimal real helpers. R6 pp41,43,51–54 | Source review and native VI inspection; actual authors supplied before final report. | SOURCE; authors/native pending |
| X06 | Complete relocatable ZIP: code/build, target executable, VIs, MATLAB, generated results. R6 p38; A2 p4 | Final manifest compared to actual archive; unpack elsewhere and run; course assets restored separately. | PACKAGE REVIEW; native artifacts pending |
| X07 | Disclose external sources, cross-group work and AI; PDF transcripts. R6 p41; A2 p7; U | Preserve complete available exchanges; export true visible transcripts; mark missing conversations; no hidden reasoning/fabricated text. | PACKAGE REVIEW; transcript completeness pending |
| X08 | Exclude course assets and private transcripts/credentials from GitHub. U | Staged-content inspection and ignore rules; independent offline backup restoration instructions. | PACKAGE REVIEW |
| X09 | Private GitHub backup; verify push and label coverage truthfully. U | Remote private/owned status, pushed commit verified; local-only/teammate-only edits not called backed up. | Verified stage history in state/BACKUP_HISTORY.md; final archive receipt records the latest verified push |
| X10 | One writer per VI; no unsafe binary merge; teammate recovery guide. U | `state/VI_OWNERSHIP.md`; exact fetch/contribute/restore steps; preserve both conflicting VI versions. | PACKAGE REVIEW |
| X11 | Current official main connector/error/submission details absent. P26 p36; U | Compact unsent professor questions and provisional policy/manifest; revise all dependent artifacts after answer. | PROVISIONAL; official response pending |
| X12 | No unauthorized GUI/native operation or paid account action. U | Agent uses local text/files/C checks only; native evidence supplied by group; no bought credits/reset/API billing. | SOURCE/process constraint |
| X13 | Honest test status and no grade guarantee. U | C measured separately; MATLAB/LV native pending; sample reference files not presented as generated test success. | Continuous final-review requirement |

## Required remaining evidence before submission-ready status

1. Human native MATLAB test log, full exception details if any, and generated PDFs including unsatisfiable and display-toggle cases.
2. Constructed VIs and verified supplied-launcher interface, followed by native LabVIEW subVI and complete-pipeline runs including failure paths.
3. Target computer/version facts, target executable build/run evidence, clean-folder/relocation run, and complete archive audit.
4. Current official connector/error/submission answers or an explicitly documented unresolved-risk handoff; real authors and complete available AI transcript PDFs.

No row becomes a native PASS merely because source review, a Python oracle or a C fixture test passed. Attach actual logs/files to each native result, preserve failures as well as successful reruns, and update the evidence record after repairs.
