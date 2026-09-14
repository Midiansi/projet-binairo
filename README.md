# EPFL ME-213 Binairo 2026 — complete first-delivery package

C and MATLAB source, build/test files, the complete LabVIEW construction recipe and operator guides are delivered. LabVIEW VIs must now be constructed by the team; native MATLAB/LabVIEW and Windows tests have **not** been executed by the agent. This is the requested first package, not a submission-ready claim.

**Start:** open [START_HERE.html](START_HERE.html), then [the complete LabVIEW guide](docs/LABVIEW_COMPLETE.html). First action: extract the complete archive to a writable teammate folder, preserve the tree, and follow C_OPERATOR_GUIDE through the target C build and runtime assembly. Create the blank LabVIEW project only after that preparation, exactly as guide chapter1 states.

## Package contents

- c/: complete C11 OCR, header/policy, native Windows and make builds, unit tests.
- matlab/: all16 MATLAB files, including required function interfaces, recursive solver, PDF renderer and sample driver.
- docs/: complete main+geometry LabVIEW recipe (combined HTML), C/MATLAB operators, test matrix, decisions, references, team backup guide and short draft report PDF.
- tests/: C integration/regression tests, development-only PNG check and native MATLAB runner; native acceptance instructions in TEST_PACKAGE.
- resources/: exact command/regex/script text and native evidence forms.
- state/: measured C results, source/native verification distinctions, review logs and next actions.
- course_materials/: preserved supplied assets and source originals, included locally but excluded from GitHub.
- transcripts/: available visible project-conversation exports as PDFs/JSON/Markdown, local only; cutoff and unavailable teammate histories disclosed.
- binaries/macos-arm64/: only the actually built/tested Mac executable. Build OCR.exe separately for Windows.
- runtime/: assembled co-located files; functional project VIs will be copied here after construction.

Actual checks:49 C unit checks+69 CLI cases+2 directory-preservation regressions passed in normal and sanitizer builds on macOS ARM64. The PNG+C development check reproduces supplied6x6/8x8/4x4 clues and rejects6x5. None of these are native MATLAB/LabVIEW execution. See [verification](state/TEST_EVIDENCE.md).

Private backup: [Midiansi/projet-binairo](https://github.com/Midiansi/projet-binairo). Sources/guides/tests/state are tracked; course materials, transcripts, generated runtime and binaries need a separate private backup. The delivery receipt accompanies the archive and records the verified latest remote commit. One writer per VI; teammate-only edits are unbacked-up until pushed or returned.

Read [NEXT_ACTIONS.md](NEXT_ACTIONS.md) for the exact next steps and [the provisional submission manifest](docs/PROVISIONAL_SUBMISSION_MANIFEST.md) for later native deliverables. No grade guarantee, fabricated authors, native success or official answer is implied.
