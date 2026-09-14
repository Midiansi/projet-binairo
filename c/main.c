/* EPFL ME-213 Binairo 2026. AI-assisted implementation by Codex.
 * Team author names: to be supplied before submission; see docs report.
 * Contract and provisional choices: docs/INTERFACE_CONTRACT.md. */
#include "ocr.h"

#include <errno.h>
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* File-only deletion preserves a directory accidentally named CellValue.txt.
 * ISO remove() may delete an empty directory on POSIX. These equivalent APIs
 * are the only platform-specific operations used by the C executable.
 */
#ifdef _WIN32
#include <io.h>
#define DeleteFileOnly _unlink
#else
#include <unistd.h>
#define DeleteFileOnly unlink
#endif

static const char OutputName[] = "CellValue.txt";
static const char TemporaryName[] = "CellValue.txt.tmp";

static int IsSeparator(char character)
{
#ifdef _WIN32
    return character == '/' || character == '\\';
#else
    return character == '/';
#endif
}

/* Allocate a sibling path without relying on the process current directory.
 * On Windows, preserve C: in drive-relative inputs as well as / and \\.
 */
static int OutputPaths(const char *input, char **output, char **temporary,
                       const char **description)
{
    const char *base = input;
    const char *cursor;
    size_t prefix;
    if (*input == '\0') {
        *description = "input path must not be empty";
        return OCR_ARGUMENT_ERROR;
    }
#ifdef _WIN32
    if (((input[0] >= 'A' && input[0] <= 'Z') ||
         (input[0] >= 'a' && input[0] <= 'z')) && input[1] == ':') {
        base = input + 2;
    }
#endif
    for (cursor = input; *cursor != '\0'; ++cursor) {
        if (IsSeparator(*cursor)) {
            base = cursor + 1;
        }
    }
    if (*base == '\0' || strcmp(base, ".") == 0 || strcmp(base, "..") == 0) {
        *description = "input path must name a file";
        return OCR_ARGUMENT_ERROR;
    }
    /* Do not delete the input itself during stale-output cleanup. Windows
     * filenames are case-insensitive, and the same often holds on macOS.
     */
    {
        char folded[sizeof TemporaryName];
        const size_t length = strlen(base);
        if (length < sizeof folded) {
            size_t index;
            for (index = 0; index <= length; ++index) {
                const char ch = base[index];
                folded[index] = (ch >= 'A' && ch <= 'Z') ?
                                (char)(ch - 'A' + 'a') : ch;
            }
            if (strcmp(folded, "cellvalue.txt") == 0 ||
                strcmp(folded, "cellvalue.txt.tmp") == 0) {
                *description = "input filename conflicts with a reserved OCR output name";
                return OCR_ARGUMENT_ERROR;
            }
        }
    }
    prefix = (size_t)(base - input);
    if (prefix > SIZE_MAX - sizeof TemporaryName) {
        *description = "input path is too long";
        return OCR_ARGUMENT_ERROR;
    }
    *output = malloc(prefix + sizeof OutputName);
    *temporary = malloc(prefix + sizeof TemporaryName);
    if (*output == NULL || *temporary == NULL) {
        *description = "cannot allocate output paths";
        return OCR_INPUT_ERROR;
    }
    memcpy(*output, input, prefix);
    memcpy(*output + prefix, OutputName, sizeof OutputName);
    memcpy(*temporary, input, prefix);
    memcpy(*temporary + prefix, TemporaryName, sizeof TemporaryName);
    return OCR_OK;
}

static int RemoveOldFile(const char *path, const char **description)
{
    if (DeleteFileOnly(path) != 0 && errno != ENOENT) {
        *description = "cannot remove a previous OCR output or temporary file";
        return OCR_OUTPUT_ERROR;
    }
    return OCR_OK;
}

static int WriteResult(const char *output, const char *temporary,
                       const OcrResult *result, const char **description)
{
    FILE *stream = fopen(temporary, "wb");
    int status = OCR_OK;
    if (stream == NULL) {
        *description = "cannot create temporary output file";
        return OCR_OUTPUT_ERROR;
    }
    /* Binary mode guarantees one LF even on Windows. Locale is fixed to C
     * by main, so the serialized percentage always uses a decimal point.
     */
    if (fprintf(stream, "d:'%c',%.4f%%\n", result->symbol,
                result->percentage) < 0 || fflush(stream) != 0 || ferror(stream)) {
        *description = "cannot write or flush temporary output file";
        status = OCR_OUTPUT_ERROR;
    }
    if (fclose(stream) != 0 && status == OCR_OK) {
        *description = "cannot close temporary output file";
        status = OCR_OUTPUT_ERROR;
    }
    if (status == OCR_OK && rename(temporary, output) != 0) {
        *description = "cannot publish the completed output file";
        status = OCR_OUTPUT_ERROR;
    }
    if (status != OCR_OK) {
        /* Output is never published before every write and close succeeds.
         * If cleanup itself fails, a .tmp file may remain, never a result.
         */
        (void)DeleteFileOnly(temporary);
    }
    return status;
}

int main(int argc, char *argv[])
{
    OcrCell cell = {0, 0, NULL};
    OcrThresholds thresholds = {0.0, 0.0, 0.0};
    OcrResult result = {' ', 0.0, {0, 0}};
    char *output = NULL;
    char *temporary = NULL;
    const char *description = "unspecified OCR error";
    int status = OCR_OK;

    (void)setlocale(LC_NUMERIC, "C");
    if (argc < 2) {
        status = OCR_ARGUMENT_ERROR;
        description = "usage: OCR <Cell.bin-path> <empty-percent> <zero-percent> <one-percent>";
        goto cleanup;
    }
    status = OutputPaths(argv[1], &output, &temporary, &description);
    if (status != OCR_OK) {
        goto cleanup;
    }
    /* A discoverable input path invalidates the old result even when a
     * subsequent argument, input, recognition or write operation fails.
     */
    status = RemoveOldFile(output, &description);
    if (status != OCR_OK) {
        goto cleanup;
    }
    status = RemoveOldFile(temporary, &description);
    if (status != OCR_OK) {
        goto cleanup;
    }
    if (argc != 5) {
        status = OCR_ARGUMENT_ERROR;
        description = "expected exactly four arguments: input path and three thresholds";
        goto cleanup;
    }
    if (OcrParseThreshold(argv[2], &thresholds.empty) != OCR_OK ||
        OcrParseThreshold(argv[3], &thresholds.zero) != OCR_OK ||
        OcrParseThreshold(argv[4], &thresholds.one) != OCR_OK) {
        status = OCR_ARGUMENT_ERROR;
        description = "thresholds must be ordinary dot-decimal numbers in [0,100]";
        goto cleanup;
    }
    status = OcrReadCell(argv[1], &cell, &description);
    if (status != OCR_OK) {
        goto cleanup;
    }
    status = OcrRecognize(&cell, &thresholds, &result, &description);
    if (status != OCR_OK) {
        goto cleanup;
    }
    status = WriteResult(output, temporary, &result, &description);

cleanup:
    OcrFreeCell(&cell);
    free(output);
    free(temporary);
    if (status != OCR_OK) {
        (void)fprintf(stderr, "OCR E%d: %s\n", status, description);
    }
    return status;
}
