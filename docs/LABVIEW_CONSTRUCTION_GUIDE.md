# Complete LabVIEW construction recipe - first delivery

**Read together with LABVIEW_GEOMETRY_GUIDE.md, which is the numbered geometry chapter of this recipe.** The HTML edition combines both into one readable document. This guide describes how to build real VIs; it is not an executable VI or evidence of native execution. Provisional environment: English desktop LabVIEW on Windows; native macOS alternative commands are given. The course's current main connector is missing. All project connectors below are our explicit provisional design. The supplied launcher is included unchanged; only its actual connector requires the narrow later inspection in chapter12.

## 1. First step: prepare the project and create the empty LabVIEW project

1. Extract the complete first-delivery archive into a writable folder on the teammate computer. Keep the directory tree intact. Do not use a Mac executable on Windows. Follow C_OPERATOR_GUIDE.md through its successful build and `python tools/prepare_runtime.py` step. Follow MATLAB_OPERATOR_GUIDE.md when MATLAB is available; first delivery does not assert these native tests have happened.
2. Open LabVIEW manually. Choose File > Create Project > Blank Project (or File > New Project if that is the installed equivalent). Save the project as `labview/Binairo2026.lvproj` inside this package. Use My Computer for all VIs, not a real-time target.
3. Read state/VI_OWNERSHIP.md: one builder edits the VIs. Build source VIs in labview/. Before running the pipeline, use the assembly helper to copy them into runtime/, where all runtime files are co-located. Close VIs before copying to avoid editing mixed versions. After any runtime-side repair, explicitly save the authoritative changed file back into labview/ before committing.
4. Create File > New VI and immediately save as `labview/ErrorIf.vi`. Complete chapter3, then build each named subVI in chapter order. The main VI is built last. Do not build from the old Billard connector.

## 2. Common exact conventions for every table

1. **Object identity.** Each table's ID is a free label you add beside that object (double-click empty diagram area and type the ID). `P.` identifies a front-panel terminal. `C.` identifies a block-diagram constant. `N.` identifies a node. `S.` identifies a structure. IDs are scoped to that VI, so `N1` in ReadText.vi is a different object from `N1` in WriteCell.vi. Table rows instantiate exactly one object unless an indexed finite set is explicitly enumerated. Do not create extra implicit arithmetic nodes.
2. **Placement/search.** Front panel: right-click empty area, Controls palette Search, enter the exact control type in the table, select the standard control/indicator. Diagram: Ctrl+Space (Quick Drop), type the exact node name, select the matching LabVIEW built-in, Enter and click to place. Course-confirmed image palette routes: Programming > Graphics & Sound > Graphics Formats for Read PNG File/Unflatten Pixmap; Programming > Graphics & Sound > Picture Functions for Draw Flattened Pixmap/Picture to Pixmap. Built-in file nodes are Programming > File I/O. When an English search returns multiple items, use Context Help to choose the named terminals/types stated here. A toolkit/IMAQ equivalent is not intended.
3. **Terminals.** Ctrl+H opens Context Help. Hover the node, then hover each terminal; its label and data type identify it. Right-click the node > Visible Items > Terminals where available. Our wire tables use terminal names, not icon corner guesses. Expand growable nodes by dragging their lower edge to the exact number of inputs stated. All listed source→destination wires are required. Branch an existing source wire when it feeds several destinations. Listed but unused OUTPUTS stay unconnected; unused INPUTS are stated explicitly with their default below. Do not guess terminals of the supplied MATLAB-launch VI.
4. **Representations.** Numeric controls/constants: right-click > Representation > I32, U32, U8 or DBL exactly as listed. I32 means signed32, U32 unsigned32, U8 unsigned8, DBL floating64. Set displayed numeric constants to decimal unless `0x` says hexadecimal (right-click radix > Hex). Booleans are switches for controls, LEDs for indicators; defaults FALSE unless specified TRUE. Arrays: place Array shell, drop the element control inside, then right-click index display > Add Dimension until dimensions match. Arrays are initially empty, not one zero element. For 2D Boolean arrays, the first index is row and second is column.
5. **Clusters.** Error cluster is the standard Error In/Out control, order status(Boolean), code(I32), source(String). GridLines cluster is project-owned order xStart[],xEnd[],yStart[],yEnd[], all1D I32. CellRect cluster is project-owned order left,top,right,bottom, allI32. Set cluster order via right-click border > Reorder Controls in Cluster. **Native picture rectangle fields are I16; do not reuse CellRect for native picture terminals.** Create native cluster types from their actual terminals.
6. **Connector panes.** For project subVIs choose the pattern with four terminals down each side and two across each top/bottom edge (12 total, commonly labelled4x2x2x4). Right-click icon > Show Connector, Patterns, select by geometry. Label positions on your paper L1..L4 top-to-bottom left; R1..R4 top-to-bottom right; T1,T2 left-to-right top; B1,B2 left-to-right bottom. Click a terminal then its front-panel object. All assigned data inputs required; error input recommended. Every unassigned terminal remains UNASSIGNED. Connector tables below and in geometry chapter fully enumerate assigned terminals. This is not an official current course connector.
7. **Cases.** A standard guard `S0` is a Case Structure selected by error-in.status. It has FALSE (no existing error) and TRUE (existing error). Each subVI table explicitly describes both branches. No side-effect node goes outside FALSE unless stated. Every output tunnel is wired in BOTH cases; do not select Use Default If Unwired. Scalar pure computations may execute before a guard, but indexing/division/open/run operations belong after input validation.
8. **Loops.** For Loops use default I32 iteration i starting0. N equals stated count. Auto-indexing is enabled only where stated; nonindexing tunnels are solid squares. Shift registers are initialized by the specified wire OUTSIDE their loop. Never use uninitialized registers. Every branch wires right registers. Stop early is only enabled where stated. UI runs once when the Run arrow is clicked; do not add an infinite outer loop.
9. **Primitive terminal aliases/defaults.** In these tables argument0/input0 means the first growable input, which NI may label input1; argument1 means the second. Format Into String initial string is explicitly empty at every call (wire a String constant labelled with the node ID plus `.Empty`); Search and Replace regex mode is OFF unless explicitly stated; all output offsets/counts not named are unused. Error outputs from formatting/regex nodes must flow along the listed error chain. For Open/Create/Replace File the optional advisory input is left at its documented default FALSE; do not add a speculative terminal.
10. **Defaults/description.** After finishing a VI, set stated control defaults, Edit > Make Current Values Default, save. File > VI Properties > Documentation: paste its purpose paragraph and reference this guide section; add actual builder name and date (never invent authors). Confirm Run arrow is unbroken. If broken, click it, save full Error List text/screenshot and the relevant objectIDs/Context Help. Never hide broken wires or insert arbitrary coercions.

## 3. ErrorIf.vi - explicit error creation and preservation

Purpose: preserve a prior error; otherwise create one only if Condition is TRUE. Error codes in this guide are project-defined7001..7099 and are not official NI/course codes.

Panel/connector: P1 Condition Boolean control FALSE=L1; P2 Code I32 control7001=L2; P3 Message String control empty=L3; P4 error in standard cluster=L4; P5 error out indicator=R4. R1,R2,R3,T1,T2,B1,B2 unassigned.

Diagram objects: C1 Boolean TRUE; N1 Unbundle By Name(status) from error cluster; N2 Bundle (3 inputs status/code/source, creates standard error cluster); N3 Select; N4 Select. No loops/cases.

| Source terminal | Destination terminal |
|---|---|
| P4.value | N1.cluster |
| C1.value | N2.element0 status |
| P2.value | N2.element1 code |
| P3.value | N2.element2 source |
| P1.value | N3.s selector |
| N2.cluster | N3.t |
| P4.value | N3.f |
| N1.status | N4.s |
| P4.value | N4.t |
| N3.output | N4.f |
| N4.output | P5.value |

Checkpoint: FALSE with no prior error passes unchanged; TRUE produces supplied code/message; existing error remains even if TRUE asks for a different error.

## 4. ReadText.vi and WriteText.vi - complete disk wrappers

These are two separate VIs with explicit variations below. Use Open/Create/Replace File, Read from Text File / Write to Text File, Close File, Merge Errors, Unbundle By Name, Case Structure and the controls named. No dialog path defaults are allowed at runtime.

### 4.1 ReadText.vi

Panel/connector: P1 File Path control (empty)=L1; P2 error in=L4; P3 Text String indicator=R1; P4 error out=R4; others unassigned. Constants C1 I32(-1), C2 String empty, C3 no-error cluster(False,0,empty). N1 Unbundle(status), S0 Case, N2 Open/Create/Replace File, N3 Unbundle(status), S1 Case, N4 Read from Text File, N5 Close File, N6 Merge Errors(2inputs). On N2 create constants FROM terminals: operation=`open`, access=`read-only`, deny mode=`deny write`. Leave the documented advisory input at FALSE (default); all path/access/operation/deny inputs are explicitly set. No file dialogue because P1 wired.

Wires: P2→N1.cluster; N1.status→S0.selector. In S0 TRUE: C2→P3 output tunnel; P2→P4 output tunnel. In S0 FALSE: P1→N2.file path; P2→N2.error in; N2.error out→N3.cluster; N3.status→S1.selector. S1 TRUE (open failed): C2→text output; N2.error out→error output. S1 FALSE: N2.refnum→N4.file; C1→N4.count; N2.error out→N4.error in; N4.text→text output; N2.refnum→N5.refnum; N4.error out→N6.error0; C3→N5.error in; N5.error out→N6.error1; N6.error out→error output. **Sequence close after read:** add Flat Sequence `S2` inside S1 FALSE, frame0 contains N4, frame1 contains N5/N6; pass refnum/text/readerror through nonindexing sequence tunnels. This allows close with a clean input even after read failure. S1 outputs→S0 outputs→P3/P4. Set Read from Text File right-click Convert EOL OFF, Read Lines OFF. Read returns raw full file; parser explicitly accepts LF/CRLF. All unused outputs (cancelled etc.) unconnected.

### 4.2 WriteText.vi

Panel/connector P1 File Path=L1; P2 Text String control=L2; P3 error in=L4; P4 error out=R4; othersunassigned. C1 no-error cluster. N1 Unbundle(status); S0 Case; N2 Open/Create/Replace File(operation=`replace or create`, access=`write-only`, deny=`deny read/write`); N3 Unbundle(status); S1 Case; S2 Flat Sequence2frames; N4 Write to Text File; N5 Close File; N6 Merge Errors2inputs.

Wires: P3→N1.cluster→S0.selector(status). S0 TRUE: P3→P4. S0 FALSE: P1→N2.file path; P3→N2.error in; N2.error out→N3.cluster→S1.selector(status). S1 TRUE: N2.error out→error output. S1 FALSE frame0: N2.refnum→N4.file; P2→N4.text; N2.error out→N4.error in. Frame1: N2.refnum→N5.refnum; C1→N5.error in; N4.error out→N6.error0; N5.error out→N6.error1; N6.error out→S1error output→S0error output→P4. Set Write to Text File right-click Convert EOL OFF. No newline added by wrapper; callers supply exact LF. N4 refnum out can remain unconnected because N2refnum is passed through sequence frame. Close always occurs after any attempted write when open succeeded. Unused outputs unconnected.

### 4.3 RemoveIfExists.vi

Purpose: remove only a known generated file if present; preserve unexpected directories and propagate permission errors. Panel P1 File Path=L1, P2 error in=L4, P3 error out=R4; other slots unassigned. Diagram objects: N1 Unbundle(status), S0 error Case, N2 Check if File or Folder Exists, S1 exists Case, N3 File/Directory Info, N4 ErrorIf, N5 Unbundle(status), S2 error Case, N6 Delete; constants C1 I32(7002), C2 String`Generated-file path is a folder; choose a clean runtime directory.`, C3 BooleanFALSE. P1 must be the nonempty generated path produced by Build Path at each caller; this helper is not a general-purpose deletion UI.

Wires: P2→N1.cluster; N1.status→S0.selector. S0 TRUE:P2→erroroutput. S0 FALSE:P1→N2.path;P2→N2.error in;N2.file or folder exists?→S1.selector. S1 FALSE:N2.error out→erroroutput. S1 TRUE:P1→N3.path;N2.error out→N3.error in;N3.directory→N4.Condition;C1→N4.Code;C2→N4.Message;N3.error out→N4.error in;N4.error out→N5.cluster;N5.status→S2.selector. S2 TRUE:N4.error out→erroroutput. S2 FALSE:P1→N6.path;N4.error out→N6.error in;C3→N6.recursive?;N6.error out→erroroutput. All S2/S1/S0 output tunnels wired through toP3; no defaults. Exists duplicate path and Info size/timestamps/resolved-path outputs are unused. NI's Exists VI does **not** have a directory output: that is why N3 is separate. Delete never executes for a directory or after an earlier error.

## 5. Native image, bounds, grid and crop geometry

Complete the entire **LABVIEW_GEOMETRY_GUIDE.md** now. It specifies the image chain, GridLines typedef/cluster, edge-safe transition loops and ComputeRowsCols/ComputeCellRect. Then return here. Expected6x6 first interior: left6,top6,right78,bottom74 ->72x68. The fourth supplied image has a white margin and unequal row/column counts; absolute image row10 is not a valid scan line. Grid strokes are measured; no fixed cell size is hardcoded.

## 6. WriteCell.vi - exact header and row-major pixels

Panel/connector: P1 Cell Boolean2D control=L1; P2 File Path control=L2; P3 error in=L4; P4 error out=R4. All other connector terminals unassigned. Cell is already cropped by Array Subset in ReadCase. Image dimensions come from its array shape.

Objects: C1 I32(0); C2 I32(1); C3 I32(10); C4 I32(256); C5 U8(0); C6 U8(1); C7 BooleanFALSE (prepend); C8 noerrorcluster; N1 Unbundle(status); S0 errorCase; N2 Array Size; N3 Index Array expanded2outputs indexes0,1; N4 To Unsigned Long Integer(height); N5 To Unsigned Long Integer(width); N6 Build Array2scalarinputs; N7 In Range and Coerce(height); N8 In Range and Coerce(width); N9 AND; N10 NOT; N11 ErrorIf; C9 code7003; C10 String`Cell dimensions outside10..256.`; N12 Unbundle(status); S1 errorCase; N13 Open/Create/Replace File(replace or create,write-only,deny read/write); N14 Unbundle(status); S2 errorCase; S3 outer For; S4 inner For; N15 Select; N16 Reshape Array; N17 Multiply; N18 Write to Binary File(header); N19 Write to Binary File(pixels); N20 Close File; N21 Merge Errors2inputs; S5 FlatSequence2frames. Byte order constants for N18/N19 created from terminal and set **little-endian enum2**, never native/default. N7/N8 Include upper limit TRUE, Include lower limitTRUE.

Wires before S1: P3→N1.cluster;N1.status→S0.selector. S0 TRUE:P3→P4. FALSE:P1→N2.array;N2.sizes→N3.array; C1→N3.index0;C2→N3.index1;N3.element0(height)→N4.x and N7.x and N17.x;N3.element1(width)→N5.x and N8.x and N17.y;C3→N7.lower/N8.lower;C4→N7.upper/N8.upper;N7.in range?→N9.x;N8.in range?→N9.y;N9.output→N10.x;N10.output→N11.Condition;C9→N11.Code;C10→N11.Message;P3→N11.error in;N11.error out→N12.cluster;N12.status→S1.selector. S1 TRUE:N11.error out→output. S1 FALSE proceeds below.

Header wires: N5.widthU32→N6.input0;N4.heightU32→N6.input1. Build Array concatenate inputs OFF creates1D U32[2] EXACTLY width,height.

Pixel conversion wires: P1→S3 left auto-index tunnel (inside isBoolean1D row). S3.N unwired (auto-index controls length). That row→S4 left auto-index tunnel (inside Boolean scalar). S4.N unwired. Inner Boolean→N15.s;C6→N15.t;C5→N15.f;N15.output→S4 right auto-index tunnel(U8row);S4 U8row→S3 right auto-index tunnel(U8matrix). S3matrix→N16.array;N17.product→N16.dimension size0. Leave only ONE dimension input on Reshape Array; output is row-major1D U8. No shift registers in these conversion loops. Their zero-size possibilities are prevented by dimension guards.

File wires: P2→N13.path;N11.error out→N13.error in;N13.error out→N14.cluster;N14.status→S2.selector. S2 TRUE:N13.error out→erroroutput. S2 FALSE contains S5. Frame0:N13.refnum→N18.file;N6.array→N18.data;C7→N18.prepend;little-endian2→N18.byte order;N13.error out→N18.error in;N18.refnum out→N19.file;N16.array→N19.data;C7→N19.prepend;little-endian2→N19.byte order;N18.error out→N19.error in. Frame1:N13.refnum→N20.refnum;C8→N20.error in;N19.error out→N21.error0;N20.error out→N21.error1;N21.error out→S2→S1→S0→P4. Sequence frame1 cannot start before both writes finish. Header/pixel writes share the SAME refnum so the second write appends at position8. Passing the path again would overwrite the header and is wrong.

Checkpoint: create a development test VI with Boolean2D40columns×35rows, allFALSE except oneTRUE at row2,col9. WriteCell must create1408bytes: header `28 00 00 00 23 00 00 00`, byte offset8+2*40+9=97 is1, all other payload bytes0. Use the binary inspection helper in chapter14; this test catches width/height swap and column-major flattening. It is intentionally non-square.

## 7. BuildOCRCommand.vi - thresholds and host quoting

Panel/connector: P1 Runtime Path=L1; P2 Thresholds cluster(control; order empty,zero,one allDBL defaults98,90,90)=L2; P3 Windows? Boolean controlTRUE=L3; P4 error in=L4; P5 Command String indicator=R1; P6 error out=R4; all other slots unassigned. Runtime is derived by main; OCR input is always runtime/Cell.bin. Provisional command-path policy: only runtime/executable paths containing letters, digits, spaces, slash, backslash, colon, dot, underscore and hyphen are accepted on Windows. Select a simple writable project location. This avoids shell expansion, including percent/exclamation/ampersand. A source image filename can contain an apostrophe because it is read natively and escaped for MATLAB, never passed to OCR's shell. POSIX runtime paths are single-quote escaped as below.

Diagram: C1 String`OCR.exe`;C2 String`OCR`;C3 String`Cell.bin`; C4 I32(0);C5 DBL(0);C6 DBL(100);C7 code7004;C8 message`Invalid OCR thresholds or command path; thresholds must have at most four decimal places.`;C9 emptyString;N1 Unbundle status;S0 guard;N2 Unbundle By Name3fields(thresholds);N3 In Range(empty),N4 In Range(zero),N5 In Range(one), include both boundsTRUE;N6 Compound Arithmetic AND6inputs;N7 Select(executablebasename);N8 Build Path(exe);N9 Build Path(cell);N10 Path To String(exe);N11 Path To String(cell);S1 WindowsCase;N12 ErrorIf;N13 Unbundle(status);S2 guard;N14 Format Into String. Instantiate N12/N13/S2/N14 separately inside each host case, with suffix .WIN or .POSIX; the common wiring paragraph below applies to exactly these two explicitly enumerated copies.

Wires common: P4→N1.cluster→S0.selector(status). S0 TRUE:C9→P5,P4→P6. S0 FALSE:P2→N2.cluster;N2.empty→N3.x;N2.zero→N4.x;N2.one→N5.x;C5→N3/N4/N5.lower;C6→N3/N4/N5.upper;N3/N4/N5.in range?→N6.inputs0/1/2. NaN is outside ranges. P3→N7.s;C1→N7.t;C2→N7.f;P1→N8.base/N9.base;N7.output→N8.name;C3→N9.name;N8.path→N10.path;N9.path→N11.path;P3→S1.selector.

Before hostCase S1 inside S0 FALSE, add the following exact precision validation. The LabVIEW UI accepts only thresholds representable by a decimal string with at most4 places; C itself still accepts its documented decimal grammar. Set all threshold control displays to fixed-point4 decimal places, but do not rely on display rounding to validate the stored value. Add QF1,QF2,QF3 Format Into String (one DBL argument each), QP1,QP2,QP3 Fract/Exp String To Number(default DBL0,use system decimal point FALSE,offsetI32zero), QE1,QE2,QE3 Equal?DBL. Constants QK1String`%.;%.4f`,QK2I32zero,QK3DBLzero,QK4BooleanFALSE. Exact finite fields j=1,2,3 correspond to N2.empty,N2.zero,N2.one, respectively. For each of these three field/node pairs: field→QFj.argument0 and QEj.x;QK1→QFj.format;QFj.result→QPj.string;QK2→QPj.offset;QK3→QPj.default;QK4→QPj.use system decimal point?;QPj.number→QEj.y. QE1.result→N6.input3;QE2.result→N6.input4;QE3.result→N6.input5. Format error chain: P4→QF1.error in;QF1out→QF2in;QF2out→QF3in. QF3.error out is the host branch's prior error (explicit wires below). The formatted roundtrip must equal the original DBL exactly; e.g.98,90.1250 pass and99.99999 fails7004 instead of silently becoming100.0000. Empty initial strings follow chapter2 convention.

S1 TRUE objects W1 Match Regular Expression, W2 Equal?, W3 String Length, W4 AND, W5 NOT, W6 String constant`^[A-Za-z0-9 _.:/\\-]+$`;W7 BooleanFALSE for multiline/ignorecase;W8 I32zero. N11.cellPath→W1.input;W6→W1.regex;W8→W1.offset;W7→W1.multiline?/ignore case?;QF3.error out→W1.error in;W1.offset past match→W2.x;N11.cellPath→W3.string;W3.length→W2.y;N6.output→W4.x;W2.output→W4.y;W4.output→W5.input;W5.output→N12.Condition;W1.error out→N12.error in. This path check covers runtime because fixed suffix is appended. W9 format string in **normal display**: `%s` is not used here for locale; use the literal file `ocr_windows_format.txt` below. N10.exePath→N14.argument0;N11.cellPath→N14.argument1;N2.empty/zero/one→N14.arguments2/3/4. Format string contains `%.;` to force decimal point (NI numeric-format syntax), as supplied in resources. W9→N14.format string.

S1 FALSE objects U1 Search and Replace String (replace all TRUE, regex mode OFF), U2 identical;Cq String single apostrophe;Cqq String **`'"'"'`** (five characters apostrophe,doublequote,apostrophe,doublequote,apostrophe);U3 NOT;U4 format string from ocr_posix_format.txt. N10.string→U1.input;N11.string→U2.input;Cq→U1/U2.search;Cqq→U1/U2.replace;BooleanTRUE→U1/U2.replace all?;I32zero→U1/U2.offset. N6.output→U3.input;U3.output→N12.Condition;QF3.error out→N12.error in;U1.result→N14.arg0;U2.result→N14.arg1;N2.empty/zero/one→N14.args2/3/4;U4→N14.format string.

Both host cases: C7→N12.Code;C8→N12.Message;N12.error out→N13.cluster→S2.selector(status). S2 TRUE:C9→commandoutput;N12.error out→erroroutput. S2 FALSE:N12.error out→N14.error in;N14.result→commandoutput;N14.error out→erroroutput. S2→S1→S0→P5/P6. All Format Into String optional initial-string input empty; unused outputsunconnected. The three numeric parameters must remain decimals with a dot on French-locale systems; checkpoint prints expected strings before running anything.

Copy formats from resources/ into block diagram NORMAL-display string constants (do not interpret backslash escapes when pasting). Remove only the file's final LF; no command newline required:

```text
Windows: %.;cmd /d /s /c ""%s" "%s" %.4f %.4f %.4f"
POSIX:   %.;'%s' '%s' %.4f %.4f %.4f
```

`%.;` is LabVIEW's decimal-separator directive; it is consumed by Format Into String, not passed to C. Expected Windows result for a manual test directory: `cmd /d /s /c ""C:\Binairo Test\OCR.exe" "C:\Binairo Test\Cell.bin" 98.0000 90.0000 90.0000"`. Native System Exec must be tested on the actual OS; do not infer Windows behavior from a Mac run.

## 8. ParseCellValue.vi - strict one-line grammar

Panel/connector: P1 Text String control=L1;P2 error in=L4;P3 MATLAB Token String indicator=R1;P4 Percent DBL indicator=R2;P5 error out=R4;other slotsunassigned.

Objects C1 emptyString,C2 DBL0,C3 I32zero,C4 code7005,C5 message`Malformed CellValue.txt; inspect raw text and OCR logs.`;C6 regex string from resources/cellvalue_regex.txt;C7 BooleanFALSE. N1 Unbundle(status);S0 guard;N2 Match Regular Expression(expand2submatches);N3 String Length;N4 Equal?;N5 NOT;N6 ErrorIf;N7 Unbundle(status);S1 guard;N8 Fract/Exp String To Number(DBL default0;use system decimal point FALSE);N9 In Range and Coerce(include bothTRUE,lower0,upper100);N10 NOT;N11 ErrorIf;N12 Unbundle(status);S2 guard;S3 Case selected by symbolString. Normal-display regex is:

```text
^d:'([01 ])',([0-9]{1,3}\.[0-9]{4})%\r?\n$
```

Wire P2→N1.cluster→S0.selector. S0TRUE:C1→P3,C2→P4,P2→P5. S0FALSE:P1→N2.input;C6→N2.regex;C3→N2.offset;C7→N2.multiline?/ignorecase?;P2→N2.error in;P1→N3.string;N2.offset past match→N4.x;N3.length→N4.y;N4.output→N5.input;N5.output→N6.Condition;C4→N6.Code;C5→N6.Message;N2.error out→N6.error in. N6.error out→N7.cluster→S1.selector. TRUE returns emptyToken,0,N6error. FALSE:N2.submatch2(percent chars)→N8.string;C3→N8.offset;C2→N8.default;C7→N8.use system decimal point?;N8.number→N9.x;DBL0→N9.lower;DBL100→N9.upper;N9.in range?→N10.input;N10.output→N11.Condition;C4→N11.Code;C5→N11.Message;N6.error out→N11.error in;N11.error out→N12.cluster→S2.selector. S2TRUE returns empty,0,error. S2FALSE:N2.submatch1→S3.selector; S3 case`0` creates String`0`;case`1` creates String`1`;case` ` (one space) creates String`NaN`;DEFAULT contains N13D ErrorIf.vi and C8D BooleanTRUE: C1→DEFAULT tokenoutput; C2→DEFAULT percentoutput; C8D→N13D.Condition; C4→N13D.Code; C5→N13D.Message; N11.error out→N13D.error in; N13D.error out→DEFAULT erroroutput. Nondefault S3cases outputtheir token,N8.number,N11error. Connect through S2/S1/S0 toP3/P4/P5. Regex check ensures source contains exactlyone matchedline and no suffix; an empty no-match offset-1 cannot equal nonnegative inputlength. All unused regex outputsunconnected. If a node calls the second submatch `substring2`, Context Help distinguishes it from `whole match`.

Checkpoint panel test strings (set string display to backslash to enter LF then back to normal): `d:' ',100.0000%\n`→NaN; `d:'0',93.7500%\n`→0; `d:'1',90.0000%\r\n`→1. Missing newline, 101.0000, symbol2, comma decimal, extra newline or garbage→7005. No malformed input silently becomesNaN.

## 9. ReadCase.vi - crop, write, execute, parse

Panel/connector: P1 Bitmap Boolean2D=L1;P2 GridLines cluster=L2;P3 CellIndex cluster(order rowI32,colI32;0,0)=L3;P4 error in=L4;P5 Runtime Path=T1;P6 Thresholds cluster=T2;P7 Windows?TRUE=B1;P8 Token String indicator=R1;P9 Percent DBL indicator=R2;P10 Diagnostics String indicator=R3;P11 error out=R4;B2unassigned.

Objects:N1 Unbundle(status);S0guard;N2 Unbundle By Name(row,col);N3 ComputeCellRect.vi;N4 UnbundleByName(left,top,right,bottom);N5 Subtract(width);N6 Subtract(height);N7 Array Subset(2D);N8 BuildPath(Cell.bin);N9 WriteCell.vi;N10 BuildOCRCommand.vi;N11 System Exec.vi;N12 NotEqual?returncode0;N13 StringLength(stderr);N14 Greater?0;N15 OR;N16 Format Into String diagnostics;N17 ErrorIf;N18 BuildPath(CellValue.txt);N19 ReadText.vi;N20 ParseCellValue.vi;N22 Merge Errors2inputs;N23 RemoveIfExists.vi (insideS1FALSE). Constants: C1 StringCell.bin;C2 StringCellValue.txt;C3 I32zero;C4 BooleanTRUE;C5 emptyString;C6 DBLzero;C7 code7006;C8 U32(65536);C10 no-error cluster(FALSE,0,empty);C9 format`Return code: %d\nstdout:\n%s\nstderr:\n%s\n` entered with backslash-display enabled so actualLFs;N21 Unbundle(status);S1guard.

S0guard: P4→N1.cluster→S0.selector;TRUE outputs emptyToken,0,emptyDiagnostics,P4error. FALSE wires: P3→N2.cluster;P2→N3.GridLines;N2.row→N3.row;N2.col→N3.col;P4→N3.error in;N3.Rect→N4.cluster;N4.right→N5.x;N4.left→N5.y;N4.bottom→N6.x;N4.top→N6.y;P1→N7.array;N4.top→N7.indexrow;N6.output→N7.lengthrow;N4.left→N7.indexcol;N5.output→N7.lengthcol. N3error→N21cluster→S1selector;S1TRUE outputsdefaults,N3error. S1FALSE:P5→N8.base/N18.base;C1→N8.name;C2→N18.name;N7.subarray→N9.Cell;N8.path→N9.File;N18.path→N23.File;N3.error out→N23.error in;N23.error out→N9.error in;P5→N10.Runtime;P6→N10.Thresholds;P7→N10.Windows?;N9.error out→N10.error in. N10.Command→N11.command line;P5→N11.working directory;C4→N11.wait until completion?;C4→N11.run minimized?;C8→N11.expected output size;C5→N11.standard input;N10.error out→N11.error in.

Process status: N11.return code→N12.x and N16.arg0;C3→N12.y;N11.standard error→N13.string and N16.arg2;N11.standard output→N16.arg1;N13.length→N14.x;C3→N14.y;N12.result→N15.x;N14.result→N15.y;N15.result→N17.Condition;C7→N17.Code;C9→N16.format;N16.result→N17.Message and Diagnosticsoutput;C10→N16.error in;N11.error out→N22.error0;N16.error out→N22.error1;N22.error out→N17.error in. N18.path→N19.File;N17.error out→N19.error in;N19.Text→N20.Text;N19.error out→N20.error in;N20.Token→tokenoutput;N20.Percent→percentoutput;N20.error out→erroroutput. ThroughS1/S0→P8/P9/P10/P11. Diagnostics are formatted with the explicitly wired C10 clean error; N22 preserves both process and formatting errors. N23 removes the previous cell result on EVERY cell before writing/launching, so a zero-exit executable producing no file cannot reuse the preceding cell’s value.

The WriteCell/command/SystemExec/read/parse error chain prevents reading a stale file. C also removes its old result. For each iteration preserve diagnostic indicator even on failure. Pure ArraySubset can compute beforeS1 guard, but WriteCell only sees it after validated rectangle and clearerror. No subprocess is launched for an invalid rectangle.

## 10. BuildML.vi - actual script generated from OCR results

Panel/connector P1 MatrixText String=L1;P2 Source PNG Path=L2;P3 Options cluster(order solveWithMatlabTRUE,showPDFTRUE)=L3;P4 error in=L4;P5 Runtime Path=T1;P6 Script Path indicator=R1;P7 Script Text indicator=R2;P8 error out=R4;R3,T2,B1,B2unassigned.

N1 Unbundle(status),S0guard;N2 BuildPath(solve_template.txt);N3 ReadText.vi;N4 Unbundle(options);N5 Select(String1/0 solve);N6 Select(String1/0 show);N7 PathToString(source);N8 SearchAndReplaceString(apostrophe doubling);N9 Replace(matrixmarker);N10 Replace(solvemarker);N11 Replace(showmarker);N12 Replace(sourcemarker LAST);N13 BuildPath(solve.m);N14 WriteText.vi. Each replace is native Search and Replace String, replaceallTRUE, offsetI32zero, regular-expression modeOFF. Its literal backslashes are not regex escapes. Constants names/values: C1`solve_template.txt`;C2`solve.m`;C3`1`;C4`0`;C5`'`;C6`''`;C7`@MATRIX@`;C8`@SOLVE@`;C9`@SHOW@`;C10`@SOURCE@`;C11 emptyString;C12 emptyPath;C13TRUE;C14I32zero.

P4→N1cluster→S0selector;TRUE outputs emptyPath,emptyString,P4error. FALSE:P5→N2.base/N13.base;C1→N2.name;C2→N13.name;N2.path→N3.File;P4→N3.error in;P3→N4.cluster;N4.solve→N5.s;C3→N5.t;C4→N5.f;N4.show→N6.s;C3→N6.t;C4→N6.f;P2→N7.path;N7.string→N8.input;C5→N8.search;C6→N8.replace. N3.Text→N9.input;C7→N9.search;P1→N9.replace;N9.result→N10.input;C8→N10.search;N5.output→N10.replace;N10.result→N11.input;C9→N11.search;N6.output→N11.replace;N11.result→N12.input;C10→N12.search;N8.result→N12.replace. C13→N8/N9/N10/N11/N12.replaceall;C14→allfive.offset. N13.path→N14.File and ScriptPathoutput;N12.result→N14.Text and ScriptTextoutput;N3.error out→N14.error in;N14.error out→outputerror. S0outputs→P6/P7/P8. All unused replacement offset/count outputsunconnected. Validate inputsource noLF/CR/NUL in main sourceguard; filenames containing marker-looking text remain literal because source is substituted last. No unresolved marker string is allowed except inside the literal source filename.

Checkpoint: inspect saved solve.m using a text editor. It must show a matrix from current OCR, row delimiters `;` plusLF, blankcells`NaN`, escaped source apostrophes as`''`, logical(1/0) flags and RunBinairo call. Exact skeleton is resources/solve_template.txt; copying sample_driver.m instead fails the assessed generation requirement.

## 11. CheckMatlabStatus.vi - completion cannot be inferred from a PDF alone

Panel/connector P1 Runtime Path=L1;P2 Launch Diagnostics String=L2;P3 error in=L4;P4 Status String indicator=R1;P5 error out=R4;other slotsunassigned. Objects C1`MatlabStatus.txt`;C2`MatlabError.txt`;C3emptyString;C4String`OK\n`;C5String`UNSOLVABLE\n`;C6code7007;N1Unbundle(status);S0guard;N2BuildPath(status);N3ReadText;S1Case on raw text;N4ErrorIf;N5BuildPath(error);N6ReadText;N7ConcatenateStrings3inputs. C4/C5 entered in backslash display with actual LF.

P3→N1cluster→S0selector. S0TRUE:P2diagnostics→P4Status;P3→P5error (never read old status). FALSE:P1→N2base/N5base;C1→N2name;C2→N5name;N2path→N3File;P3→N3errorin;N3Text→S1selector. Case exact`OK`+LF: String`Completed: PDF written.`→Statusoutput,N3error→erroroutput. Case exact`UNSOLVABLE`+LF: BooleanTRUE→N4Condition;C6→N4Code;String`Grid is unsolvable; inspect the generated error PDF.`→N4Message;N3error→N4errorin;N4errorout→erroroutput and same message→Statusoutput. DEFAULT: N5path→N6File;cleanerrorconstant→N6errorin;P2→N7input0;String`MATLAB did not report OK. Full report: `→N7input1;N6Text→N7input2;N7string→N4Message and Statusoutput;TRUE→N4Condition;C6→N4Code;N3error→N4errorin;N4errorout→erroroutput. If error file is missing, its secondary read error is deliberately not substituted for the primary missing/bad status; Status still contains original launch diagnostics. S1→S0→P4/P5. Shared-lookingN4 objects in different cases are distinct instances labelledN4.UNSOLVABLE/N4.DEFAULT in the diagram. No missing status is treated as success.

## 12. LaunchMatlabAdapter.vi - complete direct path and bounded course interface

The course supplies MP_LaunchMatlabScript4.vi, copied unmodified in course_materials and runtime. A strings-only binary inspection confirmed references to System Exec and path utilities but cannot establish its connector labels/types/positions. **No connector terminals are invented here.** A direct native LabVIEW System Exec route below is fully specified so the package is constructible before that inspection. It still launches MATLAB and exchanges disk files natively; it does not move assessed image/grid work elsewhere. Use the supplied launcher once its real interface is confirmed.

### 12.1 Adapter panel and cleanup

Panel/connector P1 Runtime Path=L1;P2 MATLAB Executable Path=L2;P3 Windows? BooleanTRUE=L3;P4 error in=L4;P5 Use Course Launcher? BooleanFALSE=T1;P6 Script Path indicator=R1;P7 Diagnostics String indicator=R2;P8 error out=R4;R3,T2,B1,B2unassigned. Default direct mode is provisional until the course launcher has been inspected. User selects installed MATLAB executable inP2 (for example bin/matlab.exe onWindows, bin/matlab onmacOS); no personal installation path is embedded in code. MATLAB2019a+ `-batch` is assumed for direct mode. If older MATLAB is required, use the course launcher after native interface inspection and return version evidence.

N1Unbundle(status);S0guard;N2BuildPath(solve.m);N3BuildPath(MatlabStatus.txt);N4BuildPath(MatlabError.txt);N5RemoveIfExists;N6RemoveIfExists;S1Case onP5;N7SystemExec;N8FormatIntoString(diagnostics);N9NotEqual returncode0;N10ErrorIf;C1emptyString;C2noerror;C3I32zero;C4BooleanTRUE;C5U32(65536);C6code7008. P4→N1cluster→S0selector. TRUE:emptyPath→P6;emptyString→P7;P4→P8. FALSE:P1→N2/N3/N4base;literalnames→theirname;N2path→P6;N3path→N5File;P4→N5errorin;N4path→N6File;N5errorout→N6errorin;P5→S1selector. Stale-status cleanup finishes before launch. The selected launcher receives N6error and never runs on a prior error. Main also removes the expected old PDF before this adapter, chapter13.

### 12.2 Direct route (S1 FALSE)

Create BuildMatlabCommand.vi. Panel/connector: P1 Runtime Path=L1;P2 MATLAB Executable Path=L2;P3 Windows? BooleanTRUE=L3;P4 error in=L4;P5 Command String=R1;P6 error out=R4;remaining unassigned. Defaults emptypaths,TRUE,noerror,emptystring. Objects E0 Unbundle(status),G0 errorCase,E1 Path To String(executable),E2 Path To String(script),E3 BuildPath,E12 StringLength(executable),E13 Equal?,E14 ErrorIf(nonempty),G1 hostCase. Constants K0 I32zero,K1String`solve.m`,K2Stringempty,K3I32(7008),K4String`Select the installed MATLAB executable.`,K5BooleanFALSE.

P4→E0.cluster;E0.status→G0.selector. G0 TRUE:K2→commandoutput;P4→erroroutput. G0 FALSE:P1→E3.base;K1→E3.name;E3.path→E2.path;P2→E1.path;E1.string→E12.string;E12.length→E13.x;K0→E13.y;E13.result→E14.Condition;K3→E14.Code;K4→E14.Message;P4→E14.error in;P3→G1.selector. Bring executable string,script string,E14error into G1 through nonindexing tunnels named exe,script,err. G1 command/error outputs→G0outputs→P5/P6.

G1 TRUE (Windows) objects E4/E5 Match Regular Expression, W1/W2 StringLength, W3/W4 Equal?,W5AND,W6NOT,W7ErrorIf,E6FormatIntoString;constants WK1 normal-display regex from resources/windows_command_path_regex.txt,WK2I32zero,WK3BooleanFALSE,WK4I32(7008),WK5String`Unsafe or missing MATLAB command path.`,WK6format from resources/matlab_windows_format.txt. G1.exe→E4.string/W1.string;G1.script→E5.string/W2.string;WK1→E4/E5.regex;WK2→E4/E5.offset;WK3→E4/E5.multiline?/ignore case?;G1.err→E4.error in;E4.error out→E5.error in;E4.offset past match→W3.x;W1.length→W3.y;E5.offset past match→W4.x;W2.length→W4.y;W3.result→W5.x;W4.result→W5.y;W5.result→W6.x;W6.result→W7.Condition;WK4→W7.Code;WK5→W7.Message;E5.error out→W7.error in;WK6→E6.format;G1.exe→E6.argument0;G1.script→E6.argument1;W7.error out→E6.error in;E6.result→G1commandoutput;E6.error out→G1erroroutput.

G1 FALSE (POSIX) objects E7/E8/E10 SearchAndReplaceString(replaceallTRUE,regexmodeOFF),E9ConcatenateStrings3inputs,E11FormatIntoString;constants UK1singlequote`'`,UK2five-character shell quote`'"'"'`,UK3two singlequotes`''`,UK4String`run('`,UK5String`')`,UK6BooleanTRUE,UK7I32zero,UK8format from resources/matlab_posix_format.txt. G1.exe→E7.input;UK1→E7.search;UK2→E7.replace;G1.script→E8.input;UK1→E8.search;UK3→E8.replace;UK4→E9.input0;E8.result→E9.input1;UK5→E9.input2;E9.result→E10.input;UK1→E10.search;UK2→E10.replace;UK6→E7/E8/E10.replaceall;UK7→E7/E8/E10.offset;UK8→E11.format;E7.result→E11.argument0;E10.result→E11.argument1;G1.err→E11.error in;E11.result→G1commandoutput;E11.error out→G1erroroutput. Unused replace counts/offsets are unconnected. All constants are normal-display literal strings. No implicit shell cd: SystemExec workingdirectory is set separately.
Literal formats, no final LF in the constant:

```text
Windows: cmd /d /s /c ""%s" -wait -batch "run('%s')""
POSIX:   '%s' -batch '%s'
```

Back in adapter S1FALSE: N11BuildMatlabCommand withP1Runtime,P2Executable,P3Windows,N6errorin. N11Command→N7commandline;P1→N7workingdirectory;C4→N7waituntilcompletion?;C4→N7runminimized?;C5→N7expectedoutputsize;C1→N7standardinput;N11errorout→N7errorin. N7returncode→N9.x;C3→N9.y;N7returncode/stdout/stderr→N8formatargs0/1/2;format`Return code: %d\nstdout:\n%s\nstderr:\n%s\n` uses actualLF. C2→N8errorin;N8result→N10Message and Diagnosticsoutput;N9result→N10Condition;C6→N10Code;MergeErrors(N7error,N8error)→N10errorin;N10errorout→erroroutput. MATLAB may emit warnings to stderr; direct mode retains them inDiagnostics but requires both zeroexit and the fresh status check. Unlike C's strict stderr-empty contract, it does not classify every MATLAB warning as fatal. S1/S0outputs→P7/P8.

### 12.3 Course route (S1 TRUE) and literal interface inspection

Until inspection is complete, this case contains ErrorIf(TRUE,7009,`Course launcher connector not yet inspected; use direct mode or complete section12.3.`,N6error)→erroroutput; same message→Diagnosticsoutput. This is an explicit guarded alternative, not a fake functional supplied VI. Direct mode remains fully constructible. Do not set Use Course Launcher TRUE until the following single boundary is completed.

1. Open the preserved copy MP_LaunchMatlabScript4.vi manually in LabVIEW. Do not save over the course original. Save a working copy beside the other source VIs only if the professor's distribution permits adaptation; otherwise leave unchanged and wrap it.
2. Ctrl+H. Show connector pane. For each occupied terminal, click it and observe the highlighted control/indicator; right-clicknumeric controls > Representation. Record the exact label, input/output direction, type and connectorposition in resources/LAUNCHER_INTERFACE_RECORD.txt. Screenshot the entire frontpanel with connector and ContextHelp. Do not infer names from Billard or from compressed binary strings.
3. Ctrl+E to its diagram. Locate the course-mentioned test-script option and ensure the production route will be used. Record literal expected script input: basename, path or string, and whether it appends `.m`. Inspect workingdirectory and whether it waits until completion. Inspect which errors it returns and whether stderr filtering is enabled. Do not blanket-ignore errors. Capture the relevant diagram and VI version in File > VI Properties > General.
4. Place the real suppliedVI in adapterS1TRUE. For **each actual script-name/path input**, right-click its terminal>Create Control to obtain the exact type; if Path, connect N2.path; if String fullpath, connect PathToString(N2.path); if basenameString as proven by its diagram, connect constant`solve` or`solve.m` EXACTLY as that diagram requires. Use the recorded rule, not a guess. This is the sole course-dependent wiring boundary that cannot be concretely named without native inspection.
5. If it has errorin/out, connect N6error→actualerrorin and actualerrorout→adaptererroroutput. If noerrorin, place it inside a Case selected by N6.status: TRUE returnsN6error without calling;FALSE calls it. If noerrorout, downstream CheckMatlabStatus still requires a fresh status; retain launch evidence and do not claim process-level diagnostics are available. If an actual executable-path control exists, connectP2 after converting its proven type; otherwise document how the suppliedVI locatesMATLAB and test missingMATLAB behavior.
6. If it returns stdout/stderr/exitcode, build the exact same diagnostics and nonzeroexit guard as directmode using those **recorded actual outputs**. If it does not, set Diagnostics to`Course launcher: inspect its returned error and fresh status files.` and rely on its actualerror plus CheckMatlabStatus. If it launches asynchronously, keep Course mode disabled and return the inspection record; directmode is already synchronous and complete. Do not insert a guessed fixed sleep.
7. Save adapter source; return the record and screenshots for exact terminal reconciliation. Run an intentional success and error script, verify fresh statuses and exit behavior. Only then save Use Course Launcher TRUE as default if course compatibility is established. This guide does not assert that this inspection has happened.

Course source: Exo.Proj.Binairo.LabVIEW.2.pdf physicalp6. That source gives purpose/co-location/test-switch behavior, not enough machine-readable connector metadata. The old2025 connector is not a replacement.


## 13. BinairoSolver.vi — the complete main pipeline

### 13.1 Panel, connector and defaults

1. Save a new VI as `labview/BinairoSolver.vi`. Apply the chapter2 connector pattern. Add the following exact panel objects; clusters use order from left to right in this table. Arrange inputs on the left, picture and results on the right. Large strings use scrollbar-visible multiline displays. The executable path is selected once per installation and saved as a default only on that team's working copy.

| ID | Exact label | Object/type/default | Connector |
|---|---|---|---|
| M.P1 | PNG path | Path control, empty, browse existing file | L1 |
| M.P2 | Thresholds | Cluster control: empty DBL98, zero DBL90, one DBL90 | L2 |
| M.P3 | Options | Cluster control: solveWithMatlab BooleanTRUE, showPDF BooleanTRUE | L3 |
| M.P4 | error in | Standard error control, no error | L4 |
| M.P5 | MATLAB Executable | Path control, empty | T1 |
| M.P6 | Windows? | Boolean switch TRUE; set FALSE on macOS/Linux | T2 |
| M.P7 | Use Course Launcher? | Boolean switch FALSE | B1 |
| M.P8 | Original image | Native 2D Picture indicator, empty | R1 |
| M.P9 | Matrix text | String indicator empty | R2 |
| M.P10 | Status and diagnostics | String indicator empty | R3 |
| M.P11 | error out | Standard error indicator | R4 |
| M.P12 | Runtime directory | Path indicator empty | Unassigned |
| M.P13 | Grid size | I32 indicator0 | Unassigned |
| M.P14 | Bitmap | 2D Boolean indicator empty | Unassigned |
| M.P15 | Generated script | String indicator empty | Unassigned |
| M.P16 | PDF path | Path indicator empty | Unassigned |

B2 remains unassigned. Set P8 drawing-area background to white with the coloring tool as in geometry7.1. Right-click P8 > Visible Items > Horizontal Scrollbar and Vertical Scrollbar. Drag its drawing-area corner to give a readable approximately650-by620-pixel area; this accommodates the supplied610-by577 image. Scroll to origin before a screenshot. This changes only the panel display, never the bitmap. Input path/control defaults must not be fabricated. Save no-error defaults and empty result indicators before distribution. There is no Run/Stop Boolean or outer While Loop: toolbar Run executes one image once. Keep one pipeline running per runtime directory because Cell.bin and status filenames are deliberately shared.

2. Add these diagram constants: M.C0 I32zero; M.C4 I32four; M.CE emptyString; M.CP emptyPath; M.CB emptyBoolean2D; M.CPic empty native2DPicture (create constant from P8 terminal); M.CT BooleanTRUE; M.CF BooleanFALSE; M.CNoErr standard no-error cluster; M.CSourceRegex normal-display string from `resources/source_png_regex.txt`; M.CSourceCode I32(7010); M.CSourceMessage String`Select a nonempty PNG path without newline or NUL characters.`; M.CPdfSuffix String`.pdf`; M.CSpace String with one ASCIIspace; M.CRowEnd String `;
` entered in backslash display (semicolon then actualLF); M.CRowLog String`row=%d col=%d
%s
` as actualLF; M.CFailure String`Pipeline stopped. Inspect error out and the diagnostics below.
` as actualLF. Give all constants their stated IDs.

### 13.2 Paths and validation, with all branches

3. Place M.N1 Current VI's Path; M.N2 Strip Path; M.N3 Unbundle By Name(status); M.S0 Case(error); M.N4 Path To String(source); M.N5 Match Regular Expression; M.N6 String Length; M.N7 Equal?; M.N8 NOT; M.N9 ErrorIf; M.N10 ReadImage.vi; M.N11 ComputeRowsCols.vi. Place M.N12 Unbundle(status), M.S1 Case(error). Current VI's Path has no input. M.N1.path→M.N2.path; M.N2.stripped path→M.P12 and runtime tunnels in subsequent structures. This works from the saved VI in runtime; do not build an executable distribution at this stage because embedded-VI paths need another policy.

4. M.P4→M.N3.cluster; M.N3.status→M.S0.selector. S0 TRUE wires M.CPic→pictureout, M.CB→bitmapout, M.C0→nout, M.CE→matrixout/scriptout, M.CP→pdfout, M.CFailure→statusout, M.P4→errorout. In S0 FALSE: M.P1→M.N4.path; M.N4.string→M.N5.string and M.N6.string; M.CSourceRegex→M.N5.regular expression; M.C0→M.N5.offset; M.CF→M.N5.multiline?/ignore case?; M.P4→M.N5.error in; M.N5.offset past match→M.N7.x; M.N6.length→M.N7.y; M.N7.result→M.N8.x; M.N8.result→M.N9.Condition; M.CSourceCode→M.N9.Code; M.CSourceMessage→M.N9.Message; M.N5.error out→M.N9.error in. This anchored regex checks the complete path, including `.png` case-insensitively. Existence and content are checked by ReadImage.

5. M.P1→M.N10.PNG path; M.N9.error out→M.N10.error in; M.N10.Bitmap→M.N11.Bitmap and bitmapout; M.N10.Picture→pictureout; M.N10.error out→M.N11.error in; M.N11.n→nout; M.N11.error out→M.N12.cluster→M.S1.selector(status). N10.Width/Height remain unconnected because ComputeRowsCols checks the bitmap. S1 TRUE: M.CE→matrixout/scriptout, M.CP→pdfout, M.CFailure→statusout, M.N11.error out→errorout. Picture/bitmap/n bypass S1, but stay inside S0. S1 FALSE contains all remaining operations. No OCR/script/MATLAB starts on malformed geometry.

6. In S1 FALSE add M.N13 Strip Path(source), M.N14 String Length, M.N15 Subtract, M.N16 String Subset, M.N17 Concatenate Strings2inputs, M.N18 Build Path. M.P1→M.N13.path; M.N13.name→M.N14.string and M.N16.string; M.N14.length→M.N15.x; M.C4→M.N15.y; M.C0→M.N16.offset; M.N15.result→M.N16.length; M.N16.substring→M.N17.input0; M.CPdfSuffix→M.N17.input1; M.N2.stripped path→M.N18.base; M.N17.string→M.N18.name; M.N18.path→pdfout. The extension was validated before subtracting4. `foo.png` produces runtime/foo.pdf, matching BinairoOutputPath.m. Source Strip Path's directory output is unused.

7. Place exactly six Build Path nodes M.B1..M.B6 and six RemoveIfExists.vi instances M.D1..M.D6. Constants M.F1..M.F6 are respectively `CellValue.txt`, `CellValue.txt.tmp`, `solve.m`, `MatlabStatus.txt`, `MatlabError.txt`, `MatlabRun.log`. For each k in the explicitly finite set1,2,3,4,5,6: M.N2.stripped path→M.Bk.base; M.Fk→M.Bk.name; M.Bk.path→M.Dk.File. Error chain is M.N11.error out→M.D1.error in; D1out→D2in; D2out→D3in; D3out→D4in; D4out→D5in; D5out→D6in. Add M.D7 RemoveIfExists: M.N18.path→D7.File; D6.error out→D7.error in. This removes only generated files once valid source/geometry is known. On invalid geometry a previous file may remain on disk, but is never reported as fresh success; the UI error is authoritative. Cell.bin is replaced per cell; source PNG is never deleted.

### 13.3 The two literal row/column loops

8. Place M.LR outer For Loop inside S1 FALSE. M.N11.n→LR.N; disable parallelism; no conditional stop. Add exactly three initialized shift registers: `matrix.L/R` String initialized M.CE, `diag.L/R` String initialized M.CE, `err.L/R` standard error initialized M.D7.error out. Nonindexing input tunnels bring n, Bitmap(N10), GridLines(N11), Runtime(N2), Thresholds(P2), Windows(P6), constants CE,CSpace,CRowEnd,CRowLog,CNoErr,C0. No automatic indexing tunnels anywhere in LR. The fixed n is even and >=2 from geometry. LR.i is the row index.

9. Inside LR place M.LC inner For Loop. LR.n tunnel→LC.N; disable parallelism; no conditional stop. Add exactly three initialized shift registers: `row.L/R` String initialized LR.CE from outside LC, `diag.L/R` String initialized LR.diag.L, `err.L/R` standard error initialized LR.err.L. Nonindexing tunnels bring LR.i as `rowIndex`, Bitmap, GridLines, Runtime, Thresholds, Windows, CSpace,CRowLog,CNoErr,C0. LC.i is the column index. No auto-indexing tunnels in LC. Do not wire the index from the wrong loop into rowIndex.

10. In LC place M.I1 Unbundle(status), M.IS Case(error), M.I2 Bundle2elements, M.I3 ReadCase.vi, M.I4 Equal?, M.I5 Select(String), M.I6 Concatenate Strings3inputs, M.I7 Format Into String3arguments, M.I8 Concatenate Strings2inputs, M.I9 Merge Errors2inputs, M.I10 Unbundle(status), M.IS2 Case(error). Create M.ICIndex cluster constant(order rowI32=0,colI32=0) and replace M.I2 with **Bundle By Name** using this constant; fields row,col. This preserves the field names expected by ReadCase. Create M.ICEmpty emptyString. All these objects except I1/IS are inside IS FALSE.

11. LC.err.L→I1.cluster; I1.status→IS.selector. IS TRUE: LC.row.L→rowout; LC.diag.L→diagout; LC.err.L→errout. IS FALSE: M.ICIndex→I2.input cluster; LC.rowIndex→I2.row; LC.i→I2.col; LC.Bitmap→I3.Bitmap; LC.GridLines→I3.GridLines; I2.cluster→I3.CellIndex; LC.Runtime→I3.Runtime; LC.Thresholds→I3.Thresholds; LC.Windows→I3.Windows?; LC.err.L→I3.error in.

12. LC.i→I4.x; LC.C0→I4.y; I4.result→I5.s; M.ICEmpty→I5.t; LC.CSpace→I5.f; LC.row.L→I6.input0; I5.output→I6.input1; I3.Token→I6.input2. Thus first token has no leading space; subsequent tokens have one separator. No numeric conversion of NaN is needed to generate valid MATLAB source.

13. LC.CRowLog→I7.format string; LC.rowIndex→I7.argument0; LC.i→I7.argument1; I3.Diagnostics→I7.argument2; LC.CNoErr→I7.error in; LC.diag.L→I8.input0; I7.result→I8.input1; I3.error out→I9.error0; I7.error out→I9.error1; I9.error out→I10.cluster→IS2.selector(status). IS2 TRUE: LC.row.L→rowout; I8.result→diagout; I9.error out→errout. IS2 FALSE: I6.result→rowout; I8.result→diagout; I9.error out→errout. IS2→IS output tunnels; IS.rowout→LC.row.R; IS.diagout→LC.diag.R; IS.errout→LC.err.R. Every register is wired exactly once in every case. A failed cell preserves the existing partial row but blocks all subsequent calls; it cannot insert a fake blank. I3.Percent is unused here but available for a probe in ReadCase.

14. After LC, inside LR, place M.R1 Concatenate Strings3inputs. LR.matrix.L→R1.input0; LC.row.R(final outside)→R1.input1; LR.CRowEnd→R1.input2; R1.result→LR.matrix.R; LC.diag.R(final)→LR.diag.R; LC.err.R(final)→LR.err.R. Empty/partial rows after failure may be visible for diagnosis, but BuildML's error guard prevents writing or launching them. Neither loop stops early, so shift-register output is always well-defined; after first failure subsequent iterations perform no file/process work.

### 13.4 Generate, launch, verify and present errors

15. After LR in S1 FALSE, place M.N19 BuildML.vi, M.N20 LaunchMatlabAdapter.vi, M.N21 CheckMatlabStatus.vi, M.N22 Concatenate Strings3inputs, M.N23 Unbundle(status), M.S2 Case(error), M.N24 Concatenate Strings2inputs. Wire LR.matrix.R(final)→N19.MatrixText and matrixout; M.P1→N19.Source PNG; M.P3→N19.Options; M.N2.stripped path→N19.Runtime; LR.err.R(final)→N19.error in; N19.Script Text→scriptout. N19.Script Path is unused because adapter derives the same fixed name.

16. M.N2.stripped path→N20.Runtime and N21.Runtime; M.P5→N20.MATLAB Executable; M.P6→N20.Windows?; M.P7→N20.Use Course Launcher?; N19.error out→N20.error in; N20.Diagnostics→N21.Launch Diagnostics; N20.error out→N21.error in. N20.Script Path is unused. N21.error out→errorout and N23.cluster; N23.status→S2.selector. LR.diag.R(final)→N22.input0; N20.Diagnostics→N22.input1; N21.Status→N22.input2. S2 FALSE:N22.result→statusout. S2 TRUE:M.CFailure→N24.input0;N22.result→N24.input1;N24.result→statusout. Error source/code appear in P11, so even an early failure with no subprocess text is fully visible.

17. Join S1 output tunnels into S0 outputs as described: matrix/script/pdf/status/error; picture/bitmap/n bypass S1 from step5. S0 picture→P8; matrix→P9; status→P10; error→P11; n→P13; bitmap→P14; script→P15; pdf→P16. Runtime P12 is wired directly at step3. Every tunnel is wired in TRUE and FALSE. Run arrow must be unbroken before testing. No Simple Error Handler modal dialogue is needed: P11 displays the complete standard error cluster.

18. Save source VIs and project; close all VIs, assemble into runtime again, then open **runtime/BinairoSolver.vi**. Select the known6x6 PNG and installed MATLAB executable. Keep98/90/90, Windows TRUE on Windows, direct launcher FALSE for Use Course Launcher, both Options TRUE. Set the panel window large enough that P9/P10/P11 can be read. The first successful run must show n=6, the exact matrix from BinairoExamples.m, a generated script and fresh PDF/status. This is the expected observation, not a claimed measured result.

## 14. Checkpoints, native tests and return packet

### 14.1 Small checkpoint VI for binary serialization

1. Save `labview/CheckWriteCell.vi`, no connector assignments. Panel Q.P1 Path outputFile control empty, Q.P2 error out indicator. Diagram Q.N1 Initialize Array(BooleanFALSE,dimensions35,40), Q.N2 Replace Array Subset, Q.N3 WriteCell.vi; constants Q.CF FALSE,Q.CT TRUE,Q.C35 I32(35),Q.C40 I32(40),Q.C2 I32(2),Q.C9 I32(9),Q.CE noerrorcluster.
2. Q.CF→N1.element; Q.C35→N1.dimension size0; Q.C40→N1.dimension size1; N1.array→N2.array; Q.C2→N2.indexrow; Q.C9→N2.indexcol; Q.CT→N2.new element; N2.array→N3.Cell; Q.P1→N3.File; Q.CE→N3.error in; N3.error out→Q.P2. No loops/cases. Choose a disposable file path, e.g. runtime/Asymmetric.bin; run once. Never point at a course fixture.
3. In a terminal at project root, paste `python tests/inspect_cell.py runtime/Asymmetric.bin --expect-asymmetric` (Windows `py -3` may replace python). Expect width40,height35,1408bytes, only black index89 (row2,col9), payload0/1. The helper only inspects files; it does not replace native serialization. Return the JSON output and actual file on failure.

### 14.2 Checkpoints in exact order

1. ErrorIf tests chapter3, ReadText/WriteText roundtrip raw LF, RemoveIfExists absent/file/directory branches. Use disposable paths only; directory must remain intact and produce7002.
2. Geometry guide ReadImage polarity/decode checks, BlackRuns synthetic edge-touching arrays, ComputeRowsCols6/8/4/nonsquare cases, ComputeCellRect first/last/invalid index. Capture the named indicators at each failed checkpoint.
3. CheckWriteCell asymmetric test above. Then use ReadCase with row0,col0 of6x6 and inspect Cell.bin: width72,height68,total4904. Supplied Cell0.bin uses74x74 and is a different bordered fixture.
4. ParseCellValue exact good/bad strings in chapter8. BuildOCRCommand verify dot decimals under French/Swiss locale. Run actual C through native System Exec: success means clear error, return0, no stdout/stderr and strict parsed result.
5. BuildML manually inspect generated rows, NaN, source apostrophe escaping and options. Verify the saved file equals the Script Text indicator byte-for-byte apart from editor display of newline.
6. Run native MATLAB tests exactly from MATLAB_OPERATOR_GUIDE.md; retain evidence even if they fail. Complete course-launcher interface record only if using that alternative. Direct launcher must wait and return real exit status; Windows format includes `-wait -batch`.
7. Full pipeline tests1–13 in TEST_PACKAGE.md, including all four option combinations, invalid inputs, missing executables, runtime relocation and injected MATLAB failure. These are all required acceptance checks; passing one6x6 screenshot does not close native verification.

### 14.3 What to capture without writing test code

1. Create `evidence/labview_YYYYMMDD/` at project root using the actual date. Copy `resources/NATIVE_EVIDENCE_FORM.txt` there, open it in a text editor and fill the observed version/test/status fields. Use actual names, never guessed results.
2. For a failure, do not run another cell/image first: it would overwrite shared files. Save all VIs, copy runtime/Cell.bin, CellValue.txt if present, solve.m, MatlabStatus.txt, MatlabError.txt, MatlabRun.log and relevant PDF into that evidence folder. Keep source PNG with excluded private materials, recording its exact filename/hash in evidence.
3. Save main front panel and failing diagram screenshots with object IDs. Include Context Help for a terminal mismatch, Error List if arrow broken, and complete P11 status/code/source. Right-click string indicators > Copy Data (or select text and copy) and paste into UTF-8 text files. For ReadCase capture return code, stdout and stderr separately using probes/indicators created from N11's actual output terminals; creating an indicator does not change the dataflow. Restore original diagram layout afterward if desired.
4. Copy final authoritative `.vi`, `.ctl`, `.lvproj` into labview/ before packaging. Close LabVIEW before making the copy. Keep the supplied unmodified launcher separately so it is never confused with an edited wrapper.
5. Paste `python tools/collect_native_evidence.py --label LV01` from project root (or `py -3 ...` on Windows); this collects existing generated files and a source hash inventory into a dated evidence folder. It never claims PASS, copies no PNG/course materials into Git, and never operates MATLAB/LabVIEW. Add screenshots and the filled form to the generated folder. Zip that folder plus updated labview/ and return it to this task, or follow TEAM_GITHUB_GUIDE to push allowed files.
6. A teammate's local edits are not backed up until pushed or returned and committed here. One person owns each VI; preserve both conflicting binary versions and use the reconciliation steps in TEAM_GITHUB_GUIDE. After evidence returns, this task reviews actual native results, repairs the package and updates verification status before the report/submission is finalized.

### 14.4 Finish criteria and narrow remaining boundary

The first-delivery recipe includes every project-owned VI, typedef, loop/case, serialization, command, parser, script generation and main error chain. It does not contain authored functional `.vi` files, because construction is explicitly the group's next step. The supplied launcher is an existing binary included unchanged; its real connector remains the only source-dependent native inspection boundary and has a guarded alternative with a complete synchronous launch recipe. Official current main-connector and final error/submission rules remain provisional, as logged in PROFESSOR_QUESTIONS.md. Geometry assumptions and palette calibration are explicit in the geometry chapter. Native execution may expose version/type/wiring differences; return exact evidence rather than treating this written recipe as execution proof.
