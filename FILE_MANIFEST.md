# File manifest and artifact roles

This is the readable manifest. The private archive contains state/PACKAGE_MANIFEST.json with every included file, byte count and SHA256, verified against the actual ZIP. That detailed local manifest includes course/transcript filenames and is excluded from GitHub. The archive excludes .git, caches, compiler intermediates and sanitizer binaries.

| Path/group | Role | GitHub | Native state |
|---|---|---|---|
| README.md, START_HERE.html, NEXT_ACTIONS.md | Start page and exact construction/testing sequence | Yes | Documentation |
| c/main.c,ocr.c,ocr.h,ocr_policy.h | Complete OCR runtime; isolated provisional policy | Yes | macOS compiled/tested |
| c/Makefile,build_windows.cmd,test_ocr.c,README.md | Native builds and49 unit checks | Yes | Windows pending |
| matlab/*.m (16 files) | Required helpers/solver/PDF renderer, wrapper and reference driver | Yes | Written/reviewed; MATLAB pending |
| resources/*.txt | Exact scripts, command formats, regexes and evidence forms | Yes | Native use pending |
| docs/LABVIEW_CONSTRUCTION_GUIDE.md,LABVIEW_GEOMETRY_GUIDE.md,LABVIEW_COMPLETE.html | Entire native construction recipe, combined readable edition | Yes | No constructed VIs claimed |
| docs/*OPERATOR_GUIDE.*,TEAM_GITHUB_GUIDE.*,TEST_PACKAGE.* | Literal builds/commands/tests/restore steps | Yes | Target checks pending |
| docs/INTERFACE_CONTRACT.md,AMBIGUITIES_DECISIONS.md,PROFESSOR_QUESTIONS.md,REQUIREMENTS_TEST_MATRIX.md,SOURCE_REFERENCE_LOG.md | Contract/source/provisional questions and requirements mapping | Yes | Official gaps labeled |
| docs/DRAFT_SUBMISSION_REPORT.md/.pdf,PROVISIONAL_SUBMISSION_MANIFEST.md | Short2-page draft and final submission checklist | Yes | Not submission-ready |
| tests/test_c.py,test_output_directory_regression.py |69 CLI+2 directory checks; AI-designed development tests | Yes | Normal+sanitizer pass |
| tests/native/run_native_tests.m |24 native MATLAB acceptance cases, collection of real results | Yes | Not executed |
| tests/check_png_surrogate.py,inspect_cell.py | Development-only image experiment and binary inspection | Yes | Not runtime dependencies |
| tools/*.py | Runtime assembly, transcript export, native evidence collection, local archive builder | Yes | No assessed functionality outsourced |
| state/*.md/*.json exceptPACKAGE_MANIFEST | Test/review/source/ownership/backup history | Yes | Actual/pending clearly separated |
| labview/README.md | Location for future sourceVIs/typedefs/project | Yes | Team constructs named files |
| course_materials/* andoriginals/* | Unchanged supplied assets and31 selected original sources | No (restore instructions only) | Locally preserved |
| transcripts/*.json/*.md,AI_PROJECT_TRANSCRIPTS.pdf,EXECUTION_REQUEST.txt | Available complete visible message exports to recorded cutoffs +original request | No (methodREADME only) | Missing future/teammate exchanges stated |
| binaries/macos-arm64/OCR | Only tested native executable | No (platformREADME only) | MacARM64 only |
| runtime/* | Co-located MATLAB/resources/launcher/MacOCR; projectVIs copied after construction | No (layoutREADME only) | Not a functioning complete native pipeline yet |
| evidence/ | Later actual target logs/screenshots/files | Only reviewed project evidence | No fabricated native passes |

The source archive and final assessed archive are different: later submission should follow the confirmed2026 requirements and include actual native VIs/output files/target executable. Keep originals and transcripts separately recoverable even when the final runtime excludes them.

Supplemental native fixtures: tests/fixtures/labview/ contains8 AI-designed PNG/corrupt-image cases, README and EXPECTED.json. These are original generated test data, tracked in GitHub, not copied course materials. All native outcomes remain pending.
