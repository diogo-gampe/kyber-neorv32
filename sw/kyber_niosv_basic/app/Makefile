# Nios V Kyber application Makefile.
#
# Build from inside niosv-shell or any shell where the Intel RISC-V toolchain is
# available in PATH:
#   make
#   make KYBER_LEVEL=768
#   make load

BSP_DIR ?= ../bsp
RISCV_CRYPTO_HOME ?= ../../../third_party/RISCV-crypto

CROSS_COMPILE ?= riscv-none-elf-
CC      := $(CROSS_COMPILE)gcc
AR      := $(CROSS_COMPILE)ar
OBJDUMP := $(CROSS_COMPILE)objdump
SIZE    := $(CROSS_COMPILE)size

NIOSV_DOWNLOAD ?= niosv-download
JTAG_TERMINAL  ?= juart-terminal

BUILD_DIR ?= build
OBJ_DIR   := $(BUILD_DIR)/obj
ELF       ?= $(BUILD_DIR)/kyber_niosv.elf
MAP       ?= $(BUILD_DIR)/kyber_niosv.map
LDSCRIPT  := $(BSP_DIR)/linker.x

KYBER_LEVEL ?= 512
KYBER_VARIANT ?= fips202

ifeq ($(KYBER_LEVEL),512)
  KYBER_K := 2
else ifeq ($(KYBER_LEVEL),768)
  KYBER_K := 3
else ifeq ($(KYBER_LEVEL),1024)
  KYBER_K := 4
else
  $(error Unsupported KYBER_LEVEL=$(KYBER_LEVEL). Use 512, 768, or 1024)
endif

RC_COMMON_DIR := $(RISCV_CRYPTO_HOME)/src/sw/common
KYBER_DIR     := $(RC_COMMON_DIR)/kyber_round3_ref
KECCAK_DIR    := $(RC_COMMON_DIR)/keccak
TINYCRYPT_DIR := $(RC_COMMON_DIR)/tinycrypt

APP_SRCS := \
  main.c \
  rvk_emu_intrin_niosv.c

KYBER_CORE_SRCS := \
  $(KYBER_DIR)/cbd.c \
  $(KYBER_DIR)/indcpa.c \
  $(KYBER_DIR)/kem.c \
  $(KYBER_DIR)/ntt.c \
  $(KYBER_DIR)/poly.c \
  $(KYBER_DIR)/polyvec.c \
  $(KYBER_DIR)/reduce.c \
  $(KYBER_DIR)/rng.c \
  $(KYBER_DIR)/verify.c

AES_RNG_SRCS := \
  $(TINYCRYPT_DIR)/aes_encrypt_t_table.c \
  $(TINYCRYPT_DIR)/ctr_prng.c \
  $(TINYCRYPT_DIR)/utils.c

ifeq ($(KYBER_VARIANT),fips202)
  SYM_DEFS :=
  SYM_SRCS := \
    $(KYBER_DIR)/symmetric-shake.c \
    $(KECCAK_DIR)/sha3_api.c \
    $(KECCAK_DIR)/sha3_f1600_rvb32.c
else ifeq ($(KYBER_VARIANT),90s)
  SYM_DEFS := -DKYBER_90S=1
  SYM_SRCS := \
    $(KYBER_DIR)/symmetric-aes.c \
    $(KYBER_DIR)/kyber_sha256.c \
    $(KYBER_DIR)/kyber_sha512.c \
    $(TINYCRYPT_DIR)/sha256.c \
    $(TINYCRYPT_DIR)/sha512.c
else
  $(error Unsupported KYBER_VARIANT=$(KYBER_VARIANT). Use fips202 or 90s)
endif

BSP_C_SRCS := \
  $(wildcard $(BSP_DIR)/HAL/src/*.c) \
  $(wildcard $(BSP_DIR)/drivers/src/*.c) \
  $(BSP_DIR)/alt_sys_init.c

# With ALT_NO_EXIT, crt0.S provides a minimal _exit symbol. Keeping alt_exit.c
# in the link creates a duplicate _exit definition.
BSP_C_SRCS := $(filter-out $(BSP_DIR)/HAL/src/alt_exit.c,$(BSP_C_SRCS))

BSP_ASM_SRCS := \
  $(wildcard $(BSP_DIR)/HAL/src/*.S)

TP_SRCS := $(KYBER_CORE_SRCS) $(AES_RNG_SRCS) $(SYM_SRCS)

APP_OBJS     := $(APP_SRCS:%=$(OBJ_DIR)/app/%.o)
BSP_C_OBJS   := $(patsubst ../%,$(OBJ_DIR)/sw/%.o,$(BSP_C_SRCS))
BSP_ASM_OBJS := $(patsubst ../%,$(OBJ_DIR)/sw/%.o,$(BSP_ASM_SRCS))
TP_OBJS      := $(patsubst ../../../%,$(OBJ_DIR)/repo/%.o,$(TP_SRCS))
OBJS         := $(APP_OBJS) $(TP_OBJS) $(BSP_C_OBJS) $(BSP_ASM_OBJS)

INCLUDES := \
  -I. \
  -I$(BSP_DIR) \
  -I$(BSP_DIR)/HAL/inc \
  -I$(BSP_DIR)/drivers/inc \
  -I$(RC_COMMON_DIR) \
  -I$(KYBER_DIR) \
  -I$(KECCAK_DIR) \
  -I$(TINYCRYPT_DIR)

COMMON_DEFS := \
  -DALT_SINGLE_THREADED \
  -DALT_LOG_FLAGS=0 \
  -DALT_NO_C_PLUS_PLUS \
  -DALT_NO_EXIT \
  -D__hal__ \
  -DKYBER_K=$(KYBER_K) \
  -DRVKINTRIN_EMULATE=1 \
  -DTC_AES_256=1 \
  $(SYM_DEFS)

ARCH_FLAGS ?= -march=rv32im_zicsr_zicbom_zifencei -mabi=ilp32
OPT_FLAGS  ?= -Os

CPPFLAGS += $(INCLUDES) $(COMMON_DEFS) -include kyber_niosv_compat.h
CFLAGS   += $(ARCH_FLAGS) $(OPT_FLAGS) -g -Wall -Wformat -ffunction-sections -fdata-sections -fno-stack-protector -MMD -MP
ASFLAGS  += $(ARCH_FLAGS) -g -Wa,-gdwarf2 -MMD -MP
LDFLAGS  += $(ARCH_FLAGS) -nostdlib -T$(LDSCRIPT) -Wl,--gc-sections -Wl,-Map,$(MAP)
LDLIBS   += -lc -lgcc

.PHONY: all clean size disasm load terminal config

all: $(ELF)

$(ELF): $(OBJS) $(LDSCRIPT)
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $@

$(OBJ_DIR)/app/%.c.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/sw/%.c.o: ../%.c
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/sw/%.S.o: ../%.S
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(ASFLAGS) -c $< -o $@

$(OBJ_DIR)/repo/%.c.o: ../../../%.c
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

size: $(ELF)
	$(SIZE) $(ELF)

disasm: $(ELF)
	$(OBJDUMP) -Sdtx $(ELF) > $(BUILD_DIR)/kyber_niosv.objdump

load: $(ELF)
	$(NIOSV_DOWNLOAD) -g $(ELF)

terminal:
	$(JTAG_TERMINAL)

config:
	@echo "BSP_DIR           = $(BSP_DIR)"
	@echo "RISCV_CRYPTO_HOME = $(RISCV_CRYPTO_HOME)"
	@echo "ELF               = $(ELF)"
	@echo "KYBER_LEVEL       = $(KYBER_LEVEL) (KYBER_K=$(KYBER_K))"
	@echo "KYBER_VARIANT     = $(KYBER_VARIANT)"
	@echo "ARCH_FLAGS        = $(ARCH_FLAGS)"
	@echo "APP sources       = $(words $(APP_SRCS))"
	@echo "Third-party srcs  = $(words $(TP_SRCS))"
	@echo "BSP C sources     = $(words $(BSP_C_SRCS))"
	@echo "BSP ASM sources   = $(words $(BSP_ASM_SRCS))"

clean:
	rm -rf $(BUILD_DIR)

-include $(OBJS:.o=.d)
