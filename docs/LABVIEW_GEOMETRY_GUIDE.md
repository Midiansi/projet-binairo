# LabVIEW image and geometry construction recipe

This file is one complete module of the main LabVIEW construction guide. Build the five VIs below in the listed order, saving them in `labview/`. They perform the assessed image and geometry work in native LabVIEW. No VI in this recipe calls Python, MATLAB, a DLL or an external image processor. The recipe has been reviewed from sources; **it has not been built or executed in LabVIEW**. The course English LabVIEW version is assumed provisionally.

The shared `ErrorIf.vi` is constructed in the main guide. Its inputs are Boolean `Condition`, I32 `Code`, String `Message`, standard `error in`; its output is standard `error out`. It preserves an existing error and creates the specified error only if Condition is true and no prior error exists.

## 1. Construction notation and exact type rules

1. On the block diagram press **Ctrl+Space** to open Quick Drop, type the exact object name printed below, select that exact primitive/VI from the result list, and press Enter. This is the specified search method; palette paths may differ by version. On macOS use the actual keyboard shortcut shown by **View → Quick Drop** if Ctrl+Space is assigned to the OS. For a project VI, use Quick Drop after adding it to the project, or drag the saved VI from the project tree.
2. Press **Ctrl+H** for Context Help. Move the cursor over each terminal before wiring and read its name/type. For picture VIs use the actual named terminal, not a guessed icon position. Right-click an actual terminal → **Create → Control/Indicator/Constant** when instructed; this preserves NI's exact type.
3. Object IDs in this guide are labels to add beside objects as free labels. They are not LabVIEW node names. A wire entry `A.out → B.x, C.y` means create two branches from the single source A.out to both named destinations. Every listed object is required. `out` on a one-output primitive means its sole output shown in Context Help; comparison `out` means its sole Boolean comparison result. `x` on a one-input conversion means its sole numeric input. Binary arithmetic/Boolean primitive terminals are `x` and `y`. Table shorthand `array` means the primitive's typed array input, `size` means Array Size's size output, `element` means Index Array's element/subarray output, and `index` on Index Array means its single index input. Search 1D Array's different `index` output is explicitly mapped in section8. Array indices are numbered from zero. A wire crossing is not a junction unless the wire branches.
4. The guide names a structure tunnel `S.name`. Create it by wiring through that structure border at the named location; add a free label with the name. Inside a Case, the same named tunnel is the same tunnel in both cases. All Case output tunnels are **Use Default If Unwired OFF** and wired in every case. No required value uses an unwired default. For Loops, every tunnel's indexing state is stated explicitly. Unless stated, an input tunnel is non-indexing, an output tunnel is non-indexing, and there are no shift registers or conditional stop terminals.
5. Standard error cluster order is Boolean `status`, I32 `code`, String `source`. Obtain it through actual error terminals. Normal default is FALSE,0,empty string. Wiring an error cluster to a Case selector produces **Error** and **No Error** cases. All five VIs have such an outer error Case: no work runs on incoming error.
6. Boolean arrays contain **TRUE for black** and FALSE for white after normalization. The image bitmap is exactly 2D `[row,column]`. Numeric pixel coordinates, array indices, dimensions, run starts/ends and n are **I32** unless a native picture terminal explicitly requires I16. Empty arrays have length 0; an empty 2D bitmap has dimensions0×0.
7. Create scalar numeric constants with Numeric Constant; right-click → Representation → I32/U32/U8 as specified, then enter value. Do not leave DBL constants on integer arithmetic. To cast to I32, Quick Drop **To Long Integer**. To cast to I16 only at a native picture rectangle field, Quick Drop **To Word Integer**. No cast may replace a bounds check.
8. **Index Array**: wire array first, then enlarge to reveal the needed index terminals. A 2D index has `index0`=row and `index1`=column. Leave one index deliberately unwired only where this guide explicitly asks for a whole row/column. **Array Size** of 2D returns a 1D I32 array `[height,width]`; it does not return width first.
9. **Build Array** with array inputs must be right-clicked → **Concatenate Inputs** when instructed. **Build Array** with scalar inputs and Concatenate Inputs OFF creates one dimension. A For Loop's auto-indexed1D Boolean output builds a Boolean vector; its auto-indexed2D input supplies one row per iteration.
10. Turn off automatic error dialogs for these subVIs (VI Properties → Execution → uncheck **Enable automatic error handling**); errors propagate through terminals. Add each VI's purpose, units, error behavior and assumptions to VI Properties → Documentation → VI description. Save all VIs after setting defaults.

## 2. Project-owned connector pattern and common types

The current course main connector is absent. These are **project-owned provisional** subVI connectors, not the old billiard connector. Right-click the upper-right front-panel icon → Show Connector; right-click connector → Patterns and select **4×2×2×4 / 12 terminals**. Identify positions by the diagram below. Assign with the wiring tool: click terminal, then front-panel control/indicator. Do not rotate the pattern.

```text
                T1     T2
       L1    +--------------+    R1
       L2    |              |    R2
       L3    |              |    R3
       L4    +--------------+    R4
                B1     B2
```

L1–L4 and R1–R4 run top to bottom; T1/T2 and B1/B2 run left to right. An unused terminal has no assignment; do not attach a hidden control to it.

Create these project type definitions once, if they were not already created in the main guide:

| Type file | Exact construction |
|---|---|
| `GridLines.ctl` | Front-panel Cluster containing four **1D arrays of I32 numeric controls** labeled `xStart`, `xEnd`, `yStart`, `yEnd`. Cluster **Reorder Controls** order0,1,2,3 respectively. All arrays empty default. Customize control; choose **Type Def.**, save in `labview/`. |
| `RectI32.ctl` | Front-panel Cluster containing four **I32 numeric controls** labeled `left`, `top`, `right`, `bottom`, order0,1,2,3. Default all 0. Type Def., save in `labview/`. Right/bottom are exclusive. |

A native picture `Rectangle`/`rect` cluster is different: actual NI terminal fields are I16. Create it from the actual terminal and preserve that native type/order. Do not connect `RectI32.ctl` directly to a native rectangle or silently redefine the typedef as I16.

| VI | L1 | L2 | L3 | L4 | R1 | R2 | R3 | R4 | T1 | T2 | B1 | B2 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| BoolExtent.vi | Bits | unused | unused | error in | First | EndExclusive | unused | error out | unused | unused | unused | unused |
| BlackRuns.vi | Bits | unused | unused | error in | Starts | Ends | unused | error out | unused | unused | unused | unused |
| ComputeCellRect.vi | row | col | GridLines | error in | Rect | unused | unused | error out | unused | unused | unused | unused |
| ComputeRowsCols.vi | Bitmap | unused | unused | error in | n | GridLines | unused | error out | unused | unused | unused | unused |
| ReadImage.vi | PNG path | unused | unused | error in | Bitmap | Picture | Width | error out | unused | Height | unused | unused |

Error codes reserved here:6101 image/path/dimensions,6102 black bounds/scanlines,6103 grid counts/gaps,6104 cell indices/rectangle,6105 palette/calibration. These are local project codes, not official course error numbers.

## 3. BoolExtent.vi — first and last occupied position

### 3.1 Front panel and diagram objects

Create a blank VI and Save As `BoolExtent.vi`. Add these front-panel objects; `C`=control and `I`=indicator:

| ID | Panel object | Type/default |
|---|---|---|
| BE.P1 | C `Bits` | 1D Boolean array, empty |
| BE.P2 | C `error in` | standard error cluster, no error |
| BE.P3 | I `First` | I32,0 |
| BE.P4 | I `EndExclusive` | I32,0 |
| BE.P5 | I `error out` | standard error cluster |

Place `BE.S0` Case around all processing. Wire BE.P2 to its selector. Its Error case contains BE.K0 I32 constant0 and an error passthrough. Its No Error case contains the following objects:

| ID | Diagram object / configuration |
|---|---|
| BE.N1 | Array Size, input 1D Boolean, scalar I32 length |
| BE.N2 | Search 1D Array; search Boolean TRUE; start index I32 zero |
| BE.N3 | Reverse 1D Array |
| BE.N4 | Search 1D Array; search Boolean TRUE; start index I32 zero |
| BE.N5 | Subtract I32; length minus reversed-found-index |
| BE.N6 | Less? I32; first index <0 |
| BE.K1 | Boolean constant TRUE |
| BE.K2 | I32 constant0 |
| BE.K3 | I32 constant6102 |
| BE.K4 | String constant `No black pixels on the inspected axis.` |
| BE.E1 | ErrorIf.vi |
| BE.S1 | Final Case, selector BE.E1.error out; outputs first,end,error |

### 3.2 Every wire

| Scope | Wires |
|---|---|
| Outside BE.S0 | BE.P1 → BE.S0.bits; BE.P2 → BE.S0.selector, BE.S0.err; BE.S0.first → BE.P3; BE.S0.end → BE.P4; BE.S0.error → BE.P5 |
| BE.S0 Error | BE.K0 → BE.S0.first, BE.S0.end; BE.S0.err → BE.S0.error |
| BE.S0 No Error | BE.S0.bits → BE.N1.array, BE.N2.array, BE.N3.array; BE.K1 → BE.N2.element, BE.N4.element; BE.K2 → BE.N2.start index, BE.N4.start index, BE.N6.y; BE.N3.reversed array → BE.N4.array; BE.N1.size → BE.N5.x; BE.N4.index → BE.N5.y; BE.N2.index → BE.N6.x, BE.S1.first; BE.N5.out → BE.S1.end; BE.K2 → BE.S1.zero; BE.N6.out → BE.E1.Condition; BE.K3 → BE.E1.Code; BE.K4 → BE.E1.Message; BE.S0.err → BE.E1.error in; BE.E1.error out → BE.S1.selector, BE.S1.err; BE.S1.first out → BE.S0.first; BE.S1.end out → BE.S0.end; BE.S1.error out → BE.S0.error |
| BE.S1 No Error | BE.S1.first → BE.S1.first out; BE.S1.end → BE.S1.end out; BE.S1.err → BE.S1.error out |
| BE.S1 Error | BE.S1.zero → BE.S1.first out, BE.S1.end out; BE.S1.err → BE.S1.error out |

No loops, no shift registers. Search returning−1 is checked before outputs are accepted. EndExclusive is **length − reverse-search-index**, not length−index−1.

### 3.3 Checkpoint

Enter `[F,F,T,T,F,T,F]`: expect First 2, EndExclusive 6, clear error. Enter `[T]`:0,1,clear. Enter all FALSE or empty:6102 and both numeric outputs0. Supply error statusTRUE/code 123/source`seed`: expect that same error and zero outputs. Save; this checkpoint is a test to be performed by the group, not an already observed result.

## 4. BlackRuns.vi — exact stroke intervals, including edge strokes

### 4.1 Objects

Create/save `BlackRuns.vi`. Front panel:

| ID | Panel object | Type/default |
|---|---|---|
| BR.P1 | C `Bits` | 1D Boolean array, empty |
| BR.P2 | C `error in` | standard error cluster |
| BR.P3 | I `Starts` | 1D I32 array, empty |
| BR.P4 | I `Ends` | 1D I32 array, empty |
| BR.P5 | I `error out` | standard error cluster |

`BR.S0` is the outer error Case. Error case has BR.K0 empty 1D I32 array. No Error case objects:

| ID | Object/configuration |
|---|---|
| BR.K1 | 1D Boolean array constant containing exactly `[FALSE]` |
| BR.K2 | I32 constant1 |
| BR.N1 | Build Array, three array inputs, **Concatenate Inputs ON**, order leadingFALSE / Bits / trailingFALSE |
| BR.N2 | Array Size on original Bits |
| BR.N3 | Add I32, N+1 |
| BR.F1 | For Loop, N wired N+1, parallelism disabled, no conditional stop, no SR; pad input non-indexing; two conditional indexing outputs |
| BR.F1.N1 | Add I32, i+1 |
| BR.F1.N2 | Index Array on padded1D vector at i |
| BR.F1.N3 | Index Array on padded1D vector at i+1 |
| BR.F1.N4 | NOT on previous bit |
| BR.F1.N5 | NOT on current bit |
| BR.F1.N6 | AND, rising = NOT previous AND current |
| BR.F1.N7 | AND, falling = previous AND NOT current |

### 4.2 Every wire and loop tunnel

| Scope | Wires |
|---|---|
| Outside BR.S0 | BR.P1 → BR.S0.bits; BR.P2 → BR.S0.selector, BR.S0.err; BR.S0.starts → BR.P3; BR.S0.ends → BR.P4; BR.S0.error → BR.P5 |
| BR.S0 Error | BR.K0 → BR.S0.starts, BR.S0.ends; BR.S0.err → BR.S0.error |
| BR.S0 No Error | BR.K1 → BR.N1.input0, BR.N1.input2; BR.S0.bits → BR.N1.input1, BR.N2.array; BR.N2.size → BR.N3.x; BR.K2 → BR.N3.y, BR.F1.one; BR.N3.out → BR.F1.N; BR.N1.array → BR.F1.pad; BR.F1.starts → BR.S0.starts; BR.F1.ends → BR.S0.ends; BR.S0.err → BR.S0.error |
| BR.F1 body | BR.F1.i → BR.F1.N1.x, BR.F1.N2.index, BR.F1.starts.value, BR.F1.ends.value; BR.F1.one → BR.F1.N1.y; BR.F1.N1.out → BR.F1.N3.index; BR.F1.pad → BR.F1.N2.array, BR.F1.N3.array; BR.F1.N2.element → BR.F1.N4.x, BR.F1.N7.x; BR.F1.N3.element → BR.F1.N5.x, BR.F1.N6.y; BR.F1.N4.out → BR.F1.N6.x; BR.F1.N5.out → BR.F1.N7.y; BR.F1.N6.out → BR.F1.starts.condition; BR.F1.N7.out → BR.F1.ends.condition |

For each of `BR.F1.starts` and `BR.F1.ends`: wire i to an output tunnel, right-click that tunnel → **Tunnel Mode → Conditional** (conditional indexing). Wire the corresponding Boolean to the small condition terminal now exposed beside that same tunnel. Both value inputs are I32; both output arrays are1D I32. Do not use Last Value or Concatenating mode. Indexing is disabled on pad and one inputs. The loop iterates i=0 through original length N inclusive, comparing padded[i] and padded[i+1]. It does not read beyond the padded length N+2. No previous-bit SR is needed.

### 4.3 Checkpoint

| Bits | Starts | Ends |
|---|---|---|
| `[F,T,T,F,T,F]` | `[1,4]` | `[3,5]` |
| `[T,T,F,T]` | `[0,3]` | `[2,4]` |
| `[T,T]` | `[0]` | `[2]` |
| `[F,F]` or empty | empty | empty |

These are half-open intervals `[start,end)`. The empty/no-stroke case is not a BlackRuns error; ComputeRowsCols rejects it as an invalid grid. Incoming error passes through and produces empty output arrays. Save.

## 5. ComputeCellRect.vi — one crop, with bounds checked before indexing

### 5.1 Front panel and constants

Create/save `ComputeCellRect.vi` and assign the connector from section2.

| ID | Panel object | Type/default |
|---|---|---|
| CR.P1 | C `row` | I32,0; zero-based |
| CR.P2 | C `col` | I32,0; zero-based |
| CR.P3 | C `GridLines` | GridLines.ctl, four empty 1D I32 arrays |
| CR.P4 | C `error in` | standard error cluster |
| CR.P5 | I `Rect` | RectI32.ctl, all 0 |
| CR.P6 | I `error out` | standard error cluster |

Place these diagram constants outside the outer Case: `CR.K0` RectI32 constant all 0; `CR.K1` I32 zero; `CR.K2` I32 one; `CR.K3` I32 two; `CR.K4` I32 three; `CR.K5` I32 ten; `CR.K6` I32 256; `CR.K7` I32 4096; `CR.K8` I32 6104; `CR.K9` String `Invalid grid-line arrays or cell row/column.`; `CR.K10` String `Cell interior rectangle is invalid or outside 10..256 pixels.`.

`CR.S0` is outer error Case. Its No Error case contains CR.S1 after input validation, and CR.S1.No Error contains CR.S2 after rectangle validation. All three have output tunnels `rect out`,`error out`. Their Error cases contain only zero-Rect and error passthrough wires. The tables below name every input and output tunnel; constants crossing a border use a named tunnel with the same constant suffix (e.g. `S1.K5`).

### 5.2 Array/index validation objects (inside CR.S0.No Error)

| ID | Exact object / configuration |
|---|---|
| CR.U1 | Unbundle By Name, four fields xStart,xEnd,yStart,yEnd from GridLines |
| CR.A1 / CR.A2 / CR.A3 / CR.A4 | Four Array Size objects, respectively xStart,xEnd,yStart,yEnd; scalar I32 lengths |
| CR.N1 | Subtract I32, xStart-length minus1 = n |
| CR.N2 | Quotient & Remainder I32, n divided by2; remainder used |
| CR.C1 | Not Equal?, xStart-length vs xEnd-length |
| CR.C2 | Not Equal?, xStart-length vs yStart-length |
| CR.C3 | Not Equal?, yStart-length vs yEnd-length |
| CR.C4 | Less?, xStart-length <3 |
| CR.C5 | Less?, row <0 |
| CR.C6 | Less?, col <0 |
| CR.C7 | Greater Or Equal?, row >=n |
| CR.C8 | Greater Or Equal?, col >=n |
| CR.C9 | Not Equal?, remainder !=0 |
| CR.B1 | Build Array,9 Boolean scalar inputs, Concatenate OFF |
| CR.O1 | Or Array Elements, Boolean array → scalar |
| CR.E1 | ErrorIf.vi |

Wires:

| Scope | Every wire |
|---|---|
| Outer diagram | CR.P1 → CR.S0.row; CR.P2 → CR.S0.col; CR.P3 → CR.S0.lines; CR.P4 → CR.S0.selector, CR.S0.err; CR.K0 → CR.S0.K0; CR.K1 → CR.S0.K1; CR.K2 → CR.S0.K2; CR.K3 → CR.S0.K3; CR.K4 → CR.S0.K4; CR.K5 → CR.S0.K5; CR.K6 → CR.S0.K6; CR.K7 → CR.S0.K7; CR.K8 → CR.S0.K8; CR.K9 → CR.S0.K9; CR.K10 → CR.S0.K10; CR.S0.rect out → CR.P5; CR.S0.error out → CR.P6 |
| CR.S0 Error | CR.S0.K0 → CR.S0.rect out; CR.S0.err → CR.S0.error out |
| CR.S0 No Error: lengths | CR.S0.lines → CR.U1.cluster; CR.U1.xStart → CR.A1.array, CR.S1.xStart; CR.U1.xEnd → CR.A2.array, CR.S1.xEnd; CR.U1.yStart → CR.A3.array, CR.S1.yStart; CR.U1.yEnd → CR.A4.array, CR.S1.yEnd; CR.A1.size → CR.N1.x, CR.C1.x, CR.C2.x, CR.C4.x; CR.A2.size → CR.C1.y; CR.A3.size → CR.C2.y, CR.C3.x; CR.A4.size → CR.C3.y; CR.S0.K2 → CR.N1.y; CR.N1.out → CR.N2.x, CR.C7.y, CR.C8.y; CR.S0.K3 → CR.N2.y; CR.S0.K4 → CR.C4.y |
| CR.S0 No Error: indices | CR.S0.row → CR.C5.x, CR.C7.x, CR.S1.row; CR.S0.col → CR.C6.x, CR.C8.x, CR.S1.col; CR.S0.K1 → CR.C5.y, CR.C6.y, CR.C9.y; CR.N2.remainder → CR.C9.x |
| CR.S0 No Error: error chain | CR.C1.out → CR.B1.input0; CR.C2.out → CR.B1.input1; CR.C3.out → CR.B1.input2; CR.C4.out → CR.B1.input3; CR.C5.out → CR.B1.input4; CR.C6.out → CR.B1.input5; CR.C7.out → CR.B1.input6; CR.C8.out → CR.B1.input7; CR.C9.out → CR.B1.input8; CR.B1.array → CR.O1.Boolean array; CR.O1.logical OR → CR.E1.Condition; CR.S0.K8 → CR.E1.Code; CR.S0.K9 → CR.E1.Message; CR.S0.err → CR.E1.error in; CR.E1.error out → CR.S1.selector, CR.S1.err |
| CR.S0 No Error: S1 constants/results | CR.S0.K0 → CR.S1.K0; CR.S0.K1 → CR.S1.K1; CR.S0.K2 → CR.S1.K2; CR.S0.K5 → CR.S1.K5; CR.S0.K6 → CR.S1.K6; CR.S0.K7 → CR.S1.K7; CR.S0.K8 → CR.S1.K8; CR.S0.K10 → CR.S1.K10; CR.S1.rect out → CR.S0.rect out; CR.S1.error out → CR.S0.error out |
| CR.S1 Error | CR.S1.K0 → CR.S1.rect out; CR.S1.err → CR.S1.error out |

### 5.3 Rectangle computation objects (inside CR.S1.No Error)

| ID | Object/configuration |
|---|---|
| CR.N3 / CR.N4 | Add I32, col+1 / row+1 |
| CR.I1 | Index Array xEnd[col] = left |
| CR.I2 | Index Array xStart[col+1] = right |
| CR.I3 | Index Array yEnd[row] = top |
| CR.I4 | Index Array yStart[row+1] = bottom |
| CR.N5 / CR.N6 | Subtract I32, right−left / bottom−top |
| CR.C10 / CR.C11 | Less? width<10 / Greater? width>256 |
| CR.C12 / CR.C13 | Less? height<10 / Greater? height>256 |
| CR.C14 / CR.C15 | Less? left<0 / Less? top<0 |
| CR.C16 / CR.C17 | Greater? right>4096 / Greater? bottom>4096 |
| CR.B2 | Build Array,8 Boolean scalar inputs, Concatenate OFF |
| CR.O2 | Or Array Elements |
| CR.E2 | ErrorIf.vi |
| CR.U2 | Bundle By Name with RectI32 base cluster; fields left,top,right,bottom |
| CR.S2 | Case selected by CR.E2.error out |

| Scope | Every wire |
|---|---|
| CR.S1 No Error: indices | CR.S1.col → CR.N3.x, CR.I1.index; CR.S1.row → CR.N4.x, CR.I3.index; CR.S1.K2 → CR.N3.y, CR.N4.y; CR.N3.out → CR.I2.index; CR.N4.out → CR.I4.index; CR.S1.xEnd → CR.I1.array; CR.S1.xStart → CR.I2.array; CR.S1.yEnd → CR.I3.array; CR.S1.yStart → CR.I4.array |
| CR.S1 No Error: geometry | CR.I1.element → CR.N5.y, CR.C14.x, CR.U2.left; CR.I2.element → CR.N5.x, CR.C16.x, CR.U2.right; CR.I3.element → CR.N6.y, CR.C15.x, CR.U2.top; CR.I4.element → CR.N6.x, CR.C17.x, CR.U2.bottom; CR.N5.out → CR.C10.x, CR.C11.x; CR.N6.out → CR.C12.x, CR.C13.x; CR.S1.K5 → CR.C10.y, CR.C12.y; CR.S1.K6 → CR.C11.y, CR.C13.y; CR.S1.K1 → CR.C14.y, CR.C15.y; CR.S1.K7 → CR.C16.y, CR.C17.y; CR.S1.K0 → CR.U2.input cluster, CR.S2.zeroRect |
| CR.S1 No Error: final gate | CR.C10.out → CR.B2.input0; CR.C11.out → CR.B2.input1; CR.C12.out → CR.B2.input2; CR.C13.out → CR.B2.input3; CR.C14.out → CR.B2.input4; CR.C15.out → CR.B2.input5; CR.C16.out → CR.B2.input6; CR.C17.out → CR.B2.input7; CR.B2.array → CR.O2.Boolean array; CR.O2.logical OR → CR.E2.Condition; CR.S1.K8 → CR.E2.Code; CR.S1.K10 → CR.E2.Message; CR.S1.err → CR.E2.error in; CR.E2.error out → CR.S2.selector, CR.S2.err; CR.U2.output cluster → CR.S2.goodRect; CR.S2.rect out → CR.S1.rect out; CR.S2.error out → CR.S1.error out |
| CR.S2 No Error | CR.S2.goodRect → CR.S2.rect out; CR.S2.err → CR.S2.error out |
| CR.S2 Error | CR.S2.zeroRect → CR.S2.rect out; CR.S2.err → CR.S2.error out |

No loops, no shift registers. Only S1.No Error contains Index Array on the four coordinate arrays, so invalid lengths/indices cannot reach it. All potentially invalid rectangles are withheld by S2.

### 5.4 Checkpoint

Set xStart=`[0,20,40]`, xEnd=`[2,22,42]`, yStart=`[0,18,36]`, yEnd=`[2,20,38]`. row0,col0 → Rect=`left2,top2,right20,bottom18`; row1,col1 →`22,20,40,36`. Width18 and height16 are valid nonsquare crops. row2, col−1, mismatched array lengths, or an interior width9 must return6104 and Rect all 0. Incoming error is preserved. Save.

## 6. ComputeRowsCols.vi — image bounds, scanlines and valid grid

### 6.1 Panel, constants and error Cases

Create/save `ComputeRowsCols.vi`. Panel objects: `GC.P1` C Bitmap 2D Boolean empty; `GC.P2` C error in; `GC.P3` I n I32 zero; `GC.P4` I GridLines GridLines.ctl; `GC.P5` I error out. Use connector section2. The bitmap is the normalized black-TRUE array from ReadImage.

Diagram constants outside all Cases:

| ID | Type/value |
|---|---|
| GC.K0 | GridLines.ctl constant, all four arrays empty |
| GC.K1 / GC.K2 / GC.K3 / GC.K4 | I32 values0 /1 /2 /10 |
| GC.K5 / GC.K6 | I32 values32 /4096 |
| GC.K7 / GC.K8 | I32 6101 / String `Image dimensions must be 32..4096 pixels.` |
| GC.K9 / GC.K10 | I32 6102 / String `Grid bounds do not contain the required top+10/left+10 scanlines.` |
| GC.K11 / GC.K12 | I32 6103 / String `Grid must have equal even row/column counts of at least two.` |

Structure nesting: GC.S0 outer error gate; S0.No Error validates dimensions then GC.S1; S1.No Error derives bounds then GC.S2; S2.No Error counts strokes then GC.S3; S3.No Error validates cell interiors then GC.S4 final gate. All five Cases have output tunnels `n out`,`lines out`,`error out`. Every Error case explicitly returns zero,empty-lines,the input error. All Case tunnels have Use Default If Unwired OFF.

### 6.2 Dimension check (GC.S0.No Error)

| ID | Object/configuration |
|---|---|
| GC.A1 | Array Size on Bitmap,1D I32 `[height,width]` |
| GC.I1 / GC.I2 | Index Array on dimensions at0(height)/1(width) |
| GC.C1 / GC.C2 | Less? height<32 / Greater? height>4096 |
| GC.C3 / GC.C4 | Less? width<32 / Greater? width>4096 |
| GC.B1 / GC.O1 | Build Array4 Boolean inputs Concatenate OFF / Or Array Elements |
| GC.E1 | ErrorIf.vi |

| Scope | Every wire |
|---|---|
| Outside GC.S0 | GC.P1 → GC.S0.bitmap; GC.P2 → GC.S0.selector, GC.S0.err; GC.K0 → GC.S0.K0; GC.K1 → GC.S0.K1; GC.K2 → GC.S0.K2; GC.K3 → GC.S0.K3; GC.K4 → GC.S0.K4; GC.K5 → GC.S0.K5; GC.K6 → GC.S0.K6; GC.K7 → GC.S0.K7; GC.K8 → GC.S0.K8; GC.K9 → GC.S0.K9; GC.K10 → GC.S0.K10; GC.K11 → GC.S0.K11; GC.K12 → GC.S0.K12; GC.S0.n out → GC.P3; GC.S0.lines out → GC.P4; GC.S0.error out → GC.P5 |
| GC.S0 Error | GC.S0.K1 → GC.S0.n out; GC.S0.K0 → GC.S0.lines out; GC.S0.err → GC.S0.error out |
| GC.S0 No Error: checks | GC.S0.bitmap → GC.A1.array, GC.S1.bitmap; GC.A1.size → GC.I1.array, GC.I2.array; GC.S0.K1 → GC.I1.index; GC.S0.K2 → GC.I2.index; GC.I1.element → GC.C1.x, GC.C2.x; GC.I2.element → GC.C3.x, GC.C4.x; GC.S0.K5 → GC.C1.y, GC.C3.y; GC.S0.K6 → GC.C2.y, GC.C4.y; GC.C1.out → GC.B1.input0; GC.C2.out → GC.B1.input1; GC.C3.out → GC.B1.input2; GC.C4.out → GC.B1.input3; GC.B1.array → GC.O1.Boolean array; GC.O1.logical OR → GC.E1.Condition; GC.S0.K7 → GC.E1.Code; GC.S0.K8 → GC.E1.Message; GC.S0.err → GC.E1.error in; GC.E1.error out → GC.S1.selector, GC.S1.err |
| GC.S0 No Error: constants/results | GC.S0.K0 → GC.S1.K0; GC.S0.K1 → GC.S1.K1; GC.S0.K2 → GC.S1.K2; GC.S0.K3 → GC.S1.K3; GC.S0.K4 → GC.S1.K4; GC.S0.K9 → GC.S1.K9; GC.S0.K10 → GC.S1.K10; GC.S0.K11 → GC.S1.K11; GC.S0.K12 → GC.S1.K12; GC.S1.n out → GC.S0.n out; GC.S1.lines out → GC.S0.lines out; GC.S1.error out → GC.S0.error out |
| GC.S1 Error | GC.S1.K1 → GC.S1.n out; GC.S1.K0 → GC.S1.lines out; GC.S1.err → GC.S1.error out |

### 6.3 Bounding rectangle and scan positions (GC.S1.No Error)

| ID | Object/configuration |
|---|---|
| GC.F1 | For Loop; auto-index Bitmap rows at input `row`; no N wire, no SR, no stop; auto-index scalar occupied output |
| GC.F1.O1 | Or Array Elements on one Boolean row |
| GC.T1 | Transpose 2D Array; used only to derive column occupancy |
| GC.F2 | For Loop; auto-index transposed rows at input `col`; no N wire, no SR, no stop; auto-index scalar occupied output |
| GC.F2.O1 | Or Array Elements on one original-image column |
| GC.V1 / GC.V2 | BoolExtent.vi, respectively row occupancy / column occupancy |
| GC.N1 / GC.N2 | Add I32, top+10 / left+10 |
| GC.C5 / GC.C6 | Greater Or Equal?, scanRow>=bottomExclusive / scanCol>=rightExclusive |
| GC.O2 | OR two Booleans |
| GC.E2 | ErrorIf.vi |

| Scope | Every wire |
|---|---|
| GC.S1 No Error: occupancy | GC.S1.bitmap → GC.F1.row, GC.T1.2D array, GC.S2.bitmap; GC.T1.transposed array → GC.F2.col; GC.F1.occupied → GC.V1.Bits; GC.F2.occupied → GC.V2.Bits; GC.S1.err → GC.V1.error in; GC.V1.error out → GC.V2.error in |
| GC.F1 body | GC.F1.row → GC.F1.O1.Boolean array; GC.F1.O1.logical OR → GC.F1.occupied |
| GC.F2 body | GC.F2.col → GC.F2.O1.Boolean array; GC.F2.O1.logical OR → GC.F2.occupied |
| GC.S1 No Error: bounds | GC.V1.First → GC.N1.x; GC.V2.First → GC.N2.x; GC.S1.K4 → GC.N1.y, GC.N2.y; GC.N1.out → GC.C5.x, GC.S2.scanRow; GC.N2.out → GC.C6.x, GC.S2.scanCol; GC.V1.EndExclusive → GC.C5.y; GC.V2.EndExclusive → GC.C6.y; GC.C5.out → GC.O2.x; GC.C6.out → GC.O2.y; GC.O2.out → GC.E2.Condition; GC.S1.K9 → GC.E2.Code; GC.S1.K10 → GC.E2.Message; GC.V2.error out → GC.E2.error in; GC.E2.error out → GC.S2.selector, GC.S2.err |
| GC.S1 No Error: constants/results | GC.S1.K0 → GC.S2.K0; GC.S1.K1 → GC.S2.K1; GC.S1.K2 → GC.S2.K2; GC.S1.K3 → GC.S2.K3; GC.S1.K11 → GC.S2.K11; GC.S1.K12 → GC.S2.K12; GC.S2.n out → GC.S1.n out; GC.S2.lines out → GC.S1.lines out; GC.S2.error out → GC.S1.error out |
| GC.S2 Error | GC.S2.K1 → GC.S2.n out; GC.S2.K0 → GC.S2.lines out; GC.S2.err → GC.S2.error out |

Do not transpose the production bitmap. Only T1's branch is transposed, for the column OR calculation. F1 emits one occupancy Boolean per image row; F2 one per image column. A blank image produces6102 from BoolExtent and never reaches scanline indexing.

### 6.4 Stroke counting and square/even validation (GC.S2.No Error)

| ID | Object/configuration |
|---|---|
| GC.I3 | Index Array 2D, row index wired scanRow; **column index deliberately unwired** →1D full horizontal scan |
| GC.I4 | Index Array 2D, **row index deliberately unwired**; column index wired scanCol →1D full vertical scan |
| GC.V3 / GC.V4 | BlackRuns.vi for horizontal / vertical scan |
| GC.A2 / GC.A3 | Array Size, horizontal Starts / vertical Starts |
| GC.N3 / GC.N4 | Subtract I32 lengths−1 →columns/rows |
| GC.N5 | Quotient & Remainder I32, columns/2 |
| GC.C7 | Not Equal? columns vs rows |
| GC.C8 | Less? columns<2 |
| GC.C9 | Not Equal? columns remainder !=0 |
| GC.B2 / GC.O3 | Build Array3 Boolean scalar inputs, Concatenate OFF / Or Array Elements |
| GC.E3 | ErrorIf.vi |
| GC.U1 | Bundle By Name on empty GridLines.ctl, all four field entries |

| Scope | Every wire |
|---|---|
| GC.S2 No Error: scans | GC.S2.bitmap → GC.I3.array, GC.I4.array; GC.S2.scanRow → GC.I3.index0; GC.S2.scanCol → GC.I4.index1; GC.I3.element → GC.V3.Bits; GC.I4.element → GC.V4.Bits; GC.S2.err → GC.V3.error in; GC.V3.error out → GC.V4.error in |
| GC.S2 No Error: counts | GC.V3.Starts → GC.A2.array, GC.U1.xStart; GC.V3.Ends → GC.U1.xEnd; GC.V4.Starts → GC.A3.array, GC.U1.yStart; GC.V4.Ends → GC.U1.yEnd; GC.S2.K0 → GC.U1.input cluster; GC.A2.size → GC.N3.x; GC.A3.size → GC.N4.x; GC.S2.K2 → GC.N3.y, GC.N4.y; GC.N3.out → GC.N5.x, GC.C7.x, GC.C8.x, GC.S3.n; GC.N4.out → GC.C7.y; GC.S2.K3 → GC.N5.y, GC.C8.y; GC.N5.remainder → GC.C9.x; GC.S2.K1 → GC.C9.y |
| GC.S2 No Error: error gate | GC.C7.out → GC.B2.input0; GC.C8.out → GC.B2.input1; GC.C9.out → GC.B2.input2; GC.B2.array → GC.O3.Boolean array; GC.O3.logical OR → GC.E3.Condition; GC.S2.K11 → GC.E3.Code; GC.S2.K12 → GC.E3.Message; GC.V4.error out → GC.E3.error in; GC.E3.error out → GC.S3.selector, GC.S3.err; GC.U1.output cluster → GC.S3.lines; GC.S2.K0 → GC.S3.K0; GC.S2.K1 → GC.S3.K1; GC.S3.n out → GC.S2.n out; GC.S3.lines out → GC.S2.lines out; GC.S3.error out → GC.S2.error out |
| GC.S3 Error | GC.S3.K1 → GC.S3.n out; GC.S3.K0 → GC.S3.lines out; GC.S3.err → GC.S3.error out |

Starts/Ends lengths are equal by construction of BlackRuns with FALSE padding. Every stroke count contributes one fewer cell; do not divide that number again by2. The transition-to-stroke conversion already happened inside BlackRuns.

### 6.5 Validate all horizontal/vertical interiors (GC.S3.No Error)

Place `GC.F3` For Loop; wire N=n, parallelism disabled, no stop terminal. Add **one initialized standard-error shift register** by right-clicking its left border → Add Shift Register. Call its terminals `err.L` and `err.R`. It is initialized from GC.S3.err outside the loop. `lines` and `zero` inputs are non-indexing. Inside place `GC.F3.V1` and `GC.F3.V2`, two ComputeCellRect.vi instances. Outside loop place `GC.S4` final error Case.

| Scope | Every wire |
|---|---|
| GC.S3 No Error, loop inputs | GC.S3.n → GC.F3.N, GC.S4.n; GC.S3.lines → GC.F3.lines, GC.S4.lines; GC.S3.K1 → GC.F3.zero, GC.S4.zero; GC.S3.K0 → GC.S4.emptyLines; GC.S3.err → GC.F3.err.L.initializer |
| GC.F3 body | GC.F3.zero → GC.F3.V1.row, GC.F3.V2.col; GC.F3.i → GC.F3.V1.col, GC.F3.V2.row; GC.F3.lines → GC.F3.V1.GridLines, GC.F3.V2.GridLines; GC.F3.err.L.current → GC.F3.V1.error in; GC.F3.V1.error out → GC.F3.V2.error in; GC.F3.V2.error out → GC.F3.err.R.next |
| GC.S3 No Error, after loop | GC.F3.err.R.final → GC.S4.selector, GC.S4.err; GC.S4.n out → GC.S3.n out; GC.S4.lines out → GC.S3.lines out; GC.S4.error out → GC.S3.error out |
| GC.S4 No Error | GC.S4.n → GC.S4.n out; GC.S4.lines → GC.S4.lines out; GC.S4.err → GC.S4.error out |
| GC.S4 Error | GC.S4.zero → GC.S4.n out; GC.S4.emptyLines → GC.S4.lines out; GC.S4.err → GC.S4.error out |

Both Rect outputs inside F3 are explicitly unused. The n calls at row0 visit every horizontal cell gap; the n calls at col0 visit every vertical gap. They therefore check all widths/heights without a second raster scan. A first failure remains in the SR and subsequent calls skip work using their outer Error case. n is at least2 before F3, but its SR is still initialized, never left to prior-run memory.

### 6.6 Checkpoint and geometry scope

After ReadImage is built, the supplied 6x6/8x8/bad4 PNGs should produce n=6/n=8/n=4 and no geometry error. The bad4 puzzle is geometrically valid; MATLAB later diagnoses its puzzle contradiction. `Binaro_5x6_Bad.png` contains 6 rows/5 columns and must fail 6103. A valid edge-touching grid must retain its first/last strokes. A blank image, interior gap 9 or 257, odd square grid, even rectangular grid, or scan outside the detected bounds must produce the corresponding error and empty outputs.

This policy assumes an axis-aligned grid, no extraneous black marks outside it, and usable scanlines 10 pixels inside the detected top/left border. It detects malformed strokes that violate its shape/gap checks; it cannot prove that every apparently valid grid has no missing pair of strokes. The Python surrogate verifies source geometry expectations only; it does not replace these native checks. Save.

## 7. ReadImage.vi — native PNG, white background and black-TRUE polarity

### 7.1 Panel and fixed interface

Create/save `ReadImage.vi`. Use section2 connector. There are **no calibration controls on the connector**. The fallback calibration constants described below are internal and used only when NI returns an empty/default palette.

| ID | Panel object | Exact type/default |
|---|---|---|
| RI.P1 | C `PNG path` | Path, empty |
| RI.P2 | C `error in` | standard error cluster |
| RI.P3 | I `Bitmap` | 2D Boolean array, empty 0×0 |
| RI.P4 | I `Picture` | native2D picture, created from Draw Flattened Pixmap `new picture`; empty |
| RI.P5 | I `Width` | I32,0 |
| RI.P6 | I `Height` | I32,0 |
| RI.P7 | I `error out` | standard error cluster |

Set the 2D Picture indicator background to white: open View → Tools Palette, select the Set Color/coloring tool, right-click the picture's drawing area to open its color picker, and select white (RGB255,255,255). This is also required for the main VI's Picture indicator. ReadImage returns the native picture, not a resized screenshot. Width/Height report the pixel dimensions for inspection. The main guide uses a manually sized scrollable picture display; no image scaling occurs here.

Structure nesting is RI.S0 outer error gate → S1 path-valid gate → S2 PNG-read-success gate → S3 original-dimensions-valid gate → S4 conversion-valid gate → S5 final palette/polarity-valid gate. Each named Case has output tunnels `bitmap out`,`picture out`,`width out`,`height out`,`error out`. All Cases are error-cluster Cases with Error and No Error. Error cases return empty bitmap, empty picture,0,0,and the incoming error. No image conversion VI is invented to have error terminals: only Read PNG File and project ErrorIf nodes have error terminals in this network.

For **each exact Case row below**, place the listed three default constants **inside that case's Error frame** and make the listed wires. This table completely defines all six Error frames; the No Error frames are specified afterward.

| Error frame | Constant IDs/types | Every Error-frame wire |
|---|---|---|
| RI.S0.Error | RI.S0.D1 empty 2D Boolean; RI.S0.D2 empty native picture; RI.S0.D3 I32 0 | D1→RI.S0.bitmap out; D2→RI.S0.picture out; D3→RI.S0.width out,RI.S0.height out; RI.S0.err→RI.S0.error out |
| RI.S1.Error | RI.S1.D1 empty 2D Boolean; RI.S1.D2 empty native picture; RI.S1.D3 I32 0 | D1→RI.S1.bitmap out; D2→RI.S1.picture out; D3→RI.S1.width out,RI.S1.height out; RI.S1.err→RI.S1.error out |
| RI.S2.Error | RI.S2.D1 empty 2D Boolean; RI.S2.D2 empty native picture; RI.S2.D3 I32 0 | D1→RI.S2.bitmap out; D2→RI.S2.picture out; D3→RI.S2.width out,RI.S2.height out; RI.S2.err→RI.S2.error out |
| RI.S3.Error | RI.S3.D1 empty 2D Boolean; RI.S3.D2 empty native picture; RI.S3.D3 I32 0 | D1→RI.S3.bitmap out; D2→RI.S3.picture out; D3→RI.S3.width out,RI.S3.height out; RI.S3.err→RI.S3.error out |
| RI.S4.Error | RI.S4.D1 empty 2D Boolean; RI.S4.D2 empty native picture; RI.S4.D3 I32 0 | D1→RI.S4.bitmap out; D2→RI.S4.picture out; D3→RI.S4.width out,RI.S4.height out; RI.S4.err→RI.S4.error out |
| RI.S5.Error | RI.S5.D1 empty 2D Boolean; RI.S5.D2 empty native picture; RI.S5.D3 I32 0 | D1→RI.S5.bitmap out; D2→RI.S5.picture out; D3→RI.S5.width out,RI.S5.height out; RI.S5.err→RI.S5.error out |

In each row D1/D2/D3 is the fully prefixed ID in that row, not one shared object. Create each D2 by copying a correctly typed empty picture constant created from the actual Draw Flattened Pixmap `picture` terminal.

### 7.2 Path and PNG reading

Place inside RI.S0.No Error: `RI.N1` Path To String; `RI.N2` String Length; `RI.C1` Equal? I32; `RI.K1` I32 0; `RI.K2` I32 6101; `RI.K3` String `Select a PNG file path.`; `RI.E1` ErrorIf.vi; `RI.S1` Case.

Place inside RI.S1.No Error: `RI.PNG` **Read PNG File.vi**; `RI.K4` **U8**128 for `Transparency Thresh`; `RI.S2` Case. NI's threshold converts alpha to a transparent/opaque mask. With white conversion background, fully transparent margins become white. This is **binary mask handling**, not a claim of mathematically exact fractional-alpha compositing. The supplied fixtures and a transparent-margin fixture must pass native tests.

| Scope | Every wire |
|---|---|
| Outside RI.S0 | RI.P1→RI.S0.path; RI.P2→RI.S0.selector,RI.S0.err; RI.S0.bitmap out→RI.P3; RI.S0.picture out→RI.P4; RI.S0.width out→RI.P5; RI.S0.height out→RI.P6; RI.S0.error out→RI.P7 |
| RI.S0.No Error | RI.S0.path→RI.N1.path,RI.S1.path; RI.N1.string→RI.N2.string; RI.N2.length→RI.C1.x; RI.K1→RI.C1.y; RI.C1.out→RI.E1.Condition; RI.K2→RI.E1.Code; RI.K3→RI.E1.Message; RI.S0.err→RI.E1.error in; RI.E1.error out→RI.S1.selector,RI.S1.err |
| RI.S1.No Error | RI.S1.path→RI.PNG.path to PNG file; RI.S1.err→RI.PNG.error in; RI.K4→RI.PNG.Transparency Thresh; RI.PNG.image data→RI.S2.data; RI.PNG.error out→RI.S2.selector,RI.S2.err |

Read PNG File's returned `path` is explicitly unused. Its `image data` is passed as the entire original native cluster, not rebuilt from bytes. This preserves the native padding and transparency mask. Do not wire an empty path and rely on its file dialog.

### 7.3 Original rectangle and dimension check

Inside RI.S2.No Error, place:

| ID | Object/configuration |
|---|---|
| RI.U1 | Unbundle By Name on native PNG image data, select `Rectangle` only |
| RI.U2 | Unbundle By Name on that native Rectangle; fields left,top,right,bottom, each I16 |
| RI.T1 / RI.T2 / RI.T3 / RI.T4 | To Long Integer, respective left/top/right/bottom to I32 |
| RI.N3 / RI.N4 | Subtract I32, right−left = Width / bottom−top = Height |
| RI.K5 / RI.K6 / RI.K7 | I32 0 /32 /4096 |
| RI.K8 / RI.K9 | I32 6101 / String `PNG rectangle must start at zero and have width/height 32..4096.` |
| RI.C2 / RI.C3 | Less? Width<32 / Greater? Width>4096 |
| RI.C4 / RI.C5 | Less? Height<32 / Greater? Height>4096 |
| RI.C6 / RI.C7 | Not Equal? left!=0 / top!=0 |
| RI.B1 / RI.O1 | Build Array6 Boolean scalar inputs Concatenate OFF / Or Array Elements |
| RI.E2 | ErrorIf.vi |
| RI.S3 | Error Case |

| Scope | Every wire |
|---|---|
| RI.S2.No Error: native rectangle | RI.S2.data→RI.U1.cluster,RI.S3.data; RI.U1.Rectangle→RI.U2.cluster,RI.S3.rect; RI.U2.left→RI.T1.x; RI.U2.top→RI.T2.x; RI.U2.right→RI.T3.x; RI.U2.bottom→RI.T4.x; RI.T1.out→RI.N3.y,RI.C6.x; RI.T2.out→RI.N4.y,RI.C7.x; RI.T3.out→RI.N3.x; RI.T4.out→RI.N4.x |
| RI.S2.No Error: size checks | RI.N3.out→RI.C2.x,RI.C3.x,RI.S3.width; RI.N4.out→RI.C4.x,RI.C5.x,RI.S3.height; RI.K6→RI.C2.y,RI.C4.y; RI.K7→RI.C3.y,RI.C5.y; RI.K5→RI.C6.y,RI.C7.y; RI.C2.out→RI.B1.input0; RI.C3.out→RI.B1.input1; RI.C4.out→RI.B1.input2; RI.C5.out→RI.B1.input3; RI.C6.out→RI.B1.input4; RI.C7.out→RI.B1.input5; RI.B1.array→RI.O1.Boolean array; RI.O1.logical OR→RI.E2.Condition; RI.K8→RI.E2.Code; RI.K9→RI.E2.Message; RI.S2.err→RI.E2.error in; RI.E2.error out→RI.S3.selector,RI.S3.err |

The origin check is a defensive project policy for decoded PNGs, which are expected to start at0,0. Cast each I16 field to I32 **before** subtracting. The original native Rectangle cluster goes unchanged to RI.S3.rect; it is not the project's RectI32 cluster.

### 7.4 Conversion, palette length and shape checks

Inside RI.S3.No Error, place:

| ID | Object/configuration |
|---|---|
| RI.DRAW | Draw Flattened Pixmap.vi |
| RI.PIX | Picture to Pixmap.vi |
| RI.UNF | Unflatten Pixmap.vi; use its **1-bit pixmap** output only |
| RI.K10 | Empty native picture constant, created from RI.DRAW.picture |
| RI.K11 | I32 1, depth |
| RI.K12 | U32 `0x00FFFFFF` (decimal16777215), Background Color white |
| RI.K13 / RI.K14 | I32 0 /I32 2 |
| RI.K15 / RI.K16 | I32 6101 / String `Converted bitmap size or depth does not match the PNG.` |
| RI.K17 / RI.K18 | I32 6105 / String `The 1-bit conversion returned an invalid palette length.` |
| RI.A1 / RI.I1 / RI.I2 | Array Size raw2D bitmap →I32 dimensions; Index Array dimensions at0/1 |
| RI.U3 | Unbundle By Name on RI.PIX.image data; `image depth` field I32 |
| RI.A2 | Array Size returned colors U32 array |
| RI.C8 / RI.C9 | Not Equal? raw-height vs original-height / raw-width vs original-width |
| RI.C10 | Not Equal? image depth vs1 |
| RI.B2 / RI.O2 | Build Array3 Boolean scalar inputs Concatenate OFF / Or Array Elements |
| RI.E3 | ErrorIf.vi for shape/depth |
| RI.C11 / RI.C12 / RI.O3 | Not Equal? palette length vs0 / Not Equal? palette length vs2 / AND |
| RI.E4 | ErrorIf.vi for palette length |
| RI.S4 | Error Case |

| Scope | Every wire |
|---|---|
| RI.S3.No Error: conversion | RI.K10→RI.DRAW.picture; RI.S3.data→RI.DRAW.image data; RI.DRAW.new picture→RI.PIX.picture,RI.S4.picture; RI.S3.rect→RI.PIX.rect; RI.K11→RI.PIX.depth; RI.K12→RI.PIX.Background Color; RI.PIX.image data→RI.UNF.image data,RI.U3.cluster; RI.UNF.1-bit pixmap→RI.A1.array,RI.S4.raw; RI.UNF.colors→RI.A2.array,RI.S4.colors |
| RI.S3.No Error: converted dimensions | RI.A1.size→RI.I1.array,RI.I2.array; RI.K13→RI.I1.index; RI.K11→RI.I2.index; RI.I1.element→RI.C8.x; RI.S3.height→RI.C8.y,RI.S4.height; RI.I2.element→RI.C9.x; RI.S3.width→RI.C9.y,RI.S4.width; RI.U3.image depth→RI.C10.x; RI.K11→RI.C10.y; RI.C8.out→RI.B2.input0; RI.C9.out→RI.B2.input1; RI.C10.out→RI.B2.input2; RI.B2.array→RI.O2.Boolean array; RI.O2.logical OR→RI.E3.Condition; RI.K15→RI.E3.Code; RI.K16→RI.E3.Message; RI.S3.err→RI.E3.error in |
| RI.S3.No Error: palette validation | RI.A2.size→RI.C11.x,RI.C12.x,RI.S4.paletteLength; RI.K13→RI.C11.y; RI.K14→RI.C12.y; RI.C11.out→RI.O3.x; RI.C12.out→RI.O3.y; RI.O3.out→RI.E4.Condition; RI.K17→RI.E4.Code; RI.K18→RI.E4.Message; RI.E3.error out→RI.E4.error in; RI.E4.error out→RI.S4.selector,RI.S4.err |

RI.PIX.`new picture`, RI.UNF.`top left`, RI.UNF.`24-bit pixmap`, `8-bit pixmap`, `4-bit pixmap`, and `mask` outputs are explicitly unused. Only1-bit pixmap is valid at depth 1. Width/Height are verified against raw array shape; native conversion has no error terminals, so these checks are essential.

### 7.5 Palette mapping and final normalization

Inside RI.S4.No Error, place `RI.K19` I32 0, `RI.C13` Equal? paletteLength==0, `RI.PC` Boolean Case selected by C13, `RI.NOTRAW` NOT (on 2D Boolean array), `RI.SELECT` Select, and `RI.S5` final error Case. RI.PC has inputs `raw`,`colors`,`err`; outputs `blackBit`,`error out`. It contains no unwired Case outputs.

| Scope | Every wire |
|---|---|
| RI.S4.No Error: branch and output gate | RI.S4.paletteLength→RI.C13.x; RI.K19→RI.C13.y; RI.C13.out→RI.PC.selector; RI.S4.raw→RI.PC.raw,RI.NOTRAW.x,RI.SELECT.t; RI.S4.colors→RI.PC.colors; RI.S4.err→RI.PC.err; RI.PC.blackBit→RI.SELECT.s; RI.NOTRAW.out→RI.SELECT.f; RI.SELECT.out→RI.S5.bitmap; RI.S4.picture→RI.S5.picture; RI.S4.width→RI.S5.width; RI.S4.height→RI.S5.height; RI.PC.error out→RI.S5.selector,RI.S5.err |
| RI.S5.No Error | RI.S5.bitmap→RI.S5.bitmap out; RI.S5.picture→RI.S5.picture out; RI.S5.width→RI.S5.width out; RI.S5.height→RI.S5.height out; RI.S5.err→RI.S5.error out |

For the two-color palette case **RI.PC.FALSE**, create these objects inside that case:

| ID | Object/configuration |
|---|---|
| RI.PC.K1 / RI.PC.K2 | I32 0 /I32 1 (palette indices) |
| RI.PC.K3 | U32 256 |
| RI.PC.K4 / RI.PC.K5 | I32 6105 / String `Palette entries have equal brightness; cannot identify black.` |
| RI.PC.I1 / RI.PC.I2 | Index Array colors[0] /colors[1], U32 |
| RI.PC.Q1 / RI.PC.Q2 / RI.PC.Q3 | Three Quotient & Remainder U32 for color0's base256 bytes |
| RI.PC.Q4 / RI.PC.Q5 / RI.PC.Q6 | Three Quotient & Remainder U32 for color1's base256 bytes |
| RI.PC.A1 / RI.PC.A2 | Add U32 for color0 B+G then +R |
| RI.PC.A3 / RI.PC.A4 | Add U32 for color1 B+G then +R |
| RI.PC.C1 | Equal? brightness0==brightness1 |
| RI.PC.C2 | Less? brightness1<brightness0; TRUE means index1 is black |
| RI.PC.E1 | ErrorIf.vi |

All RGB extraction uses U32, so sums up to 765 cannot overflow a byte. The highest byte is ignored after three quotient/remainder stages.

| Scope | Every wire |
|---|---|
| RI.PC.FALSE indices | RI.PC.colors→RI.PC.I1.array,RI.PC.I2.array; RI.PC.K1→RI.PC.I1.index; RI.PC.K2→RI.PC.I2.index; RI.PC.I1.element→RI.PC.Q1.x; RI.PC.I2.element→RI.PC.Q4.x; RI.PC.K3→RI.PC.Q1.y,RI.PC.Q2.y,RI.PC.Q3.y,RI.PC.Q4.y,RI.PC.Q5.y,RI.PC.Q6.y |
| RI.PC.FALSE color0 | RI.PC.Q1.quotient→RI.PC.Q2.x; RI.PC.Q2.quotient→RI.PC.Q3.x; RI.PC.Q1.remainder→RI.PC.A1.x; RI.PC.Q2.remainder→RI.PC.A1.y; RI.PC.A1.out→RI.PC.A2.x; RI.PC.Q3.remainder→RI.PC.A2.y |
| RI.PC.FALSE color1 | RI.PC.Q4.quotient→RI.PC.Q5.x; RI.PC.Q5.quotient→RI.PC.Q6.x; RI.PC.Q4.remainder→RI.PC.A3.x; RI.PC.Q5.remainder→RI.PC.A3.y; RI.PC.A3.out→RI.PC.A4.x; RI.PC.Q6.remainder→RI.PC.A4.y |
| RI.PC.FALSE select/error | RI.PC.A2.out→RI.PC.C1.x,RI.PC.C2.y; RI.PC.A4.out→RI.PC.C1.y,RI.PC.C2.x; RI.PC.C1.out→RI.PC.E1.Condition; RI.PC.K4→RI.PC.E1.Code; RI.PC.K5→RI.PC.E1.Message; RI.PC.err→RI.PC.E1.error in; RI.PC.C2.out→RI.PC.blackBit; RI.PC.E1.error out→RI.PC.error out |

RI.PC.Q3.quotient and RI.PC.Q6.quotient are unused. `quotient` is the native terminal `floor(x/y)`; `remainder` is `x-y*floor(x/y)`. The darker palette entry is classified as black. Raw TRUE maps to entry1, so SELECT preserves the raw bitmap if blackBit TRUE; otherwise it negates the whole bitmap once.

For the empty/default palette case **RI.PC.TRUE**, create these objects inside that case:

| ID | Object/configuration |
|---|---|
| RI.PC.FK1 | Boolean constant labeled `DefaultPaletteCalibrated`, initial FALSE |
| RI.PC.FK2 | Boolean constant labeled `DefaultBlackBit`, initial TRUE; not used successfully until calibrated |
| RI.PC.FK3 / RI.PC.FK4 | I32 0 /I32 20 |
| RI.PC.FK5 | I32 6105 |
| RI.PC.FK6 | String constant `Default 1-bit palette needs calibration. Use Binairo_6x6.png and section 7.6. Raw black(0,0)=%d; raw white(20,20)=%d.` |
| RI.PC.FI1 / RI.PC.FI2 | Index Array 2D on raw, respective coordinates(0,0)/(20,20) |
| RI.PC.FB1 / RI.PC.FB2 | Boolean To (0,1), producing numeric0/1 |
| RI.PC.FT1 / RI.PC.FT2 | To Long Integer, convert numeric probe results to I32 |
| RI.PC.FM1 | Format Into String, format FK6, arguments probeBlack then probeWhite, initial string empty |
| RI.PC.FK7 | String constant empty |
| RI.PC.FN1 | NOT on DefaultPaletteCalibrated |
| RI.PC.FE1 | ErrorIf.vi |

| Scope | Every wire |
|---|---|
| RI.PC.TRUE probes | RI.PC.raw→RI.PC.FI1.array,RI.PC.FI2.array; RI.PC.FK3→RI.PC.FI1.index0,RI.PC.FI1.index1; RI.PC.FK4→RI.PC.FI2.index0,RI.PC.FI2.index1; RI.PC.FI1.element→RI.PC.FB1.Boolean; RI.PC.FI2.element→RI.PC.FB2.Boolean; RI.PC.FB1.out→RI.PC.FT1.x; RI.PC.FB2.out→RI.PC.FT2.x; RI.PC.FT1.out→RI.PC.FM1.input 1; RI.PC.FT2.out→RI.PC.FM1.input 2; RI.PC.FK6→RI.PC.FM1.format string; RI.PC.FK7→RI.PC.FM1.initial string |
| RI.PC.TRUE guarded mapping | RI.PC.FK1→RI.PC.FN1.x; RI.PC.FN1.out→RI.PC.FE1.Condition; RI.PC.FK5→RI.PC.FE1.Code; RI.PC.FM1.resulting string→RI.PC.FE1.Message; RI.PC.err→RI.PC.FM1.error in; RI.PC.FM1.error out→RI.PC.FE1.error in; RI.PC.FK2→RI.PC.blackBit; RI.PC.FE1.error out→RI.PC.error out |

The raw shape has already passed width/height>=32, so both probe coordinates are in range. They are **known-color calibration coordinates only for the specified 6x6 fixture**, not universal detectors. A default FALSE calibration flag causes a clear 6105 and empty production outputs; it never guesses silently.

### 7.6 Literal narrow default-palette calibration

This procedure is needed **only** if the error message exactly says “Default 1-bit palette needs calibration.” A valid two-entry returned palette requires no calibration changes.

1. Open `ReadImage.vi`. Set `PNG path` to the supplied **Binairo_6x6.png**; verify the basename exactly and use the preserved course copy. Set error in to no error. Run once.
2. Read the complete error-source text. The file's pixel(row0,col0) is on its black outer stroke; pixel(row20,col20) is white inside its top-left empty cell. The message prints both raw bits as0/1. Save a screenshot showing PNG path and the entire error text.
3. If it prints **black=1, white=0**, open the block diagram, display RI.PC.TRUE, leave `DefaultBlackBit` TRUE and set `DefaultPaletteCalibrated` TRUE. If it prints **black=0, white=1**, set `DefaultBlackBit` FALSE and `DefaultPaletteCalibrated` TRUE. These are the only two accepted branches. If both are equal, keep calibration FALSE, preserve the VI and return the screenshot/log for repair; do not choose an arbitrary mapping.
4. Save ReadImage.vi, then run the same 6x6 input again. Require clear error, Width 454, Height 431, Bitmap(row0,col0)=TRUE and Bitmap(row20,col20)=FALSE. Change the array display indices to these exact coordinates to inspect the values. If either expectation fails, reset `DefaultPaletteCalibrated` FALSE, save and return the evidence.
5. Run supplied 8x8; require Width 610, Height 577 and clear error. Check Bitmap(row5,col2)=TRUE on the border and Bitmap(row30,col30)=FALSE in the top-left empty cell. Then perform ComputeRowsCols's checkpoint. Keep the calibration screenshot with native evidence and note LabVIEW/OS version. Recalibrate after moving to a different LabVIEW/default-palette environment.

This is a finite verification of NI's default palette on the native computer. The group chooses no algorithm, thresholds or architecture. The initial package remains complete; the only conditional setup is explicitly bounded and verified. ReadImage calibration does not inspect or invent the MATLAB-launcher's separate connector.

### 7.7 Connect every nested output and finish

Each arrow below is a wire in the indicated enclosing No Error case. These are the five distinct output tunnels, not a cluster to be bundled.

| Scope | Every result wire |
|---|---|
| RI.S4.No Error | RI.S5.bitmap out→RI.S4.bitmap out; RI.S5.picture out→RI.S4.picture out; RI.S5.width out→RI.S4.width out; RI.S5.height out→RI.S4.height out; RI.S5.error out→RI.S4.error out |
| RI.S3.No Error | RI.S4.bitmap out→RI.S3.bitmap out; RI.S4.picture out→RI.S3.picture out; RI.S4.width out→RI.S3.width out; RI.S4.height out→RI.S3.height out; RI.S4.error out→RI.S3.error out |
| RI.S2.No Error | RI.S3.bitmap out→RI.S2.bitmap out; RI.S3.picture out→RI.S2.picture out; RI.S3.width out→RI.S2.width out; RI.S3.height out→RI.S2.height out; RI.S3.error out→RI.S2.error out |
| RI.S1.No Error | RI.S2.bitmap out→RI.S1.bitmap out; RI.S2.picture out→RI.S1.picture out; RI.S2.width out→RI.S1.width out; RI.S2.height out→RI.S1.height out; RI.S2.error out→RI.S1.error out |
| RI.S0.No Error | RI.S1.bitmap out→RI.S0.bitmap out; RI.S1.picture out→RI.S0.picture out; RI.S1.width out→RI.S0.width out; RI.S1.height out→RI.S0.height out; RI.S1.error out→RI.S0.error out |

No loops or shift registers occur in ReadImage. Save it and its defaults. Native checks: missing path, nonexistent file, non-PNG renamed .png, corrupt PNG, valid6x6/8x8, transparent margins and incoming seeded error. Failures must show a useful native/project error and all production outputs empty/zero. For valid images compare displayed picture, black/white polarity and reported dimensions before proceeding to the main guide's binary-writing section.

## 8. Native evidence and reviewed references

After all five VIs are constructed, return: the actual 5 VI files plus GridLines/RectI32 typedefs; front panels with the checkpoint values; block-diagram screenshots covering all Case frames and connector panes; exact native errors when any checkpoint differs; LabVIEW version and OS. A screenshot of a successful C command is not evidence of native image conversion or geometry. Keep originals separately and follow the one-writer-per-VI rule.

Assignment references use physical PDF pages: P00.PPI_Projet.2026.2.pdf pp24–27; Exo.Proj.Binairo.LabVIEW.1.pdf pp3–11,14–16. Current shape rule is even square grid count; a rectangular pixel image is allowed. Course diagrams are instructional illustrations; this text supplies the missing object/connection detail and still requires native execution.

Primary NI references checked for the stated primitives and terminal meanings:

- [Read PNG File](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/vi-lib/picture/png-llb/read-png-file-vi.html): path, image-data cluster, error terminals and U8 transparency threshold.
- [Draw Flattened Pixmap](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/vi-lib/picture/picture-llb/draw-flattened-pixmap-vi.html): picture input/output and original image-data/mask handling.
- [Picture to Pixmap](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/vi-lib/picture/pictutil-llb/picture-to-pixmap-vi.html): I32 depth, U32 background, native I16 rect and possible default/empty palette.
- [Unflatten Pixmap](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/vi-lib/picture/pixmap-llb/unflatten-pixmap-vi.html):1-bit Boolean output and mapping through colors[0]/colors[1]; use only the output for the requested depth.
- [Search 1D Array](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/functions/search-1d-array.html): `index of element` returns−1 on no match. In this guide `.array` means its `1D array` input and `.index` means that output.
- [Quotient & Remainder](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/functions/quotient-remainder.html): `.quotient` in tables means `floor(x/y)`; `.remainder` means `x-y*floor(x/y)`.
- [Transpose 2D Array](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/functions/transpose-2d-array.html) and [Or Array Elements](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/functions/or-array-elements.html): native row/column occupancy construction.
- [Format Into String](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/functions/format-into-string.html) and [Boolean To (0,1)](https://www.ni.com/docs/en-US/bundle/labview-api-ref/page/functions/boolean-to-0-1.html): diagnostic formatting, propagated format error and explicit I16-to-I32 probe conversions.

No native execution is claimed by citing API documentation. If a documented primitive's actual Context Help shows an unexpected incompatible terminal/type, preserve a screenshot of the exact VI/path and report it; do not attach a different type by coercion or add a guessed terminal.

## 9. Completed source/wiring self-review and remaining native boundary

The authored recipe was checked for the following consistency points: all five connector maps agree with their front-panel directions/types; every Case output is assigned in every frame; invalid indices are gated before cell-coordinate access; every error output reaches the caller; the only SR is GC.F3's initialized error SR; every other loop has explicit bounds/indexing and no retained state; BlackRuns includes the final padded comparison and correctly returns exclusive right-edge endpoints; bitmap dimensions remain row/column while C serialization is separately width/height; project rectangle fields are I32 and native picture fields remain I16; conversion VIs have no invented error terminals; Format Into String's actual error terminals are chained in the fallback; palette normalization is applied once, only after shape/depth/palette validation. CR.N2.quotient and GC.N5.quotient are explicitly unused, as are the already listed extra native-picture outputs.

This is **author self-review of a construction recipe**, not an independent executed-VI review. Native primitive placement, saved typedef linkage, all diagram wires, default-palette calibration where needed, alpha-mask appearance and checkpoint results remain for the group's construction/testing evidence. No source or method is outsourced; no native success is asserted prematurely.
