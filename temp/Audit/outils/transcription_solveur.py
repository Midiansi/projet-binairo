# Line-by-line Python transliteration of matlab/SolveBinairo.m + GrilleBinairoValide.m + FormatGrilleValide.m
# (logic cross-check only: this is NOT an execution of the MATLAB code).
import numpy as np, itertools, random, sys
nan=np.nan
def FormatGrilleValide(g):
    if g.ndim!=2: return False
    n=g.shape[0]
    if n<2 or n%2!=0 or g.shape!=(n,n): return False
    return not np.any(~np.isnan(g)&(g!=0)&(g!=1))
def GrilleBinairoValide(g):
    if not FormatGrilleValide(g): return False
    n=g.shape[0]
    z=1.0*(g==0); u=1.0*(g==1)
    comptes=not np.any(z.sum(0)>n/2) and not np.any(z.sum(1)>n/2) and not np.any(u.sum(0)>n/2) and not np.any(u.sum(1)>n/2)
    t_l=(g[:,:-2]==g[:,1:-1])&(g[:,1:-1]==g[:,2:])
    t_c=(g[:-2,:]==g[1:-1,:])&(g[1:-1,:]==g[2:,:])
    eL=z@z.T+u@u.T; eC=z.T@z+u.T@u
    uniques=not np.any((eL==n).sum(1)>1) and not np.any((eC==n).sum(1)>1)
    return comptes and not t_l.any() and not t_c.any() and uniques
def CheckVectorOk(v,n):
    v=np.asarray(v).ravel()
    if n!=v.size or not n>=2 or n%2!=0: return False
    return (not np.any(~np.isnan(v)&(v!=0)&(v!=1))) and (v==0).sum()<=n/2 and (v==1).sum()<=n/2 and not np.any((v[:-2]==v[1:-1])&(v[1:-1]==v[2:]))
def CheckVectorUniqueOk(g,r,c,n):
    ok=True
    if not np.any(np.isnan(g[r,:])):
        ident=(g==np.ones((n,1))*g[r,:]).sum(1)==n; ident[r]=False; ok=not ident.any()
    if ok and not np.any(np.isnan(g[:,c])):
        ident=(g==g[:,[c]]*np.ones((1,n))).sum(0)==n; ident[c]=False; ok=not ident.any()
    return ok
def CheckValidMove(g,r,c,v,n):
    if not FormatGrilleValide(g) or n!=g.shape[0] or v not in (0,1): return False
    if not (0<=r<n and 0<=c<n): return False
    if not np.isnan(g[r,c]) and g[r,c]!=v: return False
    g=g.copy(); g[r,c]=v
    return CheckVectorOk(g[r,:],n) and CheckVectorOk(g[:,c],n) and CheckVectorUniqueOk(g,r,c,n)
def ParcourirCases(g,n,idx,debut,fin):
    ok=True; mod=False
    if debut>fin: return g,ok,mod
    if debut<fin:
        mil=(debut+fin)//2
        g,ok,gm=ParcourirCases(g,n,idx,debut,mil); mod=gm
        if not ok: return g,ok,mod
        g,ok,dm=ParcourirCases(g,n,idx,mil+1,fin); mod=mod or dm
        return g,ok,mod
    c,r=divmod(idx[debut-1],n)   # column-major linear index -> (r,c)
    z=CheckValidMove(g,r,c,0,n); u=CheckValidMove(g,r,c,1,n)
    if not z and not u: return g,False,mod
    if z!=u:
        g=g.copy(); g[r,c]=1*u; mod=True
    return g,ok,mod
def DirectValues(g,n):
    ok=GrilleBinairoValide(g) and n==g.shape[0]
    if not ok: return g,ok
    idx=list(np.flatnonzero(np.isnan(g.T.ravel())))   # column-major find(isnan(grid))
    g,ok,mod=ParcourirCases(g,n,idx,1,len(idx))
    if ok and mod: g,ok=DirectValues(g,n)
    return g,ok
def SolveBinairo(g):
    valid=False
    if not GrilleBinairoValide(g): return g,valid
    n=g.shape[0]
    g,ok=DirectValues(g,n)
    if not ok: return g,valid
    idx=np.flatnonzero(np.isnan(g.T.ravel()))
    if idx.size==0: return g,True
    c,r=divmod(int(idx[0]),n)
    base=g
    if CheckValidMove(base,r,c,0,n):
        e=base.copy(); e[r,c]=0
        g,valid=SolveBinairo(e)
        if valid: return g,valid
    if CheckValidMove(base,r,c,1,n):
        e=base.copy(); e[r,c]=1
        g,valid=SolveBinairo(e)
    return g,valid
# ---------- independent reference: enumerate ALL valid full grids by brute force (no shared code) ----------
def valid_rows(n):
    rows=[]
    for bits in itertools.product((0,1),repeat=n):
        if sum(bits)!=n//2: continue
        if any(bits[i]==bits[i+1]==bits[i+2] for i in range(n-2)): continue
        rows.append(bits)
    return rows
def all_solutions(puz,limit=3):
    n=len(puz); rows=valid_rows(n); sols=[]
    cand=[[r for r in rows if all(puz[i][j] is None or puz[i][j]==r[j] for j in range(n))] for i in range(n)]
    def rec(i,chosen):
        if len(sols)>=limit: return
        if i==n:
            cols=list(zip(*chosen))
            if len(set(cols))!=n: return
            for col in cols:
                if sum(col)!=n//2 or any(col[k]==col[k+1]==col[k+2] for k in range(n-2)): return
            sols.append([list(r) for r in chosen]); return
        for r in cand[i]:
            if r in chosen: continue
            # prune columns: no triple, count
            ok=True
            for j in range(n):
                col=[ch[j] for ch in chosen]+[r[j]]
                if len(col)>=3 and col[-1]==col[-2]==col[-3]: ok=False;break
                if col.count(0)>n//2 or col.count(1)>n//2: ok=False;break
            if ok: rec(i+1,chosen+[r])
    rec(0,[])
    return sols
def to_np(p): return np.array([[nan if v is None else float(v) for v in r] for r in p])
N=None
P6=[[N,0,N,N,N,N],[N,N,0,N,0,N],[N,N,N,N,1,0],[1,1,N,N,N,N],[N,0,N,0,N,N],[N,N,N,N,0,N]]
S6=[[1,0,0,1,1,0],[0,1,0,1,0,1],[1,0,1,0,1,0],[1,1,0,1,0,0],[0,0,1,0,1,1],[0,1,1,0,0,1]]
P8=[[N,0,0,N,N,N,N,0],[N]*8,[1,N,1,N,0,N,N,N],[N,N,N,N,N,N,N,0],[1,N,N,N,1,N,N,N],[N,N,N,N,1,N,1,N],[N,N,0,N,N,N,N,N],[N,0,N,N,N,N,0,0]]
S8=[[1,0,0,1,1,0,1,0],[0,1,0,0,1,0,1,1],[1,0,1,0,0,1,0,1],[0,1,0,1,0,1,1,0],[1,0,1,0,1,0,0,1],[0,1,1,0,1,0,1,0],[0,1,0,1,0,1,0,1],[1,0,1,1,0,1,0,0]]
P4=[[N,0,0,N],[N]*4,[N,0,0,N],[N]*4]
fails=0
def check(name,cond):
    global fails
    print(('PASS ' if cond else 'FAIL ')+name); fails+= (not cond)
g,v=SolveBinairo(to_np(P6)); check('6x6 solved == professor PDF solution', v and g.tolist()==[[float(x) for x in r] for r in S6])
check('6x6 unique solution (brute force)', len(all_solutions(P6))==1)
g,v=SolveBinairo(to_np(P8)); check('8x8 solved == professor PDF solution', v and g.tolist()==[[float(x) for x in r] for r in S8])
check('8x8 unique solution (brute force)', len(all_solutions(P8))==1)
g,v=SolveBinairo(to_np(P4)); check('4x4_Bad -> not valid', v is False); check('4x4_Bad has 0 solutions (brute force)', len(all_solutions(P4))==0)
g,v=SolveBinairo(to_np([[0,N],[N,0]])); check('2x2', v and g.tolist()==[[0,1],[1,0]])
g,v=SolveBinairo(to_np([[0,0,0,N],[N]*4,[N]*4,[N]*4])); check('initial triple -> invalid', v is False)
g,v=SolveBinairo(to_np([[N]*4]*4)); check('empty 4x4 -> valid full grid', v and GrilleBinairoValide(g) and not np.isnan(g).any())
g,v=SolveBinairo(to_np([[N]*8]*8)); check('empty 8x8 -> valid full grid', v and GrilleBinairoValide(g) and not np.isnan(g).any())
check('GrilleBinairoValide dup rows false', GrilleBinairoValide(to_np([[0,1,0,1],[0,1,0,1],[N]*4,[N]*4])) is False)
check('GrilleBinairoValide 3x3 false', GrilleBinairoValide(np.zeros((3,3))) is False)
# randomized differential test vs brute force
random.seed(213)
for n,trials in ((4,400),(6,300)):
    full=all_solutions([[None]*n for _ in range(n)],limit=10**9)
    bad=0; nsolv=0; nuns=0
    for t in range(trials):
        if t%3==0:   # random (often contradictory) clues
            puz=[[random.choice((None,None,None,0,1)) for _ in range(n)] for _ in range(n)]
        else:        # clues taken from a real solution
            sol=random.choice(full); k=random.random()*0.6
            puz=[[sol[i][j] if random.random()<k else None for j in range(n)] for i in range(n)]
        ref=all_solutions(puz,limit=1)
        g,v=SolveBinairo(to_np(puz))
        if v:
            nsolv+=1
            okc=all(puz[i][j] is None or g[i,j]==puz[i][j] for i in range(n) for j in range(n))
            if not (ref and GrilleBinairoValide(g) and not np.isnan(g).any() and okc): bad+=1
        else:
            nuns+=1
            if ref: bad+=1
    check(f'random differential n={n}: {trials} puzzles ({nsolv} solvable, {nuns} unsolvable), mismatches={bad}', bad==0)
print('TOTAL FAILS',fails)
