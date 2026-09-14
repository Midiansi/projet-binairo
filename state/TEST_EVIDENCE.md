# Verification evidence — first delivery

Date:2026-09-15. Source and wiring review is distinct from execution.

| Area | Actual evidence | Status |
|---|---|---|
| C build/unit | Apple clang21.0.0 (clang-2100.1.1.101), arm64-apple-darwin25.6.0, C11 strict warnings/VLA warning as error;49 unit checks | PASS normal and ASan/UBSan |
| C CLI | C_TEST_RESULTS.json, C_SANITIZER_RESULTS.json;69 cases using independent Python integer-bitset oracle | PASS both builds |
| Empty directory regression | C_DIRECTORY_REGRESSION.json and C_DIRECTORY_SANITIZER_REGRESSION.json;2 reserved output names | PASS both builds; directories preserved |
| PNG development experiment | PNG_SURROGATE_RESULTS.json;6x6/8x8/4x4 clues exact,6x5 rejected | PASS Python Pillow+C; NOT LabVIEW |
| MATLAB runtime16 files | MATLAB_STATIC_CHECKS.json, MATLAB_STAGE_REVIEW.md; no explicit assessed for/while loops | WRITTEN/SOURCE-REVIEWED; never executed in MATLAB/Octave |
| Native MATLAB test runner |24 tests (22 without viewer), expected matrices/invariants/styles/error statuses | WRITTEN; native results pending |
| LabVIEW | Full main/geometry recipes, currentNI terminal references, copyable resource files; existing supplied launcher preserved | RECIPE REVIEWED; no constructed project VIs or native run |
| Windows OCR/direct launcher | C build recipe; quoted cmd command, -wait -batch for MATLAB | PENDING native target |
| Generated MATLAB PDFs | Native renderer and style tests written | PENDING native rendering/visual check |
| Draft report/transcript PDFs | Agent-generated documentation PDFs rendered separately | DOCUMENT QA only; not MATLAB PDF evidence |
| Submission | Provisional manifest, source mapping, author/version gaps disclosed | NOT submission-ready |

Independent source expectations were derived by review agents. C frozen implementation audit and MATLAB frozen implementation audit could not complete when reviewers hit quota; root performed adversarial self-review, which is not independent. Geometry guide was authored/reviewed by a source reviewer; its self-review is not independent validation. Any later independent main-guide review is logged in FINAL_REVIEW.md.

Observed earlier failures remain disclosed: the first CLI test used Python3.9, producing22 environment failures due to int.bit_count; the runner was repeated successfully with Python>=3.10. The first PNG experiment used an absolute scanline and failed for white margins; detection now offsets from actual black bounds. A documentation PDF font/render issue was repaired with an explicit Unicode font and font configuration. None was relabeled as a native pass.

Not all OS faults (allocation exhaustion, close/flush failures, permission denial under every account) were injected. Source inspection and error branches do not prove those OS cases. Native input geometry assumptions: axis-aligned regular strokes, clean exterior, valid scanlines10pixels inside detected borders; missing paired lines can evade shape checks. Empty default palette needs the finite known-image calibration in the guide. Native conversion uses alpha masking, while the Python surrogate uses compositing, so pixel equivalence remains pending.

User constraints respected: no computer-use/browser automation, MATLAB, LabVIEW, Octave or VM operation; no subscription/reset/credit purchase; no messages/invitations sent to others. Course originals and personal transcripts are excluded from GitHub.
