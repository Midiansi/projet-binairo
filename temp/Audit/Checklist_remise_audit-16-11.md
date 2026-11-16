# Binairo — remaining actions and readiness checklist (audit of 16 November 2026)

Separate working file, extracted from `Rapport_audit_2026-11-16.md`. It does not replace the recipe or its validation chapters (19 and 23); it lists what the team still has to do before submitting. Recipe section numbers refer to the corrected copy `temp/Recette_LabVIEW_Binairo_audit-16-11`; they are the same in the original except the new §7.6 and the rewritten §21.3.

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
