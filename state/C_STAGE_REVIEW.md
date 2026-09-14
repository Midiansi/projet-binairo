# C stage review

Implemented and source-reviewed after the frozen contract. Native local environment: macOS ARM64, Apple clang; exact version recorded in TEST_EVIDENCE.md. Real helper functions, packed course bitmaps, unsigned shifts, malloc and single bulk pixel fread, no VLA. Strict validation, deterministic selection, full stale-result/error handling and temporary publication implemented.

Measured: 49 C unit checks passed normal build and AddressSanitizer/UndefinedBehaviorSanitizer build. 69 CLI integration tests passed using independent Python integer-bitset oracle, including supplied cells, rectangles, edge offsets, thresholds/equality/ties, malformed input, excess/short payload, output failure and path spaces/apostrophe. Sanitizer CLI report is separate.

A first test invocation used system Python 3.9 and 22 cases failed because int.bit_count requires Python >=3.10; this was a test environment mismatch, not an OCR pass. Re-run with bundled Python >=3.10 produced 69/69. Windows compilation is prepared but not executed. MATLAB/LabVIEW not executed. Read/close/malloc/write-flush failure branches reviewed, but not all OS failure modes fault-injected.

No independent implementation audit completed after a reviewer hit a usage limit. Root performed source review; earlier source expectations were independently derived. Native target validation remains pending.
