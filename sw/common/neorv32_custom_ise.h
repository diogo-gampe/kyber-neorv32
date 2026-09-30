#ifndef NEORV32_CUSTOM_ISE_H
#define NEORV32_CUSTOM_ISE_H

#include <stdint.h>
#include <neorv32_intrinsics.h>

static inline uint32_t pq_fqmul(uint32_t a, uint32_t b) {
  return RISCV_INSTR_R_TYPE(RISCV_OPCODE_CUSTOM0, 0, 0, a, b);
}
static inline uint32_t pq_reduce(uint32_t a) {
  return RISCV_INSTR_R_TYPE(RISCV_OPCODE_CUSTOM0, 0, 1, a, 0);
}
static inline uint32_t pq_set_twiddle(uint32_t index) {
  return RISCV_INSTR_R_TYPE(RISCV_OPCODE_CUSTOM0, 0, 2, index, 0);
}
static inline uint32_t pq_ntt(uint32_t a, uint32_t b) {
  return RISCV_INSTR_R_TYPE(RISCV_OPCODE_CUSTOM0, 0, 3, a, b);
}
static inline uint32_t pq_intt(uint32_t a, uint32_t b) {
  return RISCV_INSTR_R_TYPE(RISCV_OPCODE_CUSTOM0, 0, 4, a, b);
}
#endif
