#!/usr/bin/env python3
"""Collect existing native output without running or judging native programs."""
import argparse,datetime,hashlib,json,re,shutil,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--label',required=True);a=p.parse_args()
if not re.fullmatch(r'[A-Za-z0-9_-]+',a.label):raise SystemExit('Use only letters, digits, underscore or hyphen in label')
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
out=root/'evidence'/('native_'+a.label+'_'+stamp);out.mkdir(parents=True)
files=[]
for f in (root/'runtime').iterdir():
    if f.is_file() and (f.name in {'Cell.bin','CellValue.txt','CellValue.txt.tmp','solve.m','MatlabStatus.txt','MatlabError.txt','MatlabRun.log','Asymmetric.bin'} or f.suffix.lower()=='.pdf'):
        shutil.copy2(f,out/f.name);files.append(f.name)
shutil.copy2(root/'resources/NATIVE_EVIDENCE_FORM.txt',out/'NATIVE_EVIDENCE_FORM.txt')
source=[]
for folder,patterns in [('c',['*.c','*.h']),('matlab',['*.m']),('labview',['*.vi','*.ctl','*.lvproj'])]:
    for pattern in patterns:
        for f in (root/folder).glob(pattern):
            source.append({'file':str(f.relative_to(root)),'sha256':hashlib.sha256(f.read_bytes()).hexdigest()})
try:commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True,stderr=subprocess.DEVNULL).strip()
except (OSError,subprocess.CalledProcessError):commit='Git unavailable; fill actual source revision manually'
(out/'COLLECTION.json').write_text(json.dumps({'collected_utc':stamp,'git_commit':commit,'status':'UNREVIEWED — existing files may be stale; fill test form','files':files,'source_hashes':source},indent=2)+'\n')
print('Collected existing files in:',out);print('Add screenshots and fill NATIVE_EVIDENCE_FORM.txt; no native test was run or marked PASS.')
