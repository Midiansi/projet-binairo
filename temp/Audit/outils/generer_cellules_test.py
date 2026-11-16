import struct, sys, re, os
out = sys.argv[1]
font = open(sys.argv[2]).read()
rows = re.findall(r'\{((?:\s*0x[0-9A-Fa-f]+,?\s*)+)\}', font)
digits = [[int(x,16) for x in re.findall(r'0x[0-9A-Fa-f]+', r)] for r in rows]
assert len(digits)==2 and all(len(d)==32 for d in digits), [len(d) for d in digits]
def bit(d,l,c): return (digits[d][l] >> (31-c)) & 1
def cell(h,w,d=None,oy=0,ox=0,border=0):
    p=[[0]*w for _ in range(h)]
    for i in range(border):
        for x in range(w): p[i][x]=1; p[h-1-i][x]=1
        for y in range(h): p[y][i]=1; p[y][w-1-i]=1
    if d is not None:
        for l in range(32):
            for c in range(32):
                p[oy+l][ox+c]=bit(d,l,c)
    return p
def write(name,h,w,p,hdr=None,extra=b'',trunc=0):
    data=bytes(v for r in p for v in r)
    if trunc: data=data[:-trunc]
    with open(os.path.join(out,name),'wb') as f:
        f.write(hdr if hdr is not None else struct.pack('<II',h,w)); f.write(data+extra)
write('z50.bin',50,50,cell(50,50,0,9,9))
write('o50.bin',50,50,cell(50,50,1,18,18))
write('e50.bin',50,50,cell(50,50))
write('z1000.bin',1000,1000,cell(1000,1000,0,968,968))
write('o1000.bin',1000,1000,cell(1000,1000,1,0,0))
write('e1000.bin',1000,1000,cell(1000,1000))
write('h49.bin',49,60,cell(49,60))
write('w49.bin',60,49,cell(60,49))
write('h1001.bin',1001,60,cell(1001,60))
write('w1001.bin',60,1001,cell(60,1001))
write('rect_o.bin',50,1000,cell(50,1000,1,18,968))
write('rect_z.bin',1000,50,cell(1000,50,0,968,18))
write('neg.bin',60,60,cell(60,60),hdr=struct.pack('<II',4294967196,60))
write('zero.bin',0,0,[],hdr=struct.pack('<II',0,0))
write('trunc1.bin',60,60,cell(60,60,0,5,5),trunc=1)
write('extra1.bin',60,60,cell(60,60,0,5,5),extra=b'\x00')
write('hdr3.bin',0,0,[],hdr=b'\x3c\x00\x00')
write('empty.bin',0,0,[],hdr=b'')
write('hdronly.bin',0,0,[],hdr=struct.pack('<II',60,60))
write('bigendian.bin',60,60,cell(60,60,0,5,5),hdr=struct.pack('>II',60,60))
p=cell(60,60,0,5,5); p[0][0]=2; write('val2.bin',60,60,p)
# all black
write('black.bin',60,60,[[1]*60 for _ in range(60)])
# noise: checkerboard (neither)
write('checker.bin',60,60,[[ (x+y)&1 for x in range(60)] for y in range(60)])
# digit corner positions
write('z_tl.bin',74,74,cell(74,74,0,0,0)); write('z_br.bin',74,74,cell(74,74,0,42,42))
write('o_tr.bin',74,74,cell(74,74,1,0,42)); write('o_bl.bin',74,74,cell(74,74,1,42,0))
# asym: H=55 W=60, single black pixel at row2 col9
p=cell(55,60); p[2][9]=1; write('asym.bin',55,60,p)
print("ok", [hex(x) for x in digits[1][:6]])
