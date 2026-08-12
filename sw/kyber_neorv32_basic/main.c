#include <stdint.h>
#include <neorv32.h>

#include "api.h"
#include "rng.h"

#define BAUD_RATE 19200

enum {
  KYBER_GPIO_RESET         = 0x00,
  KYBER_GPIO_INIT          = 0x10,
  KYBER_GPIO_ENTROPY_READY = 0x20,
  KYBER_GPIO_RNG_READY     = 0x30,
  KYBER_GPIO_KEYPAIR_START = 0x40,
  KYBER_GPIO_KEYPAIR_DONE  = 0x50,
  KYBER_GPIO_ENC_DONE      = 0x60,
  KYBER_GPIO_DEC_DONE      = 0x70,
  KYBER_GPIO_COMPARE       = 0x80,
  KYBER_GPIO_SUCCESS       = 0x01,
  KYBER_GPIO_ERR_KEYPAIR   = 0xA0,
  KYBER_GPIO_ERR_ENC       = 0xB0,
  KYBER_GPIO_ERR_DEC       = 0xC0,
  KYBER_GPIO_ERR_COMPARE   = 0xD0
};

int main(void) {

  neorv32_rte_setup();

  // configure lowest 8 GPIO pins as outputs
  neorv32_gpio_dir_set(0x000000FF);
  neorv32_gpio_port_set(KYBER_GPIO_RESET);
  neorv32_gpio_port_set(KYBER_GPIO_INIT);

  uint8_t entropy[48];
  uint8_t pk[CRYPTO_PUBLICKEYBYTES];
  uint8_t sk[CRYPTO_SECRETKEYBYTES];
  uint8_t ct[CRYPTO_CIPHERTEXTBYTES];
  uint8_t ss_enc[CRYPTO_BYTES];
  uint8_t ss_dec[CRYPTO_BYTES];

  for (unsigned int i = 0; i < sizeof(entropy); i++) {
    entropy[i] = (uint8_t)i;
  }
 neorv32_gpio_port_set(KYBER_GPIO_ENTROPY_READY);

  randombytes_init(entropy, 0, 256);
  neorv32_gpio_port_set(KYBER_GPIO_RNG_READY);

  neorv32_gpio_port_set(KYBER_GPIO_KEYPAIR_START);
  int rc = crypto_kem_keypair(pk, sk);
  if (rc != 0) {
    neorv32_gpio_port_set(KYBER_GPIO_ERR_KEYPAIR);
    return 1;
  }
  neorv32_gpio_port_set(KYBER_GPIO_KEYPAIR_DONE);

  rc = crypto_kem_enc(ct, ss_enc, pk);
  if (rc != 0) {   
    neorv32_gpio_port_set(KYBER_GPIO_ERR_ENC);
    return 1;
  }
  neorv32_gpio_port_set(KYBER_GPIO_ENC_DONE);

  rc = crypto_kem_dec(ss_dec, ct, sk);
  if (rc != 0) {
    neorv32_gpio_port_set(KYBER_GPIO_ERR_DEC);
    return 1;
  }
  neorv32_gpio_port_set(KYBER_GPIO_DEC_DONE);

  rc = 0;
  neorv32_gpio_port_set(KYBER_GPIO_COMPARE);
  for (unsigned int i = 0; i < CRYPTO_BYTES; i++) {
    if (ss_enc[i] != ss_dec[i]) {
      rc = 1;
      break;
    }
  }

  if (rc != 0) {
    neorv32_gpio_port_set(KYBER_GPIO_ERR_COMPARE);
    return rc;
  }

  neorv32_gpio_port_set(KYBER_GPIO_SUCCESS);
  return 0;
}
