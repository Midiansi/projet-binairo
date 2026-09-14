@echo off
setlocal
rem Run from the Visual Studio "x64 Native Tools Command Prompt".
rem The course header must be restored unchanged in ..\course_materials\.
pushd "%~dp0"
if not exist "..\course_materials\FontRasterized_0_1.h" (
  echo ERROR: Restore FontRasterized_0_1.h into course_materials first. 1>&2
  popd
  exit /b 1
)
where cl >nul 2>nul
if errorlevel 1 (
  echo ERROR: Use an x64 Native Tools Command Prompt with MSVC C11 support. 1>&2
  popd
  exit /b 1
)
if not exist "..\build" mkdir "..\build"
cl /nologo /TC /std:c11 /W4 /WX /O2 /D_CRT_SECURE_NO_WARNINGS /I"..\course_materials" main.c ocr.c /Fe:"..\build\OCR.exe" /Fo:"..\build\\" /link /INCREMENTAL:NO
if errorlevel 1 goto failed
cl /nologo /TC /std:c11 /W4 /WX /O2 /D_CRT_SECURE_NO_WARNINGS /I"..\course_materials" test_ocr.c ocr.c /Fe:"..\build\test_ocr.exe" /Fo:"..\build\\" /link /INCREMENTAL:NO
if errorlevel 1 goto failed
"..\build\test_ocr.exe"
if errorlevel 1 goto failed
echo C build and unit tests completed. OCR.exe is in the build folder.
popd
exit /b 0
:failed
echo ERROR: C build or unit tests failed. Save this entire command output. 1>&2
popd
exit /b 1
