#!/usr/bin/env python3
"""Development-only Pillow geometry/OCR experiment. NOT native LabVIEW validation."""
from pathlib import Path
from PIL import Image
import struct,subprocess,tempfile,json,sys
ROOT=Path(__file__).resolve().parents[1]
expected={'Binairo_6x6.png':['_0____','__0_0_','____10','11____','_0_0__','____0_'],'Binairo_8x8.png':['_00____0','________','1_1_0___','_______0','1___1___','____1_1_','__0_____','_0____00'],'Binairo_4x4_Bad.png':['_00_','____','_00_','____'],'Binaro_5x6_Bad.png':None}
exe=Path(sys.argv[1]).resolve() if len(sys.argv)>1 else ROOT/'build'/'OCR'
def runs(v):
 p=[False]+v+[False]
 return [i-1 for i in range(1,len(p)) if p[i] and not p[i-1]],[i-1 for i in range(1,len(p)) if not p[i] and p[i-1]]
out=[]
for name,expected_rows in expected.items():
 raw=Image.open(ROOT/'course_materials'/name).convert('RGBA');im=Image.alpha_composite(Image.new('RGBA',raw.size,'white'),raw).convert('RGB');w,h=im.size
 b=[[sum(im.getpixel((x,y)))<384 for x in range(w)] for y in range(h)]
 top=next(y for y in range(h) if any(b[y]));left=next(x for x in range(w) if any(b[y][x] for y in range(h)))
 xs,xe=runs(b[top+10]);ys,ye=runs([row[left+10] for row in b]);nr,nc=len(ys)-1,len(xs)-1
 item={'file':name,'image_wh':[w,h],'rows':nr,'cols':nc,'x_runs':list(zip(xs,xe)),'y_runs':list(zip(ys,ye))}
 if nr!=nc or nr<2 or nr%2:
  item['result']='REJECT_GRID';assert expected_rows is None;out.append(item);continue
 with tempfile.TemporaryDirectory() as td:
  cell=Path(td)/'Cell.bin';rows=[];scores=[]
  for r in range(nr):
   row=''
   for c in range(nc):
    l,rr,t,bb=xe[c],xs[c+1],ye[r],ys[r+1]
    pix=bytes(b[y][x] for y in range(t,bb) for x in range(l,rr))
    cell.write_bytes(struct.pack('<II',rr-l,bb-t)+pix)
    result=subprocess.run([str(exe),str(cell),'98','90','90'],capture_output=True)
    if result.returncode:raise RuntimeError((name,r,c,result.stderr))
    text=(cell.parent/'CellValue.txt').read_text();row+=text[3].replace(' ','_');scores.append(text.strip())
   rows.append(row)
  item['recognized']=rows;item['scores']=scores;item['result']='MATCH' if rows==expected_rows else 'MISMATCH'
  assert rows==expected_rows,(name,rows,expected_rows)
 out.append(item)
(ROOT/'state'/'PNG_SURROGATE_RESULTS.json').write_text(json.dumps({'warning':'Python Pillow surrogate only; LabVIEW conversion, crop and serialization not executed.', 'results':out},indent=2)+'\n')
print('Supplied PNG surrogate: 6x6,8x8,4x4 match; 6x5 rejected. NOT native LabVIEW validation.')
