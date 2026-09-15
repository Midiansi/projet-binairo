# Native LabVIEW supplemental fixtures

These8 files are AI-designed test inputs, created from regular black4px strokes and white interiors. They do not contain copied course-image data. EXPECTED.json records hashes/dimensions and expected native outcomes, all PENDING until actually run.

In ReadImage then ComputeRowsCols, select each named PNG in EXPECTED.json. Valid files have4x4 all-blank cells; no template digits are embedded. AI_margin4_valid has fully transparent12pixel margins, testing the native white-background mask. Odd/rectangular/bad-gap/blank/corrupt inputs must fail with the described geometry/decoder error. The renderer may return a default palette requiring the guide's source6x6 calibration first. An exact decoding error number can depend on NI version; preserve full error details.

For the valid4x4, main pipeline should generate four rows of fourNaN values and solve a valid4x4, with all displayed solution digits blue. No particular solution is required; rows/columns must satisfy Binairo and there are no original clues. No native success is claimed from generation of these files.
