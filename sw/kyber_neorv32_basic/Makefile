# NEORV32 Makefile para código de referência RISCV-crypto
#
# Configurações públicas:
#   KYBER_LEVEL    = 512 | 768 | 1024
#   KYBER_VARIANT  = fips202 | 90s
#   KYBER_ISE_EXT  = none | zbkb | zkne | zknh 
#
# Examplo:
#   make image
#   make image KYBER_LEVEL=768 KYBER_VARIANT=90s
#   make image KYBER_LEVEL=1024 KYBER_VARIANT=fips202 KYBER_ISE_EXT=zbkb,zknh
#

NEORV32_HOME ?= ../../third_party/neorv32
RISCV_CRYPTO_HOME ?= ../../third_party/RISCV-crypto

RC_COMMON_DIR := $(RISCV_CRYPTO_HOME)/src/sw/common
KYBER_DIR     := $(RC_COMMON_DIR)/kyber_round3_ref
KECCAK_DIR    := $(RC_COMMON_DIR)/keccak
TINYCRYPT_DIR := $(RC_COMMON_DIR)/tinycrypt

# -----------------------------------------------------------------------------
# Parâmetros para oa Kyber e seleção de ISE
# -----------------------------------------------------------------------------
KYBER_LEVEL ?= 512
KYBER_VARIANT ?= fips202
KYBER_ISE_EXT ?= none

comma := ,
empty :=
space := $(empty) $(empty)
KYBER_ISE_EXT_LIST := $(strip $(subst $(comma),$(space),$(KYBER_ISE_EXT)))


HAS_ZBKB := $(if $(filter zbkb Zbkb ZBKB,$(KYBER_ISE_EXT_LIST)),1,0)
HAS_ZKNE := $(if $(filter zkne Zkne ZKNE,$(KYBER_ISE_EXT_LIST)),1,0)
HAS_ZKNH := $(if $(filter zknh Zknh ZKNH,$(KYBER_ISE_EXT_LIST)),1,0)

# -----------------------------------------------------------------------------
# NEORV32
# -----------------------------------------------------------------------------
ROM_SIZE ?= 256k
RAM_SIZE ?= 64k

#Seleciona arquitetura para compilador
BASE_MARCH ?= rv32imc_zicsr_zifencei
STD_ISE_MARCH_SUFFIX := $(if $(filter 1,$(HAS_ZBKB)),_zbkb)$(if $(filter 1,$(HAS_ZKNE)),_zkne)$(if $(filter 1,$(HAS_ZKNH)),_zknh)
MARCH ?= $(BASE_MARCH)$(STD_ISE_MARCH_SUFFIX)

MABI   ?= ilp32
EFFORT ?= -Os

# -----------------------------------------------------------------------------
# Define KYBER_K utilizado nos .c a partir do nível de segurança
# -----------------------------------------------------------------------------
ifeq ($(KYBER_LEVEL),512)
  KYBER_K := 2
else ifeq ($(KYBER_LEVEL),768)
  KYBER_K := 3
else ifeq ($(KYBER_LEVEL),1024)
  KYBER_K := 4
else
  $(error Unsupported KYBER_LEVEL=$(KYBER_LEVEL). Use 512, 768, or 1024)
endif

KYBER_PARAM_DEFS := -DKYBER_K=$(KYBER_K)

# -----------------------------------------------------------------------------
# Seleciona primitivas simétricas a partir da variante
# -----------------------------------------------------------------------------
SYM_DEFS :=
SYM_SRC  :=

ifneq ($(filter fips202 FIPS202 fips FIPS standard STANDARD padrao PADRAO,$(KYBER_VARIANT)),)
  SYM_SRC += $(KYBER_DIR)/symmetric-shake.c
  SYM_SRC += $(KECCAK_DIR)/sha3_api.c
  SYM_SRC += $(KECCAK_DIR)/sha3_f1600_rvb32.c

else ifneq ($(filter 90s 90S,$(KYBER_VARIANT)),)
  SYM_DEFS += -DKYBER_90S=1
  SYM_SRC += $(KYBER_DIR)/symmetric-aes.c
  SYM_SRC += $(KYBER_DIR)/kyber_sha256.c
  SYM_SRC += $(KYBER_DIR)/kyber_sha512.c
  SYM_SRC += $(TINYCRYPT_DIR)/sha256.c
  SYM_SRC += $(TINYCRYPT_DIR)/sha512.c
else
  $(error Unsupported KYBER_VARIANT=$(KYBER_VARIANT). Use fips202 or 90s)
endif

# -----------------------------------------------------------------------------
# Seleciona ISEs
# -----------------------------------------------------------------------------
AES_RNG_DEFS := -DTC_AES_256=1
ISE_DEFS :=
ISE_SRC  :=

ifeq ($(HAS_ZBKB),1)
  ISE_DEFS += -DRVKINTRIN_ASSEMBLER=1
else
  ISE_DEFS += -DRVKINTRIN_EMULATE=1
  ISE_SRC += ./rvk_emu_intrin_neorv32.c
endif

ifeq ($(HAS_ZKNE),1)
  ISE_DEFS += -DAES_RISCV_ASM=1
endif

ifeq ($(HAS_ZKNH),1)
  ISE_DEFS += -DSHA256_ZKNH=1 -DSHA512_ZKNH=1
endif

# -----------------------------------------------------------------------------
# arquivos fonte gerais
# -----------------------------------------------------------------------------
KYBER_CORE_SRC  = $(KYBER_DIR)/cbd.c
KYBER_CORE_SRC += $(KYBER_DIR)/indcpa.c
KYBER_CORE_SRC += $(KYBER_DIR)/kem.c
KYBER_CORE_SRC += $(KYBER_DIR)/ntt.c
KYBER_CORE_SRC += $(KYBER_DIR)/poly.c
KYBER_CORE_SRC += $(KYBER_DIR)/polyvec.c
KYBER_CORE_SRC += $(KYBER_DIR)/reduce.c
KYBER_CORE_SRC += $(KYBER_DIR)/rng.c
KYBER_CORE_SRC += $(KYBER_DIR)/verify.c

AES_RNG_SRC  = $(TINYCRYPT_DIR)/aes_encrypt_t_table.c
AES_RNG_SRC += $(TINYCRYPT_DIR)/ctr_prng.c
AES_RNG_SRC += $(TINYCRYPT_DIR)/utils.c

APP_SRC  = ./main.c
APP_SRC += $(KYBER_CORE_SRC)
APP_SRC += $(AES_RNG_SRC)
APP_SRC += $(SYM_SRC)
APP_SRC += $(ISE_SRC)

APP_INC  = -I .
APP_INC += -I $(RC_COMMON_DIR)
APP_INC += -I $(TINYCRYPT_DIR)
APP_INC += -I $(KYBER_DIR)
APP_INC += -I $(KECCAK_DIR)

APP_DEFS := $(KYBER_PARAM_DEFS) $(SYM_DEFS) $(ISE_DEFS) $(AES_RNG_DEFS)

CFLAGS  += $(APP_DEFS)
CFLAGS  += -include kyber_neorv32_compat.h
LDFLAGS += -Wl,--defsym,__neorv32_rom_size=$(ROM_SIZE)
LDFLAGS += -Wl,--defsym,__neorv32_ram_size=$(RAM_SIZE)

.PHONY: config sources kyber-help
config:
	@echo "NEORV32_HOME       = $(NEORV32_HOME)"
	@echo "RISCV_CRYPTO_HOME = $(RISCV_CRYPTO_HOME)"
	@echo "MARCH             = $(MARCH)"
	@echo "MABI              = $(MABI)"
	@echo "EFFORT            = $(EFFORT)"
	@echo "KYBER_LEVEL       = $(KYBER_LEVEL) (KYBER_K=$(KYBER_K))"
	@echo "KYBER_VARIANT     = $(KYBER_VARIANT)"
	@echo "KYBER_ISE_EXT     = $(KYBER_ISE_EXT_LIST)"
	@echo "ZBKB              = $(HAS_ZBKB)"
	@echo "ZKNE              = $(HAS_ZKNE)"
	@echo "ZKNH              = $(HAS_ZKNH)"
	@echo "ROM_SIZE          = $(ROM_SIZE)"
	@echo "RAM_SIZE          = $(RAM_SIZE)"
	@echo "APP_DEFS          = $(APP_DEFS)"
	@echo "APP_SRC_COUNT     = $(words $(APP_SRC))"

sources:
	@printf '%s\n' $(APP_SRC)

kyber-help:
	@echo "Kyber build options:"
	@echo "  KYBER_LEVEL=512|768|1024"
	@echo "  KYBER_VARIANT=fips202|90s"
	@echo "  KYBER_ISE_EXT=none|zbkb,zkne,zknh"

include $(NEORV32_HOME)/sw/common/common.mk
