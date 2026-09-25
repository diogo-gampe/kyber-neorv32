#include <neorv32.h>
#include "params.h"
#include "reduce.h"
#include "neorv32_custom_ise.h"


#define BAUDRATE 115200

/* 16 amostras por operacao, extraidas de sw/ntt_c/build/ntt_trace.csv.
 * A/B conservam os 16 bits hexadecimais do CSV. Converter para int16_t
 * antes de operar: por exemplo, 0xfd04 representa -764, nao 64772.
 * Saidas escalares sao estendidas com sinal para 32 bits, como na ISE.
 * Borboletas: primeiro coeficiente em [15:0], segundo em [31:16]. */
#define FQMUL_LEN 16u
#define REDUCE_LEN 16u
#define NTT_LEN 16u
#define INTT_LEN 16u


/* FQMUL: linhas do CSV, na mesma ordem dos vetores abaixo:
 * 262, 534, 806, 1080, 1352, 1626, 1898, 2232, 2640, 3051, 3459, 3870, 4278, 4689, 4860, 4997 */
static const uint32_t a_fqmul_i[FQMUL_LEN] = {
  0x00000a0bu, 0x00000b9au, 0x000005d5u, 0x0000026eu,
  0x000009c4u, 0x00000bc1u, 0x00000284u, 0x0000025bu,
  0x000005bdu, 0x000006bfu, 0x00000629u, 0x0000058eu,
  0x00000b9au, 0x00000a0bu, 0x000006fcu, 0x0000fd76u,
};
static const uint32_t b_fqmul_i[FQMUL_LEN] = {
  0x00000080u, 0x0000fea8u, 0x00000471u, 0x00000fc9u,
  0x0000007bu, 0x0000f71cu, 0x000000dfu, 0x000005e6u,
  0x0000f700u, 0x0000f985u, 0x00000831u, 0x000008cau,
  0x0000f510u, 0x0000fcceu, 0x000005a1u, 0x000005a1u,
};
static const uint32_t r_fqmul_o[FQMUL_LEN] = {
  0x0000063eu, 0x0000052bu, 0x000004acu, 0x0000059eu,
  0xfffffa11u, 0xfffffe92u, 0xfffffae1u, 0xffffff82u,
  0xfffffb2du, 0xfffffc1cu, 0xfffffa77u, 0xfffffd72u,
  0xffffffbau, 0x000001f7u, 0xffffffedu, 0x00000064u,
};

/* REDUCE: linhas do CSV, na mesma ordem dos vetores abaixo:
 * 2054, 2231, 2411, 2591, 2768, 2948, 3128, 3305, 3485, 3665, 3842, 4022, 4202, 4379, 4559, 4739 */
static const uint32_t a_reduce_i[REDUCE_LEN] = {
  0x00002528u, 0x0000007eu, 0x00000704u, 0x0000fef6u,
  0x0000f6edu, 0x00000a6du, 0x000000d0u, 0x00001623u,
  0x0000fe23u, 0x00000b86u, 0x0000fd32u, 0x00000b4eu,
  0x0000082eu, 0x00001081u, 0x0000077eu, 0x0000fe7bu,
};
static const uint32_t r_reduce_o[REDUCE_LEN] = {
  0x00000b26u, 0x0000007eu, 0x00000704u, 0x00000bf7u,
  0x000003eeu, 0x00000a6du, 0x000000d0u, 0x00000922u,
  0x00000b24u, 0x00000b86u, 0x00000a33u, 0x00000b4eu,
  0x0000082eu, 0x00000380u, 0x0000077eu, 0x00000b7cu,
};

/* NTT: linhas do CSV, na mesma ordem dos vetores abaixo:
 * 263, 381, 501, 621, 739, 859, 979, 1097, 1217, 1337, 1455, 1575, 1695, 1813, 1933, 2053 */
static const uint32_t a_ntt_i[NTT_LEN] = {
  0x00000000u, 0x0000003bu, 0x00000077u, 0x0000ffc9u,
  0x0000fb5au, 0x0000fccbu, 0x00000a57u, 0x0000fef2u,
  0x0000fd72u, 0x0000fef6u, 0x00000d5eu, 0x00000147u,
  0x0000fcc4u, 0x00000bccu, 0x00000e67u, 0x0000022au,
};
static const uint32_t b_ntt_i[NTT_LEN] = {
  0x00000080u, 0x000000bbu, 0x000000f7u, 0x00000328u,
  0x0000057cu, 0x0000ff93u, 0x0000fcffu, 0x0000052bu,
  0x0000045au, 0x00000252u, 0x0000ff9fu, 0x00000486u,
  0x0000024fu, 0x0000f8ffu, 0x0000fd9cu, 0x0000ff1cu,
};
static const uint32_t zeta_ntt_i[NTT_LEN] = {
  0x00000a0bu, 0x00000a0bu, 0x00000a0bu, 0x00000b9au,
  0x00000714u, 0x0000058eu, 0x000000cau, 0x00000629u,
  0x0000084fu, 0x0000017fu, 0x000002dcu, 0x000007f4u,
  0x0000033eu, 0x0000034bu, 0x00000449u, 0x0000065cu,
};
static const uint32_t twiddle_ntt_i[NTT_LEN] = {
  0x00000001u, 0x00000001u, 0x00000001u, 0x00000002u,
  0x00000003u, 0x00000005u, 0x00000007u, 0x0000000au,
  0x0000000du, 0x00000013u, 0x0000001au, 0x00000024u,
  0x00000033u, 0x00000043u, 0x00000061u, 0x0000007fu,
};
static const uint32_t r_ntt_o[NTT_LEN] = {
  0xf9c2063eu, 0xfea101d5u, 0xfcc0042eu, 0xfd1b0277u,
  0xf9a9fd0bu, 0xf7f401a2u, 0x08e30bcbu, 0x02d4fb10u,
  0xfe9dfc47u, 0xfa3503b7u, 0x080512b7u, 0xfc590635u,
  0xf998fff0u, 0x08920f06u, 0x14690865u, 0xfbfe0856u,
};

/* INTT: linhas do CSV, na mesma ordem dos vetores abaixo:
 * 2056, 2233, 2413, 2593, 2770, 2950, 3130, 3307, 3487, 3667, 3844, 4024, 4204, 4381, 4561, 4741 */
static const uint32_t a_intt_i[INTT_LEN] = {
  0x0000167eu, 0x0000fd4cu, 0x0000091au, 0x0000fdcfu,
  0x0000fb9du, 0x000002beu, 0x00000010u, 0x00000c84u,
  0x0000fc3au, 0x00000609u, 0x000002bbu, 0x00000637u,
  0x00000471u, 0x000006f9u, 0x0000012du, 0x0000fb61u,
};
static const uint32_t b_intt_i[INTT_LEN] = {
  0x00000eaau, 0x00000332u, 0x0000fdeau, 0x00000127u,
  0x0000fb50u, 0x000007afu, 0x000000c0u, 0x0000099fu,
  0x000001e9u, 0x0000057du, 0x0000fa77u, 0x00000517u,
  0x000003bdu, 0x00000988u, 0x00000651u, 0x0000031au,
};
static const uint32_t zeta_intt_i[INTT_LEN] = {
  0x0000065cu, 0x0000025bu, 0x0000081eu, 0x0000033eu,
  0x000007f4u, 0x000002dcu, 0x0000017fu, 0x0000084fu,
  0x00000629u, 0x000000cau, 0x0000058eu, 0x00000714u,
  0x00000b9au, 0x00000a0bu, 0x00000a0bu, 0x00000a0bu,
};
static const uint32_t twiddle_intt_i[INTT_LEN] = {
  0x0000007fu, 0x00000062u, 0x00000044u, 0x00000033u,
  0x00000024u, 0x0000001au, 0x00000013u, 0x0000000du,
  0x0000000au, 0x00000007u, 0x00000005u, 0x00000003u,
  0x00000002u, 0x00000001u, 0x00000001u, 0x00000001u,
};
static const uint32_t r_intt_o[INTT_LEN] = {
  0x04490b26u, 0xff82007eu, 0xfb900704u, 0x02ec0bf7u,
  0x041303eeu, 0x03dc0a6du, 0x007200d0u, 0x04aa0922u,
  0x049b0b24u, 0x04640b86u, 0xfa380a33u, 0x05fd0b4eu,
  0xf97b082eu, 0x027b0380u, 0x0679077eu, 0xfd760b7cu,
};

/* Guardar resultados permite relatar TODOS os erros somente ao final. */
typedef struct {
  uint32_t base;
  uint32_t ise;
} sample_result;

static sample_result fqmul_results[FQMUL_LEN];
static sample_result reduce_results[REDUCE_LEN];
static sample_result ntt_results[NTT_LEN];
static sample_result intt_results[INTT_LEN];

static uint32_t pack_coefficients(int16_t first, int16_t second) {
  return (uint32_t)(uint16_t)first | ((uint32_t)(uint16_t)second << 16);
}

static uint32_t corrected_cycles(uint32_t start, uint32_t end, uint32_t overhead) {
  uint32_t elapsed = end - start;
  return elapsed > overhead ? elapsed - overhead : 0;
}

int main(void) {
  neorv32_gpio_dir_set(0xffffffffu);
  neorv32_gpio_port_set(0);
  neorv32_uart0_setup(BAUDRATE, 0);
  neorv32_uart0_printf("\r\n =========== Inicando Simulacao ISE PQ_ALU NEORV32 =========== \r\n");

  uint32_t c0, c1, c2, c3, c4;
  uint32_t fqmul_latency = 0, ise_fqmul_latency = 0;
  uint32_t reduce_latency = 0, ise_reduce_latency = 0;
  uint32_t ntt_latency = 0, ise_ntt_latency = 0;
  uint32_t intt_latency = 0, ise_intt_latency = 0;
  uint32_t fqmul_errors = 0, reduce_errors = 0;
  uint32_t ntt_errors = 0, intt_errors = 0;
  uint32_t idx = 0;

  /* Calibra apenas o overhead das duas leituras do contador de ciclos. */
  c0 = (uint32_t)neorv32_cpu_get_cycle();
  c1 = (uint32_t)neorv32_cpu_get_cycle();
  uint32_t cycle_overhead = c1 - c0;

  while (idx < FQMUL_LEN) {
    int32_t a = (int16_t)a_fqmul_i[idx];
    int32_t b = (int16_t)b_fqmul_i[idx];

    c2 = (uint32_t)neorv32_cpu_get_cycle();
    uint32_t result = (uint32_t)(int32_t)montgomery_reduce(a * b);
    
    c3 = (uint32_t)neorv32_cpu_get_cycle();

    uint32_t ise_result = pq_fqmul((uint32_t)a, (uint32_t)b);
   
    c4 = (uint32_t)neorv32_cpu_get_cycle();

    fqmul_results[idx].base = result;
    fqmul_results[idx].ise = ise_result;
    if (result != ise_result || result != r_fqmul_o[idx] ||
        ise_result != r_fqmul_o[idx])
      ++fqmul_errors;
    fqmul_latency += corrected_cycles(c2, c3, cycle_overhead);
    ise_fqmul_latency += corrected_cycles(c3, c4, cycle_overhead);
    ++idx;
  }
  fqmul_latency /= FQMUL_LEN;
  ise_fqmul_latency /= FQMUL_LEN;
  idx = 0;

  while (idx < REDUCE_LEN) {
    int32_t a = (int16_t)a_reduce_i[idx];

    c2 = (uint32_t)neorv32_cpu_get_cycle();
    uint32_t result = (uint32_t)(int32_t)barrett_reduce((int16_t)a);
    c3 = (uint32_t)neorv32_cpu_get_cycle();

    uint32_t ise_result = pq_reduce((uint32_t)a);
    
    c4 = (uint32_t)neorv32_cpu_get_cycle();

    reduce_results[idx].base = result;
    reduce_results[idx].ise = ise_result;
    if (result != ise_result || result != r_reduce_o[idx] ||
        ise_result != r_reduce_o[idx])
      ++reduce_errors;
    reduce_latency += corrected_cycles(c2, c3, cycle_overhead);
    ise_reduce_latency += corrected_cycles(c3, c4, cycle_overhead);
    ++idx;
  }
  reduce_latency /= REDUCE_LEN;
  ise_reduce_latency /= REDUCE_LEN;
  idx = 0;

  while (idx < NTT_LEN) {
    int32_t a = (int16_t)a_ntt_i[idx];
    int32_t b = (int16_t)b_ntt_i[idx];

    c2 = (uint32_t)neorv32_cpu_get_cycle();
   
    int32_t zeta = (int16_t)zeta_ntt_i[idx];
    int16_t t = montgomery_reduce(zeta * b);
    uint32_t result = pack_coefficients((int16_t)(a + t),
                                        (int16_t)(a - t));
   
    c3 = (uint32_t)neorv32_cpu_get_cycle();
   
    (void)pq_set_twiddle(twiddle_ntt_i[idx]);
    uint32_t ise_result = pq_ntt((uint32_t)a, (uint32_t)b);
   
    c4 = (uint32_t)neorv32_cpu_get_cycle();

    ntt_results[idx].base = result;
    ntt_results[idx].ise = ise_result;
    if (result != ise_result || result != r_ntt_o[idx] ||
        ise_result != r_ntt_o[idx])
      ++ntt_errors;
    ntt_latency += corrected_cycles(c2, c3, cycle_overhead);
    ise_ntt_latency += corrected_cycles(c3, c4, cycle_overhead);
    ++idx;
  }
  ntt_latency /= NTT_LEN;
  ise_ntt_latency /= NTT_LEN;
  idx = 0;

  while (idx < INTT_LEN) {
    int32_t a = (int16_t)a_intt_i[idx];
    int32_t b = (int16_t)b_intt_i[idx];

    c2 = (uint32_t)neorv32_cpu_get_cycle();
   
    int32_t zeta = (int16_t)zeta_intt_i[idx];
    int16_t sum = (int16_t)(a + b);
    int16_t difference = (int16_t)(b - a);
    int16_t first = barrett_reduce(sum);
    int16_t second = montgomery_reduce(zeta * difference);
    uint32_t result = pack_coefficients(first, second);
   
    c3 = (uint32_t)neorv32_cpu_get_cycle();
   
    (void)pq_set_twiddle(twiddle_intt_i[idx]);
    uint32_t ise_result = pq_intt((uint32_t)a, (uint32_t)b);
    
    c4 = (uint32_t)neorv32_cpu_get_cycle();

    intt_results[idx].base = result;
    intt_results[idx].ise = ise_result;
    
    if (result != ise_result || result != r_intt_o[idx] ||
        ise_result != r_intt_o[idx])
      ++intt_errors;
    intt_latency += corrected_cycles(c2, c3, cycle_overhead);
    ise_intt_latency += corrected_cycles(c3, c4, cycle_overhead);
    ++idx;
  }
  
  intt_latency /= INTT_LEN;
  ise_intt_latency /= INTT_LEN;

  uint16_t total_errors = fqmul_errors + reduce_errors + ntt_errors + intt_errors;
  uint8_t pass = (total_errors != 0) ? 0 : 1;

  neorv32_uart0_printf("========= Resumo Teste com implementacao base NEORV32 ==============\r\n");
  neorv32_uart0_printf("Número medio de ciclos sem ISE p/ FQMUL: %d\n", fqmul_latency);
  neorv32_uart0_printf("Número medio de ciclos sem ISE p/ REDUCE: %d\n", reduce_latency);
  neorv32_uart0_printf("Número medio de ciclos sem ISE p/ Butt. CT: %d\n", ntt_latency);
  neorv32_uart0_printf("Número medio de ciclos sem ISE p/ Butt. GS: %d\n", intt_latency);

  neorv32_uart0_printf("\r\n========= Resumo Teste com implementacao de ISE NEORV32 ==============\r\n");
  neorv32_uart0_printf("Número medio de ciclos com ISE p/ FQMUL: %d\n", ise_fqmul_latency);
  neorv32_uart0_printf("Número medio de ciclos com ISE p/ REDUCE: %d\n", ise_reduce_latency);
  neorv32_uart0_printf("Número medio de ciclos com ISE p/ Butt. CT: %d\n", ise_ntt_latency);
  neorv32_uart0_printf("Número medio de ciclos com ISE p/ Butt. GS: %d\n", ise_intt_latency);
  neorv32_uart0_printf("Overhead da medicao: ciclos=%d\n", cycle_overhead);

  neorv32_uart0_printf("\r\n========= RESUMO ==============\r\n");
  neorv32_uart0_printf("Erros: %d\n", total_errors);

  if (pass)
    neorv32_uart0_printf("===============  [PASS] SUCESSO! ===========\n");
  else
    neorv32_uart0_printf("===============  [FAIL] FALHA! ==============\n");

  for (;;) { }
  return 0;
}
