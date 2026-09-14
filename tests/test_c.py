#!/usr/bin/env python3
"""AI-designed CLI acceptance tests; independent integer-bitset oracle, no GUI.
Run: python tests/test_c.py --exe build/OCR
Supplied fixtures are kept outside Git under course_materials/."""
import argparse, json, os, platform, random, re, struct, subprocess, sys, tempfile, time
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
arg = argparse.ArgumentParser()
arg.add_argument('--exe',type=Path,required=True)
arg.add_argument('--report',type=Path,default=ROOT/'state'/'C_TEST_RESULTS.json')
a=arg.parse_args(); EXE=a.exe.resolve()
header=(ROOT/'course_materials'/'FontRasterized_0_1.h').read_text()
words=[int(v,16) for v in re.findall(r'0x[0-9A-Fa-f]+',header)]
assert len(words)==64
T=[words[:32],words[32:]]
records=[]

def oracle(w,h,p,thresholds):
    white=100*p.count(0)/(w*h)
    if white>thresholds[0]:return ' ',white
    if min(w,h)<32:return None,None
    rows=[int(''.join(map(str,p[y*w:(y+1)*w])),2) for y in range(h)]
    scores=[]
    mask=(1<<32)-1
    for d in range(2):
        mismatch=min(sum((((rows[y+r]>>(w-x-32))&mask)^T[d][r]).bit_count() for r in range(32)) for y in range(h-31) for x in range(w-31))
        scores.append(100*(1024-mismatch)/1024)
    eligible=[d for d in range(2) if scores[d]>=thresholds[d+1]]
    if not eligible:return None,None
    d=max(eligible,key=lambda d:(scores[d]-thresholds[d+1],scores[d],-d))
    return str(d),scores[d]

def payload(w,h,d=None,x=0,y=0):
    p=[0]*(w*h)
    if d is not None:
        for r in range(32):
            for c in range(32):p[(y+r)*w+x+c]=(T[d][r]>>(31-c))&1
    return p

def write(p,w,h,pix,extra=b''):
    p.write_bytes(struct.pack('<II',w,h)+bytes(pix)+extra)

def check(name,fn):
    begin=time.monotonic()
    try:fn(); records.append({'test':name,'status':'PASS','seconds':round(time.monotonic()-begin,4)})
    except Exception as e:records.append({'test':name,'status':'FAIL','detail':repr(e)}); print('FAIL',name,repr(e))

def run(cell,t=('98','90','90')):
    return subprocess.run([str(EXE),str(cell),*map(str,t)],capture_output=True,timeout=30)

def success_case(w,h,p,thresholds=(98,90,90)):
    with tempfile.TemporaryDirectory(prefix='binairo test ') as td:
        cell=Path(td)/'Cell.bin'; write(cell,w,h,p)
        expected,score=oracle(w,h,p,thresholds)
        r=run(cell,thresholds)
        assert r.stdout==b'',r.stdout
        if expected is None:
            assert r.returncode in (3,5),(r.returncode,r.stderr)
            assert r.stderr.startswith(b'OCR E') and not (cell.parent/'CellValue.txt').exists()
        else:
            assert r.returncode==0,(r.returncode,r.stderr)
            assert r.stderr==b'',r.stderr
            got=(cell.parent/'CellValue.txt').read_bytes()
            assert got==f"d:'{expected}',{score:.4f}%\n".encode(),(got,expected,score)

def invalid_bytes(blob,code=3):
    with tempfile.TemporaryDirectory() as td:
        cell=Path(td)/'Cell.bin';cell.write_bytes(blob)
        result=cell.parent/'CellValue.txt';result.write_text('STALE')
        r=run(cell)
        assert r.returncode==code,(r.returncode,r.stderr)
        assert r.stdout==b'' and r.stderr.startswith(f'OCR E{code}:'.encode())
        assert not result.exists(),'stale output survived valid input-path attempt'

def supplied(name,expected):
    b=(ROOT/'course_materials'/name).read_bytes();w,h=struct.unpack('<II',b[:8]);p=list(b[8:])
    assert oracle(w,h,p,(88,90,90))[0]==expected
    success_case(w,h,p,(88,90,90))

for name,d in [('Cell0.bin','0'),('Cell1.bin','1'),('CellEmpty.bin',' ')]:check('supplied_'+name,lambda n=name,v=d:supplied(n,v))
for d in (0,1):
    check('exact32_digit'+str(d),lambda d=d:success_case(32,32,payload(32,32,d),(100,100,100)))
    check('bottom_right_rectangular_digit'+str(d),lambda d=d:success_case(45,38,payload(45,38,d,13,6),(100,90,90)))
check('small_empty',lambda:success_case(10,10,payload(10,10)))
check('small_nonempty',lambda:success_case(10,10,[1]+[0]*99,(100,90,90)))
check('empty_equality_is_not_empty',lambda:success_case(32,32,[0]*1024,(100,100,100)))
check('blank_strict_greater',lambda:success_case(32,32,[0]*1024,(99.9999,100,100)))
check('upper_dimension_empty',lambda:success_case(256,256,[0]*65536))
for size in (0,1,9,257,0xffffffff):
    check('invalid_width_'+str(size),lambda s=size:invalid_bytes(struct.pack('<II',s,32)))
    check('invalid_height_'+str(size),lambda s=size:invalid_bytes(struct.pack('<II',32,s)))
for n in range(8):check('short_header_'+str(n),lambda n=n:invalid_bytes(bytes(n),3))
check('short_payload',lambda:invalid_bytes(struct.pack('<II',32,32)+bytes(1023),3))
check('excess_payload',lambda:invalid_bytes(struct.pack('<II',32,32)+bytes(1025)))
check('illegal_pixel',lambda:invalid_bytes(struct.pack('<II',32,32)+bytes([2])+bytes(1023)))
check('big_endian_rejected',lambda:invalid_bytes(struct.pack('>II',32,32)+bytes(1024)))
check('no_match',lambda:success_case(32,32,[1]*1024,(100,100,100)))

p=payload(80,40,0)
for r in range(32):
    for c in range(32):p[r*80+40+c]=(T[1][r]>>(31-c))&1
p[40]^=1
check('margin_vs_raw_disagreement',lambda:success_case(80,40,p,(100,99.95,90)))
p[40]^=1
check('exact_tie_select_zero',lambda:success_case(80,40,p,(100,90,90)))

rng=random.Random(2132026)
for k in range(12):
    w,h=rng.randrange(32,49),rng.randrange(32,45);d=k%2
    p=payload(w,h,d,rng.randrange(w-31),rng.randrange(h-31))
    for j in range(k):p[rng.randrange(len(p))]^=1
    check('oracle_noise_'+str(k),lambda w=w,h=h,p=p:success_case(w,h,p,(100,90,90)))

def bad_argument(t):
    with tempfile.TemporaryDirectory() as td:
        cell=Path(td)/'Cell.bin';write(cell,32,32,[0]*1024)
        r=run(cell,(t,90,90));assert r.returncode==2 and r.stderr.startswith(b'OCR E2:') and r.stdout==b''
for t in ('','-1','101','nan','inf','90x','90,1',' 90','90 ','1e2','0x64'):
    check('bad_threshold_'+repr(t),lambda t=t:bad_argument(t))
for n in range(0,7):
    if n==4:continue
    def arity(n=n):
        r=subprocess.run([str(EXE)]+['0']*n,capture_output=True,timeout=10)
        assert r.returncode==2 and r.stderr.startswith(b'OCR E2:') and r.stdout==b''
    check('argc_user_arguments_'+str(n),arity)

def missing_input():
    with tempfile.TemporaryDirectory() as td:
        r=run(Path(td)/'missing.bin');assert r.returncode==4 and r.stderr.startswith(b'OCR E4:')
check('missing_input',missing_input)

def output_directory():
    with tempfile.TemporaryDirectory() as td:
        cell=Path(td)/'Cell.bin';write(cell,32,32,[0]*1024)
        (Path(td)/'CellValue.txt').mkdir();(Path(td)/'CellValue.txt'/'keep').write_text('do not delete')
        r=run(cell);assert r.returncode==6 and r.stderr.startswith(b'OCR E6:')
        assert (Path(td)/'CellValue.txt'/'keep').read_text()=='do not delete'
check('output_path_is_nonempty_directory',output_directory)

def current_dir_independent():
    with tempfile.TemporaryDirectory(prefix='space and apostrophe\' ') as td:
        cell=Path(td)/'Cell.bin';write(cell,32,32,[0]*1024)
        r=subprocess.run([str(EXE),str(cell),'98','90','90'],cwd=ROOT,capture_output=True,timeout=10)
        assert r.returncode==0 and (Path(td)/'CellValue.txt').is_file()
check('output_beside_input_with_spaces_apostrophe',current_dir_independent)

report={'environment':platform.platform(),'python':sys.version,'executable':str(EXE.name),'native_matlab':False,'native_labview':False,'tests':records,'pass':sum(r['status']=='PASS' for r in records),'fail':sum(r['status']=='FAIL' for r in records)}
a.report.parent.mkdir(parents=True,exist_ok=True);a.report.write_text(json.dumps(report,indent=2)+'\n')
print(f"C tests: {report['pass']} PASS, {report['fail']} FAIL; {a.report}")
sys.exit(bool(report['fail']))
