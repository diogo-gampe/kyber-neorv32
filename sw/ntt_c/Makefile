KYBER_DIR := ../../third_party/RISCV-crypto/src/sw/common/kyber_round3_ref

CC       := gcc
CPPFLAGS := -I$(KYBER_DIR) -DKYBER_K=2 -DKYBER_NTT_TRACE
CFLAGS   := -O2 -std=c17 -Wall -Wextra -Wpedantic

BUILD_DIR := build
TARGET    := $(BUILD_DIR)/ntt
SOURCES   := main.c $(KYBER_DIR)/ntt.c $(KYBER_DIR)/reduce.c

.PHONY: all run trace clean
.DELETE_ON_ERROR:

all: $(TARGET)

$(BUILD_DIR):
	mkdir -p $@

$(TARGET): $(SOURCES) | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(SOURCES) -o $@

run: $(TARGET)
	./$(TARGET)

trace: $(TARGET)
	./$(TARGET) > $(BUILD_DIR)/ntt_trace.csv
	@echo "Generated $(BUILD_DIR)/ntt_trace.csv"

clean:
	$(RM) -r -- $(BUILD_DIR)
