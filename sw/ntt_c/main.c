// SPDX-License-Identifier: CC0-1.0

#include <stdint.h>
#include <stdio.h>

#include "ntt.h"

static unsigned int fqmul_call_count;
static unsigned int butterfly_call_count;
static unsigned int ibutterfly_call_count;
static unsigned int barret_reduce_call_count;
/*
 * Instrumentation hook called by fqmul() when KYBER_NTT_TRACE is enabled.
 * Format: FQMUL,call,a_dec,a_hex,b_dec,b_hex,result_dec,result_hex
 */
void kyber_trace_fqmul(int16_t a, int16_t b, int16_t result)
{
  printf("FQMUL,call_count=%u,a=%04x,b=%04x,result=%04x\n",
         fqmul_call_count++,
         (unsigned int)(uint16_t)a,
         (unsigned int)(uint16_t)b,
         (unsigned int)(uint16_t)result);
}

/*
 * Instrumentation hook called once for every Cooley-Tukey butterfly.
 * result_l and result_h match the lower and upper halves of pq_alu.result_o.
 */
void kyber_trace_butterfly(int16_t len,
                           int16_t start,
                           int16_t j,
                           int16_t k,
                           int16_t zeta,
                           int16_t a,
                           int16_t b,
                           int16_t t,
                           int16_t result_l,
                           int16_t result_h)
{
  const uint32_t result32 =
    ((uint32_t)(uint16_t)result_h << 16) |
    (uint32_t)(uint16_t)result_l;

  printf("BUTTERFLY,call_count=%u,len=%d,start=%d,j=%d,k=%d,zeta=%d,a=%04x,b=%04x,t=%04x,result_l=%04x,"
         "result_h=%04x,result_32=%08x\n",
         butterfly_call_count++,
         (int)len,
         (int)start,
         (int)j,
         (int)k,
         (int)zeta,
         (unsigned int)(uint16_t)a,
         (unsigned int)(uint16_t)b,
         (unsigned int)(uint16_t)t,
         (unsigned int)(uint16_t)result_l,
         (unsigned int)(uint16_t)result_h,
         (unsigned int)result32);
}

void kyber_trace_barret(int16_t a, int16_t b, int16_t result)
{
  printf("BARRET_REDUCE,call_count=%u,a=%04x,b=%04x,result=%04x\n",
         barret_reduce_call_count++,
         (unsigned int)(uint16_t)a,
         (unsigned int)(uint16_t)b,
         (unsigned int)(uint16_t)result);
}

void kyber_trace_ibutterfly(int16_t len, int16_t start, int16_t j, int16_t k, int16_t zeta,
                              int16_t a, int16_t b, int16_t sum, int16_t diff, int16_t reduce, int16_t result)
{

  printf("INV_BUTTERFLY,call_count=%u,len=%d,start=%d,j=%d,k=%d,zeta=%d,a=%04x,b=%04x,sum=%04x,diff=%04x,"
         "reduce=%04x,result=%04x\n",
         ibutterfly_call_count++,
         (int)len,
         (int)start,
         (int)j,
         (int)k,
         (int)zeta,
         (unsigned int)(uint16_t)a,
         (unsigned int)(uint16_t)b,
         (unsigned int)(uint16_t)sum,
         (unsigned int)(uint16_t)diff,
         (unsigned int)(uint16_t)reduce,
         (unsigned int)(uint16_t)result);

}

/* Deterministic polynomial used to generate repeatable RTL test vectors. */
static const int16_t input_vector[KYBER_N] = {
    0,   1,   2,   3,   4,   5,   6,   7,
    8,   9,  10,  11,  12,  13,  14,  15,
   16,  17,  18,  19,  20,  21,  22,  23,
   24,  25,  26,  27,  28,  29,  30,  31,
   32,  33,  34,  35,  36,  37,  38,  39,
   40,  41,  42,  43,  44,  45,  46,  47,
   48,  49,  50,  51,  52,  53,  54,  55,
   56,  57,  58,  59,  60,  61,  62,  63,
   64,  65,  66,  67,  68,  69,  70,  71,
   72,  73,  74,  75,  76,  77,  78,  79,
   80,  81,  82,  83,  84,  85,  86,  87,
   88,  89,  90,  91,  92,  93,  94,  95,
   96,  97,  98,  99, 100, 101, 102, 103,
  104, 105, 106, 107, 108, 109, 110, 111,
  112, 113, 114, 115, 116, 117, 118, 119,
  120, 121, 122, 123, 124, 125, 126, 127,
  128, 129, 130, 131, 132, 133, 134, 135,
  136, 137, 138, 139, 140, 141, 142, 143,
  144, 145, 146, 147, 148, 149, 150, 151,
  152, 153, 154, 155, 156, 157, 158, 159,
  160, 161, 162, 163, 164, 165, 166, 167,
  168, 169, 170, 171, 172, 173, 174, 175,
  176, 177, 178, 179, 180, 181, 182, 183,
  184, 185, 186, 187, 188, 189, 190, 191,
  192, 193, 194, 195, 196, 197, 198, 199,
  200, 201, 202, 203, 204, 205, 206, 207,
  208, 209, 210, 211, 212, 213, 214, 215,
  216, 217, 218, 219, 220, 221, 222, 223,
  224, 225, 226, 227, 228, 229, 230, 231,
  232, 233, 234, 235, 236, 237, 238, 239,
  240, 241, 242, 243, 244, 245, 246, 247,
  248, 249, 250, 251, 252, 253, 254, 255
};

int main(void)
{
  _Alignas(4) int16_t output_vector[KYBER_N];

  puts("# INPUT,index,value_dec,value_hex");
  for (unsigned int i = 0; i < KYBER_N; ++i) {
    output_vector[i] = input_vector[i];
    printf("INPUT,%u,%d,%04x\n",
           i,
           (int)input_vector[i],
           (unsigned int)(uint16_t)input_vector[i]);
  }

  puts("# FQMUL,call,a_hex,b_hex,result_hex");
  puts("# BUTTERFLY,call,len,start,j,k,zeta,a_hex,"
       "b_hex,fqmul_hex,result_l_hex,"
       "result_h_hex,result32_hex");
  puts("# BARRET_REDUCE,call,a_hex,b_hex,result_hex");
  puts("# INV_BUTTERFLY,call,len,start,j,k,zeta,a_hex,b_hex,sum_hex,diff_hex,barret_hex,result_hex");

  ntt(output_vector);
  invntt(output_vector);

  puts("# OUTPUT,index,value_dec,value_hex");
  for (unsigned int i = 0; i < KYBER_N; ++i) {
    printf("OUTPUT,%u,%d,%04x\n",
           i,
           (int)output_vector[i],
           (unsigned int)(uint16_t)output_vector[i]);
  }

  printf("# SUMMARY,fqmul_calls=%u,butterfly_calls=%u, inv_butterfly_calls=%u, barret_reduce_calls=%u\n",
         fqmul_call_count,
         butterfly_call_count,
         ibutterfly_call_count,
         barret_reduce_call_count);

  return 0;
}
