#!/usr/bin/env python3
"""Development-only assembly helper. Never performs assessed image/solver work."""
from pathlib import Path
import argparse, shutil, platform
ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument('--binary', type=Path, help='Optional already-built target executable')
a = p.parse_args()
out = ROOT / 'runtime'
out.mkdir(exist_ok=True)
required = ['FontRasterized_0_1.h', 'MP_LaunchMatlabScript4.vi']
missing = [n for n in required if not (ROOT/'course_materials'/n).is_file()]
if missing:
    raise SystemExit('Restore course_materials first: ' + ', '.join(missing))
for folder, pattern in [('matlab','*.m'),('labview','*.vi'),('labview','*.ctl'),('resources','*.txt')]:
    for f in (ROOT/folder).glob(pattern):
        shutil.copy2(f,out/f.name)
for f in (ROOT/'tests'/'native').glob('*.m'):
    shutil.copy2(f,out/f.name)
shutil.copy2(ROOT/'course_materials'/'MP_LaunchMatlabScript4.vi',out/'MP_LaunchMatlabScript4.vi')
binary = a.binary or ROOT/'build'/('OCR.exe' if platform.system()=='Windows' else 'OCR')
if binary.is_file():
    shutil.copy2(binary,out/binary.name)
    print('Copied executable:',binary.name,'(use only on the system for which it was built).')
else:
    print('Executable pending: compile using docs/C_OPERATOR_GUIDE.md, then rerun assembly.')
print('Runtime files assembled at:',out)
print('Construct VIs in labview/, then rerun this helper to copy them alongside runtime files.')
