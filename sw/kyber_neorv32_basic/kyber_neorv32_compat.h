#ifndef KYBER_NEORV32_COMPAT_H
#define KYBER_NEORV32_COMPAT_H

#ifndef __ASSEMBLER__

#include <stddef.h>
#include <stdint.h>

#include "sha3_api.h"

void kyber_shake128_absorb(sha3_ctx_t *state, const uint8_t seed[32], uint8_t x, uint8_t y);
void kyber_shake256(const uint8_t *out, int outlen, const uint8_t *in, int inlen);
void kyber_shake256_prf(uint8_t *out, size_t outlen, const uint8_t key[32], uint8_t nonce);
void sha3_f1600_rvb32(void *s);

#if defined(KYBER_ASCON)
#if defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wcomment"
#endif
#include "permutations.h"
#if defined(__GNUC__)
#pragma GCC diagnostic pop
#endif

void ascon_hash_absorb(ascon_state_t *s_ptr, const unsigned char *m, uint32_t len, int xof);
void ascon_hash_squeeze(ascon_state_t *s_ptr, unsigned char *out, uint32_t len, int xof);
#endif

#endif

#endif
