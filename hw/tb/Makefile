NEORV32_HOME ?= ../../third_party/neorv32
SW_APP_DIR ?= ../../sw/kyber_neorv32_basic
IMEM_IMAGE ?= $(SW_APP_DIR)/neorv32_imem_image.vhd
BUILD_DIR ?= ./build
FILE_LIST := $(NEORV32_HOME)/rtl/file_list_soc.f

#Transforma lista fornecida de arquivos de dependência em uma lista de argumentos para ghdl
RTL_FILES := $(shell sed \
	-e "s|\$$NEORV32_HOME|$(NEORV32_HOME)|g" \
	-e "s|$(NEORV32_HOME)/rtl/core/neorv32_imem_image.vhd|$(IMEM_IMAGE)|g" \
	$(FILE_LIST))
TOP_FILE ?= neorv32_kyber_tb

.PHONY: all image analyze elaborate run clean

all: run

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

image:
	$(MAKE) -C $(SW_APP_DIR) image

$(IMEM_IMAGE):
	$(MAKE) -C $(SW_APP_DIR) image

analyze: $(BUILD_DIR) $(IMEM_IMAGE)
	@echo "Running analysis on NEORV32 source files..."
	@ghdl -a --std=08 --work=neorv32 --workdir=$(BUILD_DIR) $(RTL_FILES)
	@echo "Running analysis on testbench files..."
	@ghdl -a --std=08 --work=neorv32 --workdir=$(BUILD_DIR) ./*.vhd

elaborate: analyze
	@echo "Running elaboration with top-level: $(TOP_FILE)"
	@ghdl -e --std=08 --work=neorv32 --workdir=$(BUILD_DIR) $(TOP_FILE)

run: elaborate
	@echo "Running simulation with top-level: $(TOP_FILE)"
	@ghdl -r --std=08 --work=neorv32 --workdir=$(BUILD_DIR) $(TOP_FILE) --vcd=wave.vcd
clean:
	@ghdl --clean --work=neorv32 --workdir=$(BUILD_DIR)
	rm -f $(BUILD_DIR)/*.o $(BUILD_DIR)/*.cf wave.vcd
