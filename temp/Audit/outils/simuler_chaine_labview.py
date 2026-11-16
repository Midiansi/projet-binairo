# Independent emulation of the LabVIEW recipe (annexe G) + real C OCR, on the course PNGs.
import sys, os, struct, subprocess
import numpy as np
from PIL import Image
imgdir, ocr, work = sys.argv[1], sys.argv[2], sys.argv[3]
def intervals(bits):
    b=[False]+list(bits)+[False]; deb=[];fin=[]
    for i in range(len(bits)+1):
        if (not b[i]) and b[i+1]: deb.append(i)
        if b[i] and (not b[i+1]): fin.append(i)
    return deb,fin
def extent(bits):
    idx=np.flatnonzero(bits)
    return (int(idx[0]), int(idx[-1])+1) if len(idx) else None
def run(name, thr, mode='inside', th=(88,90,90)):
    im=Image.open(os.path.join(imgdir,name)).convert('RGBA')
    bg=Image.new('RGBA',im.size,(255,255,255,255)); im=Image.alpha_composite(bg,im).convert('RGB')
    a=np.asarray(im).astype(int); lum={"mean":a.sum(axis=2)/3,"rec601":a@np.array([0.299,0.587,0.114]),"green":a[...,1]}[KIND]
    bmp=lum<thr   # True = black
    H,W=bmp.shape
    ey=extent(bmp.any(axis=1)); ex=extent(bmp.any(axis=0))
    row=ey[0]+10; col=ex[0]+10
    dX,fX=intervals(bmp[row,:]); dY,fY=intervals(bmp[:,col])
    ncol=(len(dX)+len(fX))//2-1; nrow=(len(dY)+len(fY))//2-1
    info=dict(size=(W,H),nrow=nrow,ncol=ncol,dX=dX,fX=fX,dY=dY,fY=fY)
    if nrow!=ncol or ncol<2 or ncol%2: return info,None,'GEOM 6103'
    M=[];dims=set();pcts=[]
    for r in range(nrow):
        line=[]
        for c in range(ncol):
            if mode=='inside': l,rr,t,b=fX[c],dX[c+1],fY[r],dY[r+1]
            else: l,rr,t,b=dX[c],fX[c+1],dY[r],fY[r+1]
            cell=bmp[t:b,l:rr]; h,w=cell.shape; dims.add((h,w))
            p=os.path.join(work,'Cell.bin')
            with open(p,'wb') as f: f.write(struct.pack('<II',h,w)); f.write(cell.astype(np.uint8).tobytes())
            cv=os.path.join(work,'CellValue.txt')
            if os.path.exists(cv): os.remove(cv)
            res=subprocess.run([ocr,p,str(th[0]),str(th[1]),str(th[2])],capture_output=True,text=True)
            if res.returncode!=0: line.append('E%d'%res.returncode); continue
            txt=open(cv).read(); sym=txt.split("'")[1]; pcts.append((sym,float(txt.split(', ')[1].rstrip('%\n'))))
            line.append({'0':'0','1':'1','-1':'NaN'}[sym])
        M.append(line)
    info['dims']=sorted(dims); info['pct_digit_min']=min([p for s,p in pcts if s!='-1'],default=None); info['pct_empty_min']=min([p for s,p in pcts if s=='-1'],default=None)
    return info,M,'OK'
exp6=[['NaN','0','NaN','NaN','NaN','NaN'],['NaN','NaN','0','NaN','0','NaN'],['NaN','NaN','NaN','NaN','1','0'],['1','1','NaN','NaN','NaN','NaN'],['NaN','0','NaN','0','NaN','NaN'],['NaN','NaN','NaN','NaN','0','NaN']]
N='NaN'
exp8=[[N,'0','0',N,N,N,N,'0'],[N]*8,['1',N,'1',N,'0',N,N,N],[N,N,N,N,N,N,N,'0'],['1',N,N,N,'1',N,N,N],[N,N,N,N,'1',N,'1',N],[N,N,'0',N,N,N,N,N],[N,'0',N,N,N,N,'0','0']]
exp4=[[N,'0','0',N],[N]*4,[N,'0','0',N],[N]*4]
expected={'Binairo_6x6.png':exp6,'Binairo_6x6_rect.v2.png':exp6,'Binairo_6x6_rect.png':exp6,'Binairo_8x8.png':exp8,'Binairo_4x4_Bad.png':exp4,'Binaro_5x6_Bad.png':None}
import itertools
for KIND,name in itertools.product(("rec601","green"),expected):
    for thr in (120,126,128,130,140):
        for mode in ('inside',):
            info,M,st=run(name,thr,mode)
            ok = (M==expected[name]) if expected[name] is not None else (st.startswith('GEOM'))
            print(f"{KIND:6s} {name:26s} thr={thr} {mode:9s} {st:9s} n={info['nrow']}x{info['ncol']} size={info['size']} dims={info.get('dims')} dmin={info.get('pct_digit_min')} emin={info.get('pct_empty_min')} -> {'PASS' if ok else 'FAIL'}")
            if not ok and M: 
                for l in M: print('    ',' '.join(l))
