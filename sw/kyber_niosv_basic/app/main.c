#include <stddef.h>
#include <stdint.h>

#include "system.h"
#include "sys/alt_stdio.h"
#include "sys/alt_timestamp.h"

#ifndef KYBER_K
#define KYBER_K 2
#endif

#include "api.h"
#include "rng.h"

#define ALIGN4 __attribute__((aligned(4)))

static uint8_t entropy_input[48] ALIGN4;
static uint8_t public_key[CRYPTO_PUBLICKEYBYTES] ALIGN4;
static uint8_t secret_key[CRYPTO_SECRETKEYBYTES] ALIGN4;
static uint8_t ciphertext[CRYPTO_CIPHERTEXTBYTES] ALIGN4;
static uint8_t shared_secret_enc[CRYPTO_BYTES] ALIGN4;
static uint8_t shared_secret_dec[CRYPTO_BYTES] ALIGN4;

static void put_u64(uint64_t value) {
  char buffer[21];
  size_t pos = sizeof(buffer);

  buffer[--pos] = '\0';

  do {
    buffer[--pos] = (char)('0' + (value % 10u));
    value /= 10u;
  } while (value != 0u);

  alt_putstr(&buffer[pos]);
}

static void put_hex32(uint32_t value) {
  static const char hex[] = "0123456789abcdef";

  alt_putstr("0x");
  for (int shift = 28; shift >= 0; shift -= 4) {
    alt_putchar(hex[(value >> shift) & 0x0fu]);
  }
}

static void put_metric(const char *label, uint64_t start, uint64_t end) {
  alt_putstr(label);
  alt_putstr(": ");
  put_u64(end - start);
  alt_putstr(" ticks\r\n");
}

static uint8_t ct_compare(const uint8_t *a, const uint8_t *b, size_t len) {
  uint8_t diff = 0u;

  for (size_t i = 0; i < len; i++) {
    diff = (uint8_t)(diff | (uint8_t)(a[i] ^ b[i]));
  }

  return diff;
}

static uint32_t checksum32(const uint8_t *data, size_t len) {
  uint32_t acc = 0x811c9dc5u;

  for (size_t i = 0; i < len; i++) {
    acc ^= data[i];
    acc *= 0x01000193u;
  }

  return acc;
}

static void init_deterministic_entropy(void) {
  for (size_t i = 0; i < sizeof(entropy_input); i++) {
    entropy_input[i] = (uint8_t)(0x42u + (uint8_t)(17u * i));
  }
}

int main(int argc, char **argv, char **envp) {
  (void)argc;
  (void)argv;
  (void)envp;

  int rc;
  uint64_t t_start;
  uint64_t t_rng;
  uint64_t t_keypair;
  uint64_t t_enc;
  uint64_t t_dec;
  uint64_t t_check;

  alt_putstr("\r\n");
  alt_putstr("========================================\r\n");
  alt_putstr(" Kyber KEM - Nios V / JTAG UART\r\n");
  alt_putstr("========================================\r\n");
  alt_putstr("Algorithm: ");
  alt_putstr(CRYPTO_ALGNAME);
  alt_putstr("\r\n");
  alt_putstr("Public key bytes: ");
  put_u64(CRYPTO_PUBLICKEYBYTES);
  alt_putstr("\r\n");
  alt_putstr("Secret key bytes: ");
  put_u64(CRYPTO_SECRETKEYBYTES);
  alt_putstr("\r\n");
  alt_putstr("Ciphertext bytes: ");
  put_u64(CRYPTO_CIPHERTEXTBYTES);
  alt_putstr("\r\n");
  alt_putstr("Shared secret bytes: ");
  put_u64(CRYPTO_BYTES);
  alt_putstr("\r\n");

  if (alt_timestamp_start() != 0) {
    alt_putstr("ERROR: alt_timestamp_start failed\r\n");
    return 1;
  }

  alt_putstr("Timestamp frequency: ");
  put_u64(alt_timestamp_freq());
  alt_putstr(" Hz\r\n\r\n");

  t_start = alt_timestamp();

  init_deterministic_entropy();
  randombytes_init(entropy_input, 0, 256);
  t_rng = alt_timestamp();

  rc = crypto_kem_keypair(public_key, secret_key);
  t_keypair = alt_timestamp();
  if (rc != 0) {
    alt_putstr("ERROR: crypto_kem_keypair failed\r\n");
    return 1;
  }

  rc = crypto_kem_enc(ciphertext, shared_secret_enc, public_key);
  t_enc = alt_timestamp();
  if (rc != 0) {
    alt_putstr("ERROR: crypto_kem_enc failed\r\n");
    return 1;
  }

  rc = crypto_kem_dec(shared_secret_dec, ciphertext, secret_key);
  t_dec = alt_timestamp();
  if (rc != 0) {
    alt_putstr("ERROR: crypto_kem_dec failed\r\n");
    return 1;
  }

  if (ct_compare(shared_secret_enc, shared_secret_dec, CRYPTO_BYTES) != 0u) {
    alt_putstr("ERROR: shared secrets differ\r\n");
    return 1;
  }
  t_check = alt_timestamp();

  alt_putstr("Status: success\r\n");
  alt_putstr("Public key checksum: ");
  put_hex32(checksum32(public_key, CRYPTO_PUBLICKEYBYTES));
  alt_putstr("\r\n");
  alt_putstr("Ciphertext checksum: ");
  put_hex32(checksum32(ciphertext, CRYPTO_CIPHERTEXTBYTES));
  alt_putstr("\r\n\r\n");

  put_metric("RNG initialization", t_start, t_rng);
  put_metric("Keypair", t_rng, t_keypair);
  put_metric("Encapsulation", t_keypair, t_enc);
  put_metric("Decapsulation", t_enc, t_dec);
  put_metric("Shared-secret check", t_dec, t_check);
  put_metric("Total", t_start, t_check);

  alt_putstr("\r\nDone.\r\n");

  return 0;
}
