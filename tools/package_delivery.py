#!/usr/bin/env python3
"""Create a local private delivery ZIP, excluding Git/cache/build intermediates.
This intentionally includes preserved course assets and personal transcript
exports: NEVER upload this ZIP to the source repository or make it public.
"""
from pathlib import Path
import argparse,hashlib,json,datetime,zipfile,subprocess
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--receipt',type=Path);a=p.parse_args()
if root==a.output.resolve() or root in a.output.resolve().parents:raise SystemExit('ZIP must be outside project root to prevent recursive packaging')
def included(f):
    parts=f.relative_to(root).parts
    return not any(x in {'.git','build','__pycache__','.DS_Store'} for x in parts) and f.suffix not in {'.pyc','.zip','.lvps','.lvlps','.aliases'} and f.name!='PACKAGE_MANIFEST.json'
files=sorted(f for f in root.rglob('*') if f.is_file() and included(f))
entries=[{'file':str(f.relative_to(root)),'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()} for f in files]
try:revision=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
except (OSError,subprocess.CalledProcessError):revision='unavailable'
manifest={'created_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'source_commit':revision,'scope':'Private local first delivery: course/transcripts included; Git/build/cache excluded. Native MATLAB/LabVIEW pending. Receipt and this manifest are excluded from the per-file list to avoid self-hashing.','files':entries}
manifest_path=root/'state/PACKAGE_MANIFEST.json';manifest_path.write_text(json.dumps(manifest,indent=2)+'\n')
a.output.parent.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(a.output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    for f in files:z.write(f,'binairo/'+str(f.relative_to(root)))
    z.write(manifest_path,'binairo/state/PACKAGE_MANIFEST.json')
    if a.receipt:z.write(a.receipt,'DELIVERY_RECEIPT.json')
with zipfile.ZipFile(a.output) as z:
    assert z.testzip() is None
    for e in entries:assert hashlib.sha256(z.read('binairo/'+e['file'])).hexdigest()==e['sha256'],e['file']
checksum=hashlib.sha256(a.output.read_bytes()).hexdigest()
a.output.with_suffix(a.output.suffix+'.sha256').write_text(checksum+'  '+a.output.name+'\n')
print(json.dumps({'archive':str(a.output),'files':len(entries),'bytes':a.output.stat().st_size,'sha256':checksum,'all_member_hashes_verified':True},indent=2))
