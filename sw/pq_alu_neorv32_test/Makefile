.DEFAULT_GOAL := image
NEORV32_HOME ?= ../../third_party/neorv32
KYBER_HOME ?= ../../third_party/RISCV-crypto
KYBER_DIR := $(KYBER_HOME)/src/sw/common/kyber_round3_ref
TRACE_CSV ?= ../ntt_c/build/ntt_trace.csv
PYTHON ?= python3
BUILD_DIR ?= build
MARCH ?= rv32imc_zicsr_zicntr_zifencei
MABI ?= ilp32
APP_SRC = main.c $(KYBER_DIR)/reduce.c $(KYBER_DIR)/ntt.c
APP_INC = -I ../common -I $(KYBER_DIR) -I $(BUILD_DIR)
# Preserve the reference reduction's intended wrapping signed arithmetic.
CFLAGS += -fwrapv -DKYBER_K=2
LDFLAGS += -Wl,--defsym,__neorv32_rom_size=64k
LDFLAGS += -Wl,--defsym,__neorv32_ram_size=16k

include $(NEORV32_HOME)/sw/common/common.mk

# O common.mk controla recompilacao por timestamps dos fontes, mas mudancas em
# USER_FLAGS nao aparecem nas dependencias dos objetos. Registre as flags para
# invalidar o firmware ao alternar, por exemplo, UART0_SIM_MODE.
USER_FLAGS_STAMP := $(BUILD_DIR)/.user_flags

.PHONY: force_user_flags
force_user_flags:

$(USER_FLAGS_STAMP): force_user_flags | $(BUILD_DIR)
	@printf '%s\n' '$(USER_FLAGS)' | cmp -s - $@ || \
	  printf '%s\n' '$(USER_FLAGS)' > $@

$(OBJ): $(USER_FLAGS_STAMP)
