@echo off
rem Projet Binairo - ME-213
rem Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
rem Controle automatique de OCR.exe sur la VM Windows (outil de test, hors rendu).
rem Utilisation : copier OCR.exe dans ce dossier, puis lancer TestOCR.bat
rem               ou bien : TestOCR.bat "chemin\vers\OCR.exe"
setlocal
cd /d "%~dp0"
set "OCR=%~1"
if "%OCR%"=="" set "OCR=OCR.exe"
set "OUT=resultats_vm.txt"
set "CV=cellules\CellValue.txt"
if not exist "%OCR%" echo OCR.exe introuvable : "%OCR%"& exit /b 1
if exist "%OUT%" del /q "%OUT%"
echo Debut : %TIME%
call :cas cellules\Cell0.bin 88 90 90
call :cas cellules\Cell1.bin 88 90 90
call :cas cellules\CellEmpty.bin 88 90 90
call :cas cellules\Cell0_rect.bin 88 90 90
call :cas cellules\Cell1_rect.bin 88 90 90
call :cas cellules\CellEmpty_rect.bin 88 90 90
call :cas cellules\BadCell_1.bin 88 90 90
call :cas cellules\Bad_Cell0_morepx.bin 88 90 90
call :cas cellules\z50.bin 88 90 90
call :cas cellules\o50.bin 88 90 90
call :cas cellules\e50.bin 88 90 90
call :cas cellules\z1000.bin 88 90 90
call :cas cellules\rect_o.bin 88 90 90
call :cas cellules\rect_z.bin 88 90 90
call :cas cellules\z_tl.bin 88 90 90
call :cas cellules\z_br.bin 88 90 90
call :cas cellules\o_tr.bin 88 90 90
call :cas cellules\o_bl.bin 88 90 90
call :cas cellules\asym.bin 88 90 90
call :cas cellules\h49.bin 88 90 90
call :cas cellules\w49.bin 88 90 90
call :cas cellules\h1001.bin 88 90 90
call :cas cellules\w1001.bin 88 90 90
call :cas cellules\neg.bin 88 90 90
call :cas cellules\zero.bin 88 90 90
call :cas cellules\trunc1.bin 88 90 90
call :cas cellules\extra1.bin 88 90 90
call :cas cellules\hdr3.bin 88 90 90
call :cas cellules\empty.bin 88 90 90
call :cas cellules\hdronly.bin 88 90 90
call :cas cellules\bigendian.bin 88 90 90
call :cas cellules\val2.bin 88 90 90
call :cas cellules\black.bin 88 90 90
call :cas cellules\checker.bin 88 90 90
call :cas cellules\absent.bin 88 90 90
call :cas cellules\Cell0.bin 0 90 90
call :cas cellules\Cell0.bin 88 0 90
call :cas cellules\Cell0.bin 88 90 0
call :cas cellules\Cell0.bin 100 90 90
call :cas cellules\Cell0.bin 88 100 90
call :cas cellules\Cell0.bin 88 90 100
call :cas cellules\Cell0.bin 1 1 1
call :cas cellules\Cell0.bin 99 99 99
call :cas cellules\Cell0.bin 88.5 90 90
call :cas cellules\Cell0.bin 88 abc 90
call :cas cellules\Cell0.bin 88 90 -5
call :cas cellules\Cell0.bin 88 90
call :cas cellules\Cell0.bin 88 90 90 90
call :cas cellules\Cell0.bin
echo Fin   : %TIME%
if exist "%CV%" del /q "%CV%"
echo.
fc "%OUT%" attendu_ocr.txt >nul
if errorlevel 1 goto echec
echo RESULTAT : tous les cas sont identiques a attendu_ocr.txt
exit /b 0
:echec
echo RESULTAT : DIFFERENCES - lignes concernees :
fc "%OUT%" attendu_ocr.txt
exit /b 1

rem Un cas : effacer l'ancien resultat, lancer OCR, noter code de retour et premiere ligne de CellValue.txt
:cas
if exist "%CV%" del /q "%CV%"
"%OCR%" %* 2>nul
set "RC=%ERRORLEVEL%"
set "L=(absent)"
if exist "%CV%" set "L=(vide)"
if exist "%CV%" set /p L=<"%CV%"
>>"%OUT%" echo %* ; code=%RC% ; %L%
goto :eof
