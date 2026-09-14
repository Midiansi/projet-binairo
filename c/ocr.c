/* EPFL ME-213 Binairo 2026. AI-assisted implementation by Codex.
 * Team author names: to be supplied before submission; see docs report.
 * Contract and provisional choices: docs/INTERFACE_CONTRACT.md. */
#include "ocr.h"
#include "ocr_policy.h"

#include <errno.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

/* This supplied header defines storage, so include it in this file only.
 * Restore the unchanged course original into course_materials/ before build.
 */
#include "FontRasterized_0_1.h"

_Static_assert(DigitBitmapWidth == 32, "Expected course 32-bit packed rows");
_Static_assert(DigitBitmapHeight == 32, "Expected course 32-row digit bitmap");

unsigned char GetDigitBitmapBit(unsigned int digit, size_t row, size_t col)
{
    /* Cast BEFORE shifting: signed right-shift is implementation-dependent. */
    const uint32_t bits = (uint32_t)DigitBitmap[digit][row];
    return (unsigned char)((bits >> (31u - (unsigned int)col)) & UINT32_C(1));
}

unsigned char GetCellBit(const OcrCell *cell, size_t row, size_t col)
{
    return cell->pixels[row * (size_t)cell->width + col];
}

static int IsDecimalDigit(char character)
{
    return character >= '0' && character <= '9';
}

int OcrParseThreshold(const char *text, double *value)
{
    const char *cursor = text;
    size_t digits = 0;
    char *end = NULL;
    double parsed;

    if (text == NULL || value == NULL || *cursor == '\0') {
        return OCR_ARGUMENT_ERROR;
    }
    if (*cursor == '+' || *cursor == '-') {
        ++cursor;
    }
    while (IsDecimalDigit(*cursor)) {
        ++digits;
        ++cursor;
    }
    if (*cursor == '.') {
        ++cursor;
        while (IsDecimalDigit(*cursor)) {
            ++digits;
            ++cursor;
        }
    }
    /* Constrain strtod to ordinary decimal syntax. In particular, reject
     * whitespace, exponent/hex forms, NaN, infinity, comma decimals and junk.
     */
    if (digits == 0 || *cursor != '\0') {
        return OCR_ARGUMENT_ERROR;
    }
    errno = 0;
    parsed = strtod(text, &end);
    if (errno == ERANGE || end == text || *end != '\0' ||
        !isfinite(parsed) || parsed < 0.0 || parsed > 100.0) {
        return OCR_ARGUMENT_ERROR;
    }
    *value = parsed;
    return OCR_OK;
}

static uint32_t ReadU32LittleEndian(const unsigned char *bytes)
{
    return (uint32_t)bytes[0] |
           ((uint32_t)bytes[1] << 8u) |
           ((uint32_t)bytes[2] << 16u) |
           ((uint32_t)bytes[3] << 24u);
}

void OcrFreeCell(OcrCell *cell)
{
    if (cell != NULL) {
        free(cell->pixels);
        cell->pixels = NULL;
        cell->width = 0;
        cell->height = 0;
    }
}

int OcrReadCell(const char *path, OcrCell *cell, const char **description)
{
    FILE *input = NULL;
    unsigned char header[8];
    size_t pixel_count = 0;
    size_t index;
    int status = OCR_OK;
    int next;

    cell->width = 0;
    cell->height = 0;
    input = fopen(path, "rb");
    if (input == NULL) {
        *description = "cannot open input cell file";
        return OCR_INPUT_ERROR;
    }
    if (fread(header, 1, sizeof header, input) != sizeof header) {
        status = ferror(input) ? OCR_INPUT_ERROR : OCR_FORMAT_ERROR;
        *description = ferror(input) ? "input read failed in header" :
                                      "input header must contain 8 bytes";
        goto cleanup;
    }
    cell->width = ReadU32LittleEndian(header);
    cell->height = ReadU32LittleEndian(header + 4);
    if (cell->width < OCR_MIN_DIMENSION || cell->width > OCR_MAX_DIMENSION ||
        cell->height < OCR_MIN_DIMENSION || cell->height > OCR_MAX_DIMENSION) {
        status = OCR_FORMAT_ERROR;
        *description = "cell dimensions are outside the configured bounds";
        goto cleanup;
    }
    if ((size_t)cell->width > SIZE_MAX / (size_t)cell->height) {
        status = OCR_FORMAT_ERROR;
        *description = "cell dimensions overflow the pixel buffer size";
        goto cleanup;
    }
    pixel_count = (size_t)cell->width * (size_t)cell->height;
    cell->pixels = malloc(pixel_count);
    if (cell->pixels == NULL) {
        status = OCR_INPUT_ERROR;
        *description = "cannot allocate the cell pixel buffer";
        goto cleanup;
    }
    /* One bulk read of the entire pixel array, as required by P26 p18. */
    if (fread(cell->pixels, 1, pixel_count, input) != pixel_count) {
        status = ferror(input) ? OCR_INPUT_ERROR : OCR_FORMAT_ERROR;
        *description = ferror(input) ? "input read failed in pixel payload" :
                                      "pixel payload is shorter than width times height";
        goto cleanup;
    }
    next = fgetc(input);
    if (ferror(input)) {
        status = OCR_INPUT_ERROR;
        *description = "input read failed while checking the end of file";
        goto cleanup;
    }
    if (next != EOF) {
        status = OCR_FORMAT_ERROR;
        *description = "pixel payload is longer than width times height";
        goto cleanup;
    }
    for (index = 0; index < pixel_count; ++index) {
        if (cell->pixels[index] > 1u) {
            status = OCR_FORMAT_ERROR;
            *description = "every pixel must be byte 0 (white) or 1 (black)";
            goto cleanup;
        }
    }

cleanup:
    if (fclose(input) != 0 && status == OCR_OK) {
        status = OCR_INPUT_ERROR;
        *description = "cannot close input cell file";
    }
    if (status != OCR_OK) {
        OcrFreeCell(cell);
    }
    return status;
}

int OcrSelectDigit(const double scores[2], const double thresholds[2])
{
    int selected = -1;
    unsigned int digit;
    double best_primary = 0.0;
    for (digit = 0; digit < 2u; ++digit) {
        double primary;
        if (scores[digit] < thresholds[digit]) {
            continue;
        }
#if OCR_SELECT_BY_MARGIN
        primary = scores[digit] - thresholds[digit];
#else
        primary = scores[digit];
#endif
        if (selected < 0 || primary > best_primary ||
            (primary == best_primary && scores[digit] > scores[selected])) {
            selected = (int)digit;
            best_primary = primary;
        }
        /* Equal primary AND raw scores retain the earlier digit: 0. */
    }
    return selected;
}

int OcrRecognize(const OcrCell *cell, const OcrThresholds *thresholds,
                 OcrResult *result, const char **description)
{
    size_t white = 0;
    const size_t pixel_count = (size_t)cell->width * (size_t)cell->height;
    size_t index;
    unsigned int digit;
    double scores[2];
    const double digit_thresholds[2] = {thresholds->zero, thresholds->one};
    int selected;

    result->symbol = ' ';
    result->percentage = 0.0;
    result->best[0] = 0;
    result->best[1] = 0;
    for (index = 0; index < pixel_count; ++index) {
        white += cell->pixels[index] == 0u;
    }
    result->percentage = 100.0 * (double)white / (double)pixel_count;
    if (result->percentage > thresholds->empty) {
        return OCR_OK;
    }
    if (cell->width < DigitBitmapWidth || cell->height < DigitBitmapHeight) {
        *description = "nonempty cell is too small for the 32 by 32 digit templates";
        return OCR_NO_MATCH;
    }

    for (digit = 0; digit < 2u; ++digit) {
        size_t y;
        for (y = 0; y <= (size_t)cell->height - DigitBitmapHeight; ++y) {
            size_t x;
            for (x = 0; x <= (size_t)cell->width - DigitBitmapWidth; ++x) {
                unsigned int equal = 0;
                size_t row;
                for (row = 0; row < DigitBitmapHeight; ++row) {
                    size_t col;
                    for (col = 0; col < DigitBitmapWidth; ++col) {
                        /* Matching WHITE pixels matters as much as BLACK:
                         * P26 p10 explains why black-only comparison fails.
                         */
                        equal += GetCellBit(cell, y + row, x + col) ==
                                 GetDigitBitmapBit(digit, row, col);
                    }
                }
                if (equal > result->best[digit]) {
                    result->best[digit] = equal;
                }
            }
        }
        scores[digit] = 100.0 * (double)result->best[digit] / 1024.0;
    }
    selected = OcrSelectDigit(scores, digit_thresholds);
    if (selected < 0) {
        *description = "neither digit meets its recognition threshold";
        return OCR_NO_MATCH;
    }
    result->symbol = (char)('0' + selected);
    result->percentage = scores[selected];
    return OCR_OK;
}
