# Kyber NEORV32

Projeto de integracao do algoritmo Kyber com um SoC NEORV32 para experimentos em RISC-V, simulacao e sintese FPGA.

O repositorio combina uma aplicacao embarcada em C, um top-level de hardware para o NEORV32 e um testbench VHDL. As dependencias externas sao mantidas como submodulos Git em `third_party/`.

## Estrutura

- `sw/kyber_neorv32_basic/`: aplicacao Kyber para NEORV32 e Makefile de compilacao.
- `hw/rtl/`: top-level Verilog do projeto.
- `hw/tb/`: testbench VHDL e Makefile para GHDL.
- `hw/quartus/`: projeto Quartus.
- `third_party/neorv32/`: submodulo do NEORV32.
- `third_party/RISCV-crypto/`: submodulo com implementacoes criptograficas RISC-V.

## Submodulos

Ao clonar o repositorio:

```sh
git clone --recurse-submodules <url-do-repositorio>
```

Se o clone ja foi feito sem submodulos:

```sh
git submodule update --init --recursive
```

## Build e simulacao

Gerar a imagem VHDL da memoria de instrucoes:

```sh
make -C sw/kyber_neorv32_basic image
```

Rodar o testbench:

```sh
make -C hw/tb run
```

A imagem `neorv32_imem_image.vhd` e gerada no diretorio da aplicacao e consumida pelo testbench e pelo projeto Quartus, sem modificar o submodulo `third_party/neorv32`.
