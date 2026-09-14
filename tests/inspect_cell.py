#!/usr/bin/env python3
"""Development-only inspection of a file written by native LabVIEW."""
import argparse, json, struct
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('file',type=Path);p.add_argument('--expect-asymmetric',action='store_true');a=p.parse_args()
b=a.file.read_bytes()
if len(b)<8:raise SystemExit('FAIL: header shorter than8 bytes')
w,h=struct.unpack('<II',b[:8]);pixels=b[8:]
r={'width':w,'height':h,'bytes':len(b),'expected_bytes':8+w*h,'payload_values':sorted(set(pixels)),'black_count':pixels.count(1)}
valid=len(pixels)==w*h and set(pixels)<={0,1}
if a.expect_asymmetric:
    indexes=[i for i,x in enumerate(pixels) if x]
    r['black_indexes']=indexes;valid=valid and (w,h)==(40,35) and indexes==[89]
r['status']='PASS' if valid else 'FAIL';print(json.dumps(r,indent=2));raise SystemExit(0 if valid else 1)
