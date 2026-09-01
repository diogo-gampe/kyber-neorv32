APP_DIR := app
BSP_DIR := bsp
BUILD_DIR := build

ELF_NAME := kyber_niosv.elf
ELF := $(BUILD_DIR)/$(ELF_NAME)

NIOSV_APP ?= niosv-app
NIOSV_DOWNLOAD ?= niosv-download
CMAKE ?= cmake

COMMON_DIR := ../../third_party/RISCV-crypto/src/sw/common
KYBER_DIR := $(COMMON_DIR)/kyber_round3_ref
KECCAK_DIR := $(COMMON_DIR)/keccak
TINYCRYPT_DIR := $(COMMON_DIR)/tinycrypt

KYBER_SRCS := \
	$(KYBER_DIR)/cbd.c \
	$(KYBER_DIR)/indcpa.c \
	$(KYBER_DIR)/kem.c \
	$(KYBER_DIR)/ntt.c \
	$(KYBER_DIR)/poly.c \
	$(KYBER_DIR)/polyvec.c \
	$(KYBER_DIR)/reduce.c \
	$(KYBER_DIR)/rng.c \
	$(KYBER_DIR)/verify.c \
	$(KYBER_DIR)/symmetric-shake.c

KECCAK_SRCS := \
	$(KECCAK_DIR)/sha3_api.c \
	$(KECCAK_DIR)/sha3_f1600_rvb32.c

TINYCRYPT_SRCS := \
	$(TINYCRYPT_DIR)/aes_encrypt_t_table.c \
	$(TINYCRYPT_DIR)/ctr_prng.c \
	$(TINYCRYPT_DIR)/utils.c

RVK_SRCS := \
	$(COMMON_DIR)/rvk_emu_intrin.c

APP_SRCS := \
	$(APP_DIR)/main.c \
	$(KYBER_SRCS) \
	$(KECCAK_SRCS) \
	$(TINYCRYPT_SRCS) \
	$(RVK_SRCS)

INC_DIRS := \
	$(COMMON_DIR) \
	$(KYBER_DIR) \
	$(KECCAK_DIR) \
	$(TINYCRYPT_DIR)

KYBER_K ?= 2
CMAKE_BUILD_TYPE ?= Release
APP_C_FLAGS ?= -DKYBER_K=$(KYBER_K) -DRVKINTRIN_EMULATE=1 -DTC_AES_256=1
DOWNLOAD_FLAGS ?= -g

empty :=
space := $(empty) $(empty)
comma := ,
comma_list = $(subst $(space),$(comma),$(strip $(1)))

.PHONY: all generate configure build elf load clean distclean help

all: build

generate: $(APP_DIR)/CMakeLists.txt

$(APP_DIR)/CMakeLists.txt: $(APP_DIR)/main.c
	$(NIOSV_APP) \
		-a=$(APP_DIR) \
		-b=$(BSP_DIR) \
		-e=$(ELF_NAME) \
		-s=$(APP_DIR)/main.c \
		-s=$(call comma_list,$(KYBER_SRCS)) \
		-s=$(call comma_list,$(KECCAK_SRCS)) \
		-s=$(call comma_list,$(TINYCRYPT_SRCS)) \
		-s=$(call comma_list,$(RVK_SRCS)) \
		-i=$(call comma_list,$(INC_DIRS))

configure: $(BUILD_DIR)/CMakeCache.txt

$(BUILD_DIR)/CMakeCache.txt: $(APP_DIR)/CMakeLists.txt $(BSP_DIR)/CMakeLists.txt $(BSP_DIR)/toolchain.cmake
	$(CMAKE) \
		-S $(APP_DIR) \
		-B $(BUILD_DIR) \
		-DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
		-DCMAKE_C_FLAGS="$(APP_C_FLAGS)"

build elf: $(ELF)

$(ELF): $(BUILD_DIR)/CMakeCache.txt $(APP_SRCS)
	$(CMAKE) --build $(BUILD_DIR)

load: $(ELF)
	$(NIOSV_DOWNLOAD) $(DOWNLOAD_FLAGS) $(ELF)

clean:
	@if [ -d "$(BUILD_DIR)" ]; then $(CMAKE) --build $(BUILD_DIR) --target clean; fi

distclean:
	rm -rf $(BUILD_DIR) $(APP_DIR)/CMakeLists.txt

help:
	@echo "Targets:"
	@echo "  make generate   - gera app/CMakeLists.txt com niosv-app"
	@echo "  make build      - configura CMake, compila e linka $(ELF)"
	@echo "  make load       - carrega $(ELF) via niosv-download"
	@echo "  make clean      - limpa artefatos do build CMake"
	@echo "  make distclean  - remove build/ e app/CMakeLists.txt"
	@echo
	@echo "Variaveis uteis:"
	@echo "  KYBER_K=2|3|4"
	@echo "  DOWNLOAD_FLAGS=\"-g\""
	@echo "  DOWNLOAD_FLAGS=\"-g --use_openocd\""
