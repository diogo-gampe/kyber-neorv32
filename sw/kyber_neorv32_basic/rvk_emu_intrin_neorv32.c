/*
 * Local wrapper to keep RISCV-crypto's src/sw/common directory out of the
 * NEORV32 VPATH. That directory also contains a crt0.S, which must not shadow
 * NEORV32's startup file.
 */
#include "../../third_party/RISCV-crypto/src/sw/common/rvk_emu_intrin.c"
