#include <stdint.h>
#include <neorv32.h>

#include "api.h"
#include "rng.h"

#define BAUD_RATE 115200

enum {

  KYBER_GPIO_INIT          = 0x01,
  KYBER_GPIO_ENTROPY_READY = 0x02,
  KYBER_GPIO_RNG_READY     = 0x03,
  KYBER_GPIO_KEYPAIR_START = 0x04,
  KYBER_GPIO_KEYPAIR_DONE  = 0x05,
  KYBER_GPIO_ENC_DONE      = 0x06,
  KYBER_GPIO_DEC_DONE      = 0x07,
  KYBER_GPIO_COMPARE       = 0x08,
  KYBER_GPIO_SUCCESS       = 0x09,
  KYBER_GPIO_ERR_KEYPAIR   = 0x0A,
  KYBER_GPIO_ERR_ENC       = 0x0B,
  KYBER_GPIO_ERR_DEC       = 0x0C,
  KYBER_GPIO_ERR_COMPARE   = 0x0D
};

int main(void) {

  neorv32_rte_setup();
  uint32_t c0, c1, c2, c3, c4, c5;
  uint32_t i0, i1, i2, i3, i4, i5;

  uint32_t cycle_overhead, inst_overhead;
  uint32_t c_cal0, c_cal1;
  uint32_t i_cal0, i_cal1;
  uint32_t cpi_x100;

  c_cal0 = neorv32_cpu_get_cycle();
  c_cal1 = neorv32_cpu_get_cycle();
  cycle_overhead = c_cal1 - c_cal0;

  i_cal0 = neorv32_cpu_get_instret();
  i_cal1 = neorv32_cpu_get_instret();
  inst_overhead = i_cal1 - i_cal0;
  
  // configure lowest 8 GPIO pins as outputs
  neorv32_gpio_dir_set(0x000000FF);
  neorv32_gpio_port_set(KYBER_GPIO_INIT);
  
  //Configure UART0
  neorv32_uart0_setup(BAUD_RATE, 0);

  uint8_t entropy[48];
  uint8_t pk[CRYPTO_PUBLICKEYBYTES];
  uint8_t sk[CRYPTO_SECRETKEYBYTES];
  uint8_t ct[CRYPTO_CIPHERTEXTBYTES];
  uint8_t ss_enc[CRYPTO_BYTES];
  uint8_t ss_dec[CRYPTO_BYTES];

  c0 = neorv32_cpu_get_cycle();
  i0 = neorv32_cpu_get_instret();
  for (unsigned int i = 0; i < sizeof(entropy); i++) {
    entropy[i] = (uint8_t)i;
  }
 
  randombytes_init(entropy, 0, 256);

  c1 = neorv32_cpu_get_cycle();
  i1 = neorv32_cpu_get_instret();
  int rc = crypto_kem_keypair(pk, sk);
  if (rc != 0) {
    return 1;
  }
  
  c2 = neorv32_cpu_get_cycle();
  i2 = neorv32_cpu_get_instret();
  rc = crypto_kem_enc(ct, ss_enc, pk);
  if (rc != 0) {   
    return 1;
  }
  
  c3 = neorv32_cpu_get_cycle();
  i3 = neorv32_cpu_get_instret();
  rc = crypto_kem_dec(ss_dec, ct, sk);
  if (rc != 0) {
    neorv32_gpio_port_set(KYBER_GPIO_ERR_DEC);
    return 1;
  }
  
  rc = 0;
  c4 = neorv32_cpu_get_cycle();
  i4 = neorv32_cpu_get_instret();
  for (unsigned int i = 0; i < CRYPTO_BYTES; i++) {
    if (ss_enc[i] != ss_dec[i]) {
      rc = 1;
      break;
    }
  }

  if (rc != 0) {
    return rc;
  }
  c5 = neorv32_cpu_get_cycle();
  i5 = neorv32_cpu_get_instret();

  neorv32_uart0_printf("<<<<<<<<<< Kyber Execution Results >>>>>>>>>>>\n\n");
  neorv32_uart0_printf("========== Cycle Count Results ===========\n");
  neorv32_uart0_printf("Entropy Initialization Cycle Count: %u\n", (uint32_t)(c1 - c0));
  neorv32_uart0_printf("Keypair Generation Cycle Count: %u\n", (uint32_t)(c2 - c1));
  neorv32_uart0_printf("Kyber Encoding Cycle Count: %u\n", (uint32_t)(c3 - c2));
  neorv32_uart0_printf("Kyber Decoding Cycle Count: %u\n", (uint32_t)(c4 - c3));
  neorv32_uart0_printf("Final Comparison Cycle Count: %u\n", (uint32_t)(c5 - c4));
  neorv32_uart0_printf("Total Kyber Execution Cycle Count: %u\n", (uint32_t)(c5 - c0));
  neorv32_uart0_printf("\nCycle Count Access Overhead: %u\n", (uint32_t)cycle_overhead);

  neorv32_uart0_printf("\n========== Retired Instruction Count Results ===========\n");
  neorv32_uart0_printf("Entropy Initialization Instruction Count: %u\n", (uint32_t)(i1 - i0));
  neorv32_uart0_printf("Keypair Generation Instruction Count: %u\n", (uint32_t)(i2 - i1));
  neorv32_uart0_printf("Kyber Encoding Instruction Count: %u\n", (uint32_t)(i3 - i2));
  neorv32_uart0_printf("Kyber Decoding Instruction Count: %u\n", (uint32_t)(i4 - i3));
  neorv32_uart0_printf("Final Comparison Instruction Count: %u\n", (uint32_t)(i5 - i4));
  neorv32_uart0_printf("Total Kyber Execution Instruction Count: %u\n", (uint32_t)(i5 - i0));
  neorv32_uart0_printf("\nInstruction Count Access Overhead: %u\n", (uint32_t)inst_overhead);
  
  neorv32_uart0_printf("\n========== Cycles per Instruction Results ===========\n");
  cpi_x100 = ((uint32_t)(c1 - c0) * 100u) / (uint32_t)(i1 - i0);
  neorv32_uart0_printf("Entropy Initialization CPI: %u.%u%u\n", cpi_x100 / 100u, (cpi_x100 / 10u) % 10u, cpi_x100 % 10u);
  cpi_x100 = ((uint32_t)(c2 - c1) * 100u) / (uint32_t)(i2 - i1);
  neorv32_uart0_printf("Keypair Generation CPI: %u.%u%u\n", cpi_x100 / 100u, (cpi_x100 / 10u) % 10u, cpi_x100 % 10u);
  cpi_x100 = ((uint32_t)(c3 - c2) * 100u) / (uint32_t)(i3 - i2);
  neorv32_uart0_printf("Kyber Encoding CPI: %u.%u%u\n", cpi_x100 / 100u, (cpi_x100 / 10u) % 10u, cpi_x100 % 10u);
  cpi_x100 = ((uint32_t)(c4 - c3) * 100u) / (uint32_t)(i4 - i3);
  neorv32_uart0_printf("Kyber Decoding CPI: %u.%u%u\n", cpi_x100 / 100u, (cpi_x100 / 10u) % 10u, cpi_x100 % 10u);
  cpi_x100 = ((uint32_t)(c5 - c4) * 100u) / (uint32_t)(i5 - i4);
  neorv32_uart0_printf("Final Comparison CPI: %u.%u%u\n", cpi_x100 / 100u, (cpi_x100 / 10u) % 10u, cpi_x100 % 10u);
  cpi_x100 = ((uint32_t)(c5 - c0) * 100u) / (uint32_t)(i5 - i0);
  neorv32_uart0_printf("Total Kyber Execution CPI: %u.%u%u\n", cpi_x100 / 100u, (cpi_x100 / 10u) % 10u, cpi_x100 % 10u);
  
  return 0;
}
