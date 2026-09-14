#!/usr/bin/env python3
"""Regression: neither output filename may cause removal of an empty directory."""
import argparse,json,struct,subprocess,tempfile
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--exe',type=Path,required=True);p.add_argument('--report',type=Path,required=True);a=p.parse_args();exe=a.exe.resolve();results=[]
for name in ('CellValue.txt','CellValue.txt.tmp'):
    with tempfile.TemporaryDirectory() as tmp:
        d=Path(tmp);(d/name).mkdir();cell=d/'Cell.bin';cell.write_bytes(struct.pack('<II',32,32)+bytes(1024))
        r=subprocess.run([str(exe),str(cell),'98','90','90'],capture_output=True,timeout=10)
        passed=r.returncode==6 and r.stdout==b'' and r.stderr.startswith(b'OCR E6:') and (d/name).is_dir()
        results.append({'name':name,'status':'PASS' if passed else 'FAIL','returncode':r.returncode})
a.report.write_text(json.dumps({'tests':results,'pass':sum(x['status']=='PASS' for x in results),'native_matlab':False,'native_labview':False},indent=2)+'\n');print(results)
raise SystemExit(0 if all(x['status']=='PASS' for x in results) else 1)
