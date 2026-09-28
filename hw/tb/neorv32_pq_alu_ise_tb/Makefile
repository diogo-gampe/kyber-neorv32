NEORV32_HOME ?= ../../../third_party/neorv32
SW_APP_DIR ?= ../../../sw/pq_alu_neorv32_test
IMEM_IMAGE ?= $(SW_APP_DIR)/neorv32_imem_image.vhd
BUILD_DIR ?= ./build
FILE_LIST := $(NEORV32_HOME)/rtl/file_list_soc.f

#Transforma lista fornecida de arquivos de dependência em uma lista de argumentos para ghdl
RTL_FILES_ORIG := $(shell sed \
	-e "s|\$$NEORV32_HOME|$(NEORV32_HOME)|g" \
	-e "s|$(NEORV32_HOME)/rtl/core/neorv32_imem_image.vhd|$(IMEM_IMAGE)|g" \
	$(FILE_LIST))
TOP_FILE ?= neorv32_pq_alu_ise_tb
# Replace the original CFU; analyze PQ-ALU before its direct instantiation.
PQ_RTL_DIR := ../../rtl/kyber_neorv32
RTL_FILES := $(subst $(NEORV32_HOME)/rtl/core/neorv32_cpu_alu_cfu.vhd, $(PQ_RTL_DIR)/fqmul.vhd $(PQ_RTL_DIR)/barret_reduce.vhd $(PQ_RTL_DIR)/pq_alu.vhd $(PQ_RTL_DIR)/neorv32_cpu_alu_cfu.vhd, $(RTL_FILES_ORIG))
GHDL ?= ghdl
GHDL_RUN_FLAGS ?=
VCD ?= 0

SW_USER_FLAGS ?= -DUART0_SIM_MODE

ifeq ($(VCD),1)
  GHDL_VCD_FLAG := --vcd=wave.vcd
else
  GHDL_VCD_FLAG :=
endif

.PHONY: all image analyze elaborate run clean

all: run

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

image:
	$(MAKE) -C $(SW_APP_DIR) image NEORV32_HOME=$(abspath $(NEORV32_HOME)) BUILD_DIR=build APP_VHD=$(abspath $(IMEM_IMAGE)) USER_FLAGS="$(SW_USER_FLAGS)"

analyze: $(BUILD_DIR) image
	@echo "Running analysis on NEORV32 source files..."
	@$(GHDL) -a --std=08 --work=neorv32 --workdir=$(BUILD_DIR) $(RTL_FILES)
	@echo "Running analysis on testbench files..."
	@$(GHDL) -a --std=08 --work=neorv32 --workdir=$(BUILD_DIR) $(TOP_FILE).vhd

elaborate: analyze
	@echo "Running elaboration with top-level: $(TOP_FILE)"
	@$(GHDL) -e --std=08 --work=neorv32 --workdir=$(BUILD_DIR) $(TOP_FILE)

run: elaborate
	@echo "Running simulation with top-level: $(TOP_FILE)"
	@$(GHDL) -r --std=08 --work=neorv32 --workdir=$(BUILD_DIR) $(TOP_FILE) --assert-level=error $(GHDL_VCD_FLAG) $(GHDL_RUN_FLAGS)
clean:
	@$(GHDL) --clean --work=neorv32 --workdir=$(BUILD_DIR)
	rm -f $(BUILD_DIR)/*.o $(BUILD_DIR)/*.cf wave.vcd
