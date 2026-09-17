IVERILOG ?= iverilog
VVP      ?= vvp
GHDL     ?= ghdl

RTL_DIR   := ../../rtl/kyber_neorv32
BUILD_DIR ?= build

.PHONY: verilog vhdl

# Compila e executa o testbench Verilog com Icarus Verilog.
verilog:
	mkdir -p $(BUILD_DIR)/verilog
	$(IVERILOG) -g2012 -Wall -s pq_alu_tb \
		-o $(BUILD_DIR)/verilog/pq_alu_tb.vvp \
		$(RTL_DIR)/pq_alu.v pq_alu_tb.v
	$(VVP) $(BUILD_DIR)/verilog/pq_alu_tb.vvp

# VHDL-2008 permite acessar o sinal interno do DUT pelo testbench.
vhdl:
	mkdir -p $(BUILD_DIR)/vhdl
	$(GHDL) -a --std=08 --workdir=$(BUILD_DIR)/vhdl \
		$(RTL_DIR)/pq_alu.vhd pq_alu_tb.vhd
	$(GHDL) -e --std=08 --workdir=$(BUILD_DIR)/vhdl pq_alu_tb
	$(GHDL) -r --std=08 --workdir=$(BUILD_DIR)/vhdl pq_alu_tb
