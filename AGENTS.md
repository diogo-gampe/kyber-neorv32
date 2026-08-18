# Project: Kyber-NeoRV32 Hardware/Software Co-Design & Testing Infrastructure

## 1. Project Overview
This repository contains a robust infrastructure for benchmarking, testing, and experimenting with hardware and software implementations of the CRYSTALS-Kyber post-quantum cryptography algorithm. The target platform is the **NEORV32** processor, a customizable RISC-V SoC.

The infrastructure bridges pure software simulation, cycle-accurate hardware simulation, and physical validation on FPGA development boards. It evaluates both standardized RISC-V Instruction Set Extensions (ISEs) and custom hardware accelerators mapped into the NEORV32 pipeline.

### Core Stack
*   **Processor Core:** NEORV32 (RISC-V 32-bit RV32IMC / RV32B / Custom ISE).
*   **Hardware Description:** VHDL / Verilog (for custom extensions and SoC integration).
*   **Software Stack:** C/C++ (Kyber implementations, benchmark suites, drivers).
*   **Simulation Tools:** GHDL, GTKWave.
*   **FPGA Toolchains:** Intel Quartus Prime Lite 20.1.

### References
* **Oficial NEORV32 documentation: ** https://stnolting.github.io/neorv32/
* **Reference implementation articles: ** ../tese/artigos/

---

## 2. Repository Structure
AI agents must maintain this organizational layout when generating or modifying files:
*   `/hw/`: Custom hardware extensions, accelerator units, modified NEORV32 core files and testbench simulation files.
*   `/sw/`: C source code for Kyber (Ref, Optimized, Custom ISE wrappers) and firmware.
*   `/hw/quartus/`: Quartus project files for implementation.
*   `/hw/rtl/`: Custom hardware extensions and top-level entities
*   `/hw/tb/`: Testbenches for simulation
*   `/docs/`: Architecture diagrams, profiling data, and performance logs.
---

## 3. Build & Test Commands
Always use the following specific commands for automation and validation:

### 3.1. Software Compilation (Cross-Compiling for NEORV32)
```bash
# Clean previous artifacts
make -C ./sw/kyber_neorv32_basic/ clean

# Build firmware and image .vhd using the RISC-V GCC toolchain (configured for RV32)
make -C ./sw/kyber_neorv32_basic image
```

### 3.2. Hardware RTL Simulation
```bash

# Go into testbench directory
cd ./hw/tb/

# Run GHDL simulation to verify RTL correctness
make run

```
---

## 4. Coding & Architecture Rules

### 4.1. Hardware (VHDL / NEORV32 Guidelines)
*   **NEORV32 Pipeline:** Do not alter the core pipeline registers unless explicitly designing a tightly coupled Custom Functions Unit (CFU). Use the dedicated external bus interfaces (like Wishbone or Stream) for large accelerators.
*   **Clock Domains:** Custom hardware extensions must run synchronously with the main processor clock (`clk_i`) unless an asynchronous FIFO bridge is explicitly specified.
*   **Reset:** Use synchronous, active-high resets for core logic matching the NEORV32 standard (`rstn_i` is active-low, adapt accordingly inside modules).

### 4.2. Software (C / Kyber Guidelines)
*   **Memory Management:** Dynamic memory allocation (`malloc`, `free`) is strictly forbidden in the bare-metal environment. Use static arrays.
*   **Alignment:** Ensure that matrices and polynomial coefficients (16-bit integers for Kyber) are strictly aligned to 32-bit boundaries to prevent unaligned access exceptions on RV32.
*   **Inline Assembly:** When implementing Custom ISEs, encapsulate instructions inside `asm volatile` blocks with proper constraints, or use intrinsic macros defined in `sw/common/neorv32_custom_ise.h`.

---

## 5. Security & Edge Cases for AI
*   **Timing Attacks:** Kyber operations must maintain constant-time execution. Never introduce data-dependent branching (`if/else` based on secret keys or polynomial coefficients) in the hardware or software paths.
*   **Resource Constraints:** The NEORV32 typically targets small-to-medium FPGAs. Monitor BRAM and DSP utilization closely. A single custom NTT (Number Theoretic Transform) accelerator must not exhaust the target device's DSP blocks.
*   **Integer Overflow:** Pay close attention to modular reduction steps (Barrett or Montgomery reduction). Ensure intermediate states do not overflow the 32-bit register boundaries.

---

## 6. Infrastructure Roadmap (Verification Flow)
Every new Kyber optimization must pass through this rigorous pipeline:
1.  **Software Functional Check:** Verify algorithm math using standard host GCC.
2.  **Instruction Simulation:** Run on NEORV32 software simulator using golden test vectors.
3.  **RTL Simulation:** Validate execution cycles and data integrity in GHDL/ModelSim.
4.  **FPGA Implementation:** Synthesize, verify timing closure, and extract physical metrics (LUTs, Fmax, energy-per-operation).

