/* EPFL ME-213 Binairo 2026. AI-assisted implementation by Codex.
 * Team author names: to be supplied before submission; see docs report.
 * Contract and provisional choices: docs/INTERFACE_CONTRACT.md. */
#ifndef BINAIRO_OCR_H
#define BINAIRO_OCR_H

#include <stddef.h>
#include <stdint.h>

enum OcrStatus {
    OCR_OK = 0,
    OCR_ARGUMENT_ERROR = 2,
    OCR_FORMAT_ERROR = 3,
    OCR_INPUT_ERROR = 4,
    OCR_NO_MATCH = 5,
    OCR_OUTPUT_ERROR = 6
};

typedef struct {
    uint32_t width;
    uint32_t height;
    unsigned char *pixels;
} OcrCell;

typedef struct {
    double empty;
    double zero;
    double one;
} OcrThresholds;

typedef struct {
    char symbol;                /* ASCII '0', '1', or one space for empty. */
    double percentage;        /* Raw score, never the selection margin. */
    unsigned int best[2];      /* Equal pixels out of 1024, for validation. */
} OcrResult;

/* Helpers use zero-based row/column positions. Their caller checks bounds.
 * GetDigitBitmapBit: digit in 0..1; row and col in 0..31.
 * GetCellBit: cell is initialized, row < height and col < width.
 */
unsigned char GetDigitBitmapBit(unsigned int digit, size_t row, size_t col);
unsigned char GetCellBit(const OcrCell *cell, size_t row, size_t col);

/* All errors return an OcrStatus and a static, human-readable description.
 * No core helper writes stdout/stderr. OcrReadCell requires an empty cell
 * (pixels == NULL), owns allocated memory on success, and leaves it empty on
 * failure. OcrFreeCell is safe to call repeatedly on an initialized cell.
 */
int OcrParseThreshold(const char *text, double *value);
int OcrReadCell(const char *path, OcrCell *cell, const char **description);
void OcrFreeCell(OcrCell *cell);
int OcrRecognize(const OcrCell *cell, const OcrThresholds *thresholds,
                 OcrResult *result, const char **description);

/* Public for boundary/tie tests; inputs are scores and thresholds in 0..100.
 * Returns digit 0/1 or -1 when neither digit meets its threshold.
 */
int OcrSelectDigit(const double scores[2], const double thresholds[2]);

#endif
