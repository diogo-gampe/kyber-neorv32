cmake_minimum_required(VERSION 3.14)

add_subdirectory(../bsp bsp)

include(../bsp/toolchain.cmake)

project(kyber_niosv)

enable_language(ASM)
enable_language(C)
enable_language(CXX)

add_executable(kyber_niosv.elf)

target_sources(kyber_niosv.elf
    PRIVATE
        main.c
        ../../../third_party/RISCV-crypto/src/sw/common/kyber_round3_ref/cbd.c
        ../../../third_party/RISCV-crypto/src/sw/common/kyber_round3_ref/indcpa.c
        ../../../third_party/RISCV-crypto/src/sw/common/kyber_round3_ref/kem.c
        ../../../third_party/RISCV-crypto/src/sw/common/kyber_round3_ref/ntt.c
        ../../../third_party/RISCV-crypto/src/sw/common/kyber_round3_ref/poly.c
        ../../../third_party/RISCV-crypto/src/sw/common/kyber_round3_ref/polyvec.c
        ../../../third_party/RISCV-crypto/src/sw/common/kyber_round3_ref/reduce.c
        ../../../third_party/RISCV-crypto/src/sw/common/kyber_round3_ref/rng.c
        ../../../third_party/RISCV-crypto/src/sw/common/kyber_round3_ref/verify.c
        ../../../third_party/RISCV-crypto/src/sw/common/kyber_round3_ref/symmetric-shake.c
        ../../../third_party/RISCV-crypto/src/sw/common/keccak/sha3_api.c
        ../../../third_party/RISCV-crypto/src/sw/common/keccak/sha3_f1600_rvb32.c
        ../../../third_party/RISCV-crypto/src/sw/common/tinycrypt/aes_encrypt_t_table.c
        ../../../third_party/RISCV-crypto/src/sw/common/tinycrypt/ctr_prng.c
        ../../../third_party/RISCV-crypto/src/sw/common/tinycrypt/utils.c
        ../../../third_party/RISCV-crypto/src/sw/common/rvk_emu_intrin.c
)

target_include_directories(kyber_niosv.elf
    PRIVATE
        ../../../third_party/RISCV-crypto/src/sw/common
        ../../../third_party/RISCV-crypto/src/sw/common/kyber_round3_ref
        ../../../third_party/RISCV-crypto/src/sw/common/keccak
        ../../../third_party/RISCV-crypto/src/sw/common/tinycrypt
    PUBLIC
)

target_link_libraries(kyber_niosv.elf
    PRIVATE
        -T "${BspLinkerScript}" -nostdlib
        "${ExtraArchiveLibraries}"
        -Wl,--start-group "${BspLibraryName}" -lc -lstdc++ -lgcc -lm -Wl,--end-group
)

# Create objdump from ELF.
set(objdump kyber_niosv.elf.objdump)
add_custom_command(
    OUTPUT "${objdump}"
    DEPENDS kyber_niosv.elf
    COMMAND "${ToolchainObjdump}" "${ToolchainObjdumpFlags}" kyber_niosv.elf >
            "${objdump}"
    COMMENT "Creating ${objdump}."
    VERBATIM
)
add_custom_target(create-objdump ALL DEPENDS "${objdump}")

# Report space free for stack + heap. Note that the file below is never created
# so the report is always output on build.
set(stack_report_file kyber_niosv.elf.stack_report)
add_custom_command(
    OUTPUT "${stack_report_file}"
    DEPENDS kyber_niosv.elf
    COMMAND niosv-stack-report -p "${ToolchainPrefix}" kyber_niosv.elf
    COMMENT "Reporting memory available for stack + heap in kyber_niosv.elf."
    VERBATIM
)
add_custom_target(niosv-stack-report ALL DEPENDS "${stack_report_file}")

# Generate HEX file(s) from kyber_niosv.elf using elf2hex tool.
# Note : If ECC Full is enabled, width of 39 is set for NiosV TCM. Otherwise, 32.
add_custom_command(
    OUTPUT "onchip_memory2_0.hex"
    DEPENDS kyber_niosv.elf
    COMMAND elf2hex kyber_niosv.elf -o onchip_memory2_0.hex -b 0x00000000 -w 32 -e 0x0001FFFF -r 4
    COMMENT "Creating onchip_memory2_0.hex."
    VERBATIM
)
add_custom_target(create-hex ALL DEPENDS "onchip_memory2_0.hex")
