# NEORV32 application Makefile for Kyber from the RISCV-crypto tree.
#
# Configuration is split into layers:
#   1. Kyber parameter set:       Kyber512 / Kyber768 / Kyber1024
#   2. Symmetric primitive set:   SHAKE/Keccak / Kyber90s / TurboSHAKE / ASCON
#   3. Implementation backend:    C, standard RISC-V crypto, or custom ISE
#   4. NEORV32 platform knobs:    ISA string, ABI, linker memory sizes
#
# The NEORV32 common.mk still owns the toolchain, linker script and image
# generation. This file only selects sources and turns the knobs below into
# preprocessor defines.

NEORV32_HOME ?= ../../third_party/neorv32
RISCV_CRYPTO_HOME ?= ../../third_party/RISCV-crypto

RC_COMMON_DIR := $(RISCV_CRYPTO_HOME)/src/sw/common
KYBER_DIR     := $(RC_COMMON_DIR)/kyber_round3_ref
KECCAK_DIR    := $(RC_COMMON_DIR)/keccak
TINYCRYPT_DIR := $(RC_COMMON_DIR)/tinycrypt
ASCON_DIR     := $(RC_COMMON_DIR)/ascon

# -----------------------------------------------------------------------------
# 1. Parametros do Kyber
# -----------------------------------------------------------------------------
# KYBER_STRENGTH Seleciona Nível de Segurança e gera define KYBER_K
#   512  -> KYBER_K=2
#   768  -> KYBER_K=3
#   1024 -> KYBER_K=4
KYBER_STRENGTH ?= 512

# -----------------------------------------------------------------------------
# 2. Conjunto de primitivas simétricas utilizadas pelo Kyber
# -----------------------------------------------------------------------------
# KYBER_SYM values:
#   90s        -> XOF/PRF = AES-256-CTR, hash/KDF = SHA-256/SHA-512
#   shake      -> XOF/PRF = SHAKE, hash/KDF = SHA3/SHAKE
#   turboshake -> TurboSHAKE/Keccak 
#   ascon      -> ASCON hash/XOF 
#
KYBER_SYM ?= 90s

# Permite chamar make TURBOSHAKE= sem disparar erro por valor vazio.
TURBOSHAKE ?= 0

# Kyber90s espera AES-256.
AES ?= 256

# -----------------------------------------------------------------------------
# 3. Varivéis para selecionar implementações
# -----------------------------------------------------------------------------

# Seleção de extensões já padronizadas
#   AES_ASM=1     -> Utiliza instruções aes32* 
#   SHA*_ZKNH=1   -> Utiliza instruções sha* instructions
#   ZBKB=1        -> Utiliza instruções de manipulações de bit

# É preciso setar no top-level da CPU a implementação das extensões
AES_ASM     ?= 0
SHA256_ZKNH ?= 0
SHA512_ZKNH ?= 0
ZBKB ?= 1

# ISEs propostas em Gewehr et. al
#   KYBER_ISE=1 -> Instruções aritmética do Kyber
#   ASCON_ISE=1 -> Instruções aritmética do Kyber
KYBER_ISE ?= 0
ASCON_ISE ?= 0

# -----------------------------------------------------------------------------
# 4. Plataforma NEORV32
# -----------------------------------------------------------------------------
ROM_SIZE ?= 256k
RAM_SIZE ?= 64k
MARCH  ?= rv32imc_zicsr_zifencei_zbkb_zbkc_zbkx_zkne_zknh
MABI   ?= ilp32
EFFORT ?= -Os

# -----------------------------------------------------------------------------
# Defines a partir dos parâmetros e variantes selecionados
# -----------------------------------------------------------------------------
ifeq ($(KYBER_STRENGTH),512)
  KYBER_K := 2
else ifeq ($(KYBER_STRENGTH),768)
  KYBER_K := 3
else ifeq ($(KYBER_STRENGTH),1024)
  KYBER_K := 4
else
  $(error Unsupported KYBER_STRENGTH=$(KYBER_STRENGTH). Use 512, 768, or 1024)
endif

KYBER_PARAM_DEFS := -DKYBER_K=$(KYBER_K)

# -----------------------------------------------------------------------------
# Seleção das primitivas selecionadas, gera os defines e inclui .c associados
# -----------------------------------------------------------------------------
SYM_DEFS :=
SYM_SRC  :=

ifneq ($(filter 90s 90S,$(KYBER_SYM)),)
  KYBER_SYM_CANON := 90s
  TURBOSHAKE_EFFECTIVE := $(TURBOSHAKE)
  SYM_DEFS += -DKYBER_90S=1
  SYM_XOF   := AES-256-CTR
  SYM_PRF   := AES-256-CTR
  SYM_HASHH := SHA-256
  SYM_HASHG := SHA-512
  SYM_KDF   := SHA-256
  SYM_SRC += $(KYBER_DIR)/symmetric-aes.c
  SYM_SRC += $(KYBER_DIR)/kyber_sha256.c
  SYM_SRC += $(KYBER_DIR)/kyber_sha512.c
  SYM_SRC += $(TINYCRYPT_DIR)/sha256.c
  SYM_SRC += $(TINYCRYPT_DIR)/sha512.c
else ifneq ($(filter shake SHAKE keccak KECCAK,$(KYBER_SYM)),)
  KYBER_SYM_CANON := shake
  TURBOSHAKE_EFFECTIVE := $(TURBOSHAKE)
  SYM_XOF   := SHAKE128
  SYM_PRF   := SHAKE256
  SYM_HASHH := SHA3-256
  SYM_HASHG := SHA3-512
  SYM_KDF   := SHAKE256
  SYM_SRC += $(KYBER_DIR)/symmetric-shake.c
  SYM_SRC += $(KECCAK_DIR)/sha3_api.c
  SYM_SRC += $(KECCAK_DIR)/sha3_f1600_rvb32.c
else ifneq ($(filter turboshake TURBOSHAKE,$(KYBER_SYM)),)
  KYBER_SYM_CANON := turboshake
  TURBOSHAKE_EFFECTIVE := 1
  SYM_XOF   := TurboSHAKE128
  SYM_PRF   := TurboSHAKE256
  SYM_HASHH := TurboSHAKE256/32
  SYM_HASHG := TurboSHAKE256/64
  SYM_KDF   := TurboSHAKE256
  SYM_SRC += $(KYBER_DIR)/symmetric-shake.c
  SYM_SRC += $(KECCAK_DIR)/sha3_api.c
  SYM_SRC += $(KECCAK_DIR)/sha3_f1600_rvb32.c
else ifneq ($(filter ascon ASCON,$(KYBER_SYM)),)
  KYBER_SYM_CANON := ascon
  TURBOSHAKE_EFFECTIVE := $(TURBOSHAKE)
  SYM_DEFS += -DKYBER_ASCON=1
  SYM_XOF   := ASCON-XOF
  SYM_PRF   := ASCON-XOF
  SYM_HASHH := ASCON-XOF/32
  SYM_HASHG := ASCON-XOF/64
  SYM_KDF   := ASCON-XOF
  SYM_SRC += $(KYBER_DIR)/symmetric-ascon.c
  SYM_SRC += $(ASCON_DIR)/ascon_hash.c
  SYM_SRC += $(ASCON_DIR)/permutations.c
else
  $(error Unsupported KYBER_SYM=$(KYBER_SYM). Use 90s, shake, turboshake, or ascon)
endif

ifeq ($(KYBER_SYM_CANON),ascon)
  ifneq ($(KYBER_K),2)
    $(error KYBER_SYM=ascon is only supported with KYBER_STRENGTH=512)
  endif
endif

ifeq ($(TURBOSHAKE_EFFECTIVE),1)
  ifeq ($(filter shake turboshake,$(KYBER_SYM_CANON)),)
    $(error TURBOSHAKE=1 only applies to KYBER_SYM=shake/keccak/turboshake)
  endif
  SYM_DEFS += -DTURBOSHAKE=1
  ifeq ($(KYBER_SYM_CANON),shake)
    SYM_XOF   := TurboSHAKE128
    SYM_PRF   := TurboSHAKE256
    SYM_HASHH := TurboSHAKE256/32
    SYM_HASHG := TurboSHAKE256/64
    SYM_KDF   := TurboSHAKE256
  endif
else ifneq ($(TURBOSHAKE_EFFECTIVE),0)
  $(error Unsupported TURBOSHAKE=$(TURBOSHAKE). Use 0 or 1)
endif

# -----------------------------------------------------------------------------
# Gera defines da implementação
# -----------------------------------------------------------------------------
IMPL_DEFS :=
IMPL_SRC  :=

ifeq ($(AES),128)
  IMPL_DEFS += -DTC_AES_128=1
else ifeq ($(AES),192)
  IMPL_DEFS += -DTC_AES_192=1
else ifeq ($(AES),256)
  IMPL_DEFS += -DTC_AES_256=1
else
  $(error Unsupported AES=$(AES). Use 128, 192, or 256)
endif

ifeq ($(ZBKB),1)
  IMPL_DEFS += -DRVKINTRIN_ASSEMBLER=1
else ifeq ($(ZBKB),0)
  IMPL_DEFS += -DRVKINTRIN_EMULATE=1
  IMPL_SRC += ./rvk_emu_intrin_neorv32.c
else
  $(error Unsupported ZBKB=$(ZBKB). Use 0 or 1)
endif

ifeq ($(AES_ASM),1)
  IMPL_DEFS += -DAES_RISCV_ASM=1
else ifneq ($(AES_ASM),0)
  $(error Unsupported AES_ASM=$(AES_ASM). Use 0 or 1)
endif

ifeq ($(SHA256_ZKNH),1)
  IMPL_DEFS += -DSHA256_ZKNH=1
else ifneq ($(SHA256_ZKNH),0)
  $(error Unsupported SHA256_ZKNH=$(SHA256_ZKNH). Use 0 or 1)
endif

ifeq ($(SHA512_ZKNH),1)
  IMPL_DEFS += -DSHA512_ZKNH=1
else ifneq ($(SHA512_ZKNH),0)
  $(error Unsupported SHA512_ZKNH=$(SHA512_ZKNH). Use 0 or 1)
endif

ifeq ($(KYBER_ISE),1)
  IMPL_DEFS += -DKYBER_ISE=1
else ifneq ($(KYBER_ISE),0)
  $(error Unsupported KYBER_ISE=$(KYBER_ISE). Use 0 or 1)
endif

ifeq ($(ASCON_ISE),1)
  ifneq ($(KYBER_SYM_CANON),ascon)
    $(error ASCON_ISE=1 requires KYBER_SYM=ascon)
  endif
  IMPL_DEFS += -DASCON_ISE=1
else ifneq ($(ASCON_ISE),0)
  $(error Unsupported ASCON_ISE=$(ASCON_ISE). Use 0 or 1)
endif

ifneq ($(CUSTOM_BINUTILS_PREFIX),)
  USER_FLAGS += -B$(CUSTOM_BINUTILS_PREFIX)
endif

# -----------------------------------------------------------------------------
# Lista de fontes padrão
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
APP_SRC += $(IMPL_SRC)

APP_INC  = -I .
APP_INC += -I $(RC_COMMON_DIR)
APP_INC += -I $(TINYCRYPT_DIR)
APP_INC += -I $(KYBER_DIR)
APP_INC += -I $(KECCAK_DIR)
APP_INC += -I $(ASCON_DIR)

APP_DEFS := $(KYBER_PARAM_DEFS) $(SYM_DEFS) $(IMPL_DEFS)

CFLAGS  += $(APP_DEFS)
CFLAGS  += -include kyber_neorv32_compat.h
LDFLAGS += -Wl,--defsym,__neorv32_rom_size=$(ROM_SIZE)
LDFLAGS += -Wl,--defsym,__neorv32_ram_size=$(RAM_SIZE)

.PHONY: config sources
config:
	@echo "NEORV32_HOME            = $(NEORV32_HOME)"
	@echo "RISCV_CRYPTO_HOME      = $(RISCV_CRYPTO_HOME)"
	@echo "MARCH                  = $(MARCH)"
	@echo "MABI                   = $(MABI)"
	@echo "EFFORT                 = $(EFFORT)"
	@echo "KYBER_STRENGTH         = $(KYBER_STRENGTH) (KYBER_K=$(KYBER_K))"
	@echo "KYBER_SYM              = $(KYBER_SYM_CANON)"
	@echo "TURBOSHAKE             = $(TURBOSHAKE_EFFECTIVE)"
	@echo "XOF                    = $(SYM_XOF)"
	@echo "PRF                    = $(SYM_PRF)"
	@echo "hash_h                 = $(SYM_HASHH)"
	@echo "hash_g                 = $(SYM_HASHG)"
	@echo "KDF                    = $(SYM_KDF)"
	@echo "AES                    = $(AES)"
	@echo "ZBKB                   = $(ZBKB)"
	@echo "AES_ASM                = $(AES_ASM)"
	@echo "SHA256_ZKNH            = $(SHA256_ZKNH)"
	@echo "SHA512_ZKNH            = $(SHA512_ZKNH)"
	@echo "KYBER_ISE              = $(KYBER_ISE)"
	@echo "ASCON_ISE              = $(ASCON_ISE)"
	@echo "CUSTOM_BINUTILS_PREFIX = $(CUSTOM_BINUTILS_PREFIX)"
	@echo "ROM_SIZE               = $(ROM_SIZE)"
	@echo "RAM_SIZE               = $(RAM_SIZE)"
	@echo "KYBER_PARAM_DEFS       = $(KYBER_PARAM_DEFS)"
	@echo "SYM_DEFS               = $(SYM_DEFS)"
	@echo "IMPL_DEFS              = $(IMPL_DEFS)"
	@echo "APP_DEFS               = $(APP_DEFS)"
	@echo "APP_SRC_COUNT          = $(words $(APP_SRC))"

sources:
	@printf '%s\n' $(APP_SRC)

include $(NEORV32_HOME)/sw/common/common.mk
