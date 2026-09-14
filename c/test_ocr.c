/* EPFL ME-213 Binairo 2026. AI-assisted implementation by Codex.
 * Team author names: to be supplied before submission; see docs report.
 * Contract and provisional choices: docs/INTERFACE_CONTRACT.md. */
#include "ocr.h"
#include "ocr_policy.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned int checks = 0;
static unsigned int failures = 0;

static void Check(int condition, const char *label)
{
    ++checks;
    if (!condition) {
        ++failures;
        fprintf(stderr, "FAIL: %s\n", label);
    }
}

static void TestThresholds(void)
{
    static const char *valid[] = {"0", "100", "90.0", ".5", "100.", "+98", "-0"};
    static const double expected[] = {0, 100, 90, .5, 100, 98, 0};
    static const char *invalid[] = {
        "", "+", "-", ".", "-1", "100.0001", "101", " 90", "90 ",
        "nan", "NaN", "inf", "-inf", "1e2", "0x1p2", "90,5", "90%", "9x", "..1"
    };
    size_t index;
    for (index = 0; index < sizeof valid / sizeof valid[0]; ++index) {
        double value = -123.0;
        Check(OcrParseThreshold(valid[index], &value) == OCR_OK &&
              value == expected[index], "valid decimal threshold");
    }
    for (index = 0; index < sizeof invalid / sizeof invalid[0]; ++index) {
        double value = -123.0;
        Check(OcrParseThreshold(invalid[index], &value) == OCR_ARGUMENT_ERROR &&
              value == -123.0, "invalid threshold rejected without changing result");
    }
}

static void TestSelection(void)
{
    double scores[2] = {95, 92};
    double thresholds[2] = {94, 80};
#if OCR_SELECT_BY_MARGIN
    Check(OcrSelectDigit(scores, thresholds) == 1, "margin selection differs from raw score");
#else
    Check(OcrSelectDigit(scores, thresholds) == 0, "raw-score policy alternative");
#endif
    thresholds[0] = 95;
    thresholds[1] = 93;
    Check(OcrSelectDigit(scores, thresholds) == 0, "digit equality is eligible");
    thresholds[0] = 96;
    Check(OcrSelectDigit(scores, thresholds) == -1, "no eligible digit is no-match");
    scores[0] = 90;
    scores[1] = 95;
    thresholds[0] = 80;
    thresholds[1] = 85;
    Check(OcrSelectDigit(scores, thresholds) == 1, "equal margins favor higher raw score");
    scores[0] = 95;
    thresholds[0] = 85;
    Check(OcrSelectDigit(scores, thresholds) == 0, "complete tie favors digit zero");
}

static void TestHelpers(void)
{
    unsigned char pixels[120] = {0};
    OcrCell cell = {12, 10, pixels};
    pixels[2 * 12 + 9] = 1;
    Check(GetCellBit(&cell, 2, 9) == 1, "rectangular row-major cell indexing");
    Check(GetCellBit(&cell, 9, 2) == 0, "row and column not swapped");
    Check(GetDigitBitmapBit(0, 2, 7) == 0 && GetDigitBitmapBit(0, 2, 8) == 1 &&
          GetDigitBitmapBit(0, 2, 15) == 1 && GetDigitBitmapBit(0, 2, 16) == 0,
          "course row 0x00FF0000 uses column zero at bit31");
    Check(GetDigitBitmapBit(1, 7, 3) == 1 && GetDigitBitmapBit(1, 7, 2) == 0 &&
          GetDigitBitmapBit(1, 7, 31) == 0,
          "course one bitmap bit extraction");
}

static void TestRecognition(void)
{
    OcrCell cell = {40, 35, NULL};
    OcrThresholds thresholds = {100.0, 100.0, 100.0};
    OcrResult result;
    const char *description = "";
    unsigned int digit;
    unsigned int corner;
    cell.pixels = malloc((size_t)cell.width * cell.height);
    Check(cell.pixels != NULL, "test cell allocation");
    if (cell.pixels == NULL) {
        return;
    }
    for (digit = 0; digit < 2; ++digit) {
        for (corner = 0; corner < 4; ++corner) {
            const size_t x = (corner & 1u) ? cell.width - 32u : 0u;
            const size_t y = (corner & 2u) ? cell.height - 32u : 0u;
            size_t row;
            memset(cell.pixels, 0, (size_t)cell.width * cell.height);
            for (row = 0; row < 32; ++row) {
                size_t col;
                for (col = 0; col < 32; ++col) {
                    cell.pixels[(row + y) * cell.width + col + x] =
                        GetDigitBitmapBit(digit, row, col);
                }
            }
            Check(OcrRecognize(&cell, &thresholds, &result, &description) == OCR_OK &&
                  result.symbol == (char)('0' + digit) && result.percentage == 100.0 &&
                  result.best[digit] == 1024,
                  "exact template at each rectangular-cell corner, inclusive offsets");
        }
    }
    OcrFreeCell(&cell);
    Check(cell.pixels == NULL && cell.width == 0 && cell.height == 0, "free resets ownership");
    OcrFreeCell(&cell);

    cell.width = 10;
    cell.height = 10;
    cell.pixels = calloc(100, 1);
    Check(cell.pixels != NULL, "small test cell allocation");
    if (cell.pixels == NULL) {
        return;
    }
    thresholds.empty = 99;
    Check(OcrRecognize(&cell, &thresholds, &result, &description) == OCR_OK &&
          result.symbol == ' ' && result.percentage == 100.0,
          "small all-white cell is empty before template-size check");
    cell.pixels[0] = 1;
    Check(OcrRecognize(&cell, &thresholds, &result, &description) == OCR_NO_MATCH,
          "empty equality is strict and small nonempty cell cannot match");
    thresholds.empty = 98;
    Check(OcrRecognize(&cell, &thresholds, &result, &description) == OCR_OK &&
          result.symbol == ' ' && result.percentage == 99.0,
          "empty percentage uses whole cell");
    OcrFreeCell(&cell);
}

int main(void)
{
    TestThresholds();
    TestSelection();
    TestHelpers();
    TestRecognition();
    printf("C unit tests: %u checks, %u failures (margin policy=%d)\n",
           checks, failures, OCR_SELECT_BY_MARGIN);
    return failures == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}
