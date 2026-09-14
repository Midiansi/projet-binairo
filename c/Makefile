CC ?= cc
CPPFLAGS ?=
CPPFLAGS += -I../course_materials
CFLAGS ?= -O2
CFLAGS += -std=c11 -Wall -Wextra -Wpedantic -Werror -Wvla
LDFLAGS ?=
LDLIBS ?=
BUILD = ../build
HEADERS = ocr.h ocr_policy.h ../course_materials/FontRasterized_0_1.h

.PHONY: all test sanitize clean
all: $(BUILD)/OCR

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/OCR: main.c ocr.c $(HEADERS) | $(BUILD)
	$(CC) $(CPPFLAGS) $(CFLAGS) main.c ocr.c $(LDFLAGS) $(LDLIBS) -o $@

$(BUILD)/test_ocr: test_ocr.c ocr.c $(HEADERS) | $(BUILD)
	$(CC) $(CPPFLAGS) $(CFLAGS) test_ocr.c ocr.c $(LDFLAGS) $(LDLIBS) -o $@

test: $(BUILD)/OCR $(BUILD)/test_ocr
	$(BUILD)/test_ocr

sanitize: | $(BUILD)
	$(CC) $(CPPFLAGS) -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -Wvla -fsanitize=address,undefined -fno-omit-frame-pointer main.c ocr.c -o $(BUILD)/OCR_sanitize
	$(CC) $(CPPFLAGS) -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -Wvla -fsanitize=address,undefined -fno-omit-frame-pointer test_ocr.c ocr.c -o $(BUILD)/test_ocr_sanitize
	$(BUILD)/test_ocr_sanitize

clean:
	rm -f $(BUILD)/OCR $(BUILD)/test_ocr $(BUILD)/OCR_sanitize $(BUILD)/test_ocr_sanitize
