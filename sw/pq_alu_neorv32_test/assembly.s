
./sw/pq_alu_neorv32_test/main.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <__crt0_entry>:
   0:	f14020f3          	csrr	ra,mhartid
   4:	80004217          	auipc	tp,0x80004
   8:	ffc20213          	addi	tp,tp,-4 # 80004000 <__crt0_stack_top>
   c:	ff027113          	andi	sp,tp,-16
  10:	80000197          	auipc	gp,0x80000
  14:	7f018193          	addi	gp,gp,2032 # 80000800 <__global_pointer$>
  18:	000022b7          	lui	t0,0x2
  1c:	80028293          	addi	t0,t0,-2048 # 1800 <__crt0_copy_data_src_begin+0x5c0>
  20:	30029073          	csrw	mstatus,t0
  24:	00000317          	auipc	t1,0x0
  28:	15030313          	addi	t1,t1,336 # 174 <__crt0_panic>
  2c:	30531073          	csrw	mtvec,t1
  30:	30401073          	csrw	mie,zero
  34:	00001397          	auipc	t2,0x1
  38:	20c38393          	addi	t2,t2,524 # 1240 <__crt0_copy_data_src_begin>
  3c:	80000417          	auipc	s0,0x80000
  40:	fc440413          	addi	s0,s0,-60 # 80000000 <__crt0_bss_end>
  44:	80000497          	auipc	s1,0x80000
  48:	fbc48493          	addi	s1,s1,-68 # 80000000 <__crt0_bss_end>
  4c:	80000517          	auipc	a0,0x80000
  50:	fb450513          	addi	a0,a0,-76 # 80000000 <__crt0_bss_end>
  54:	80000597          	auipc	a1,0x80000
  58:	fac58593          	addi	a1,a1,-84 # 80000000 <__crt0_bss_end>
  5c:	4601                	li	a2,0
  5e:	4681                	li	a3,0
  60:	4701                	li	a4,0
  62:	4781                	li	a5,0
  64:	4801                	li	a6,0
  66:	4881                	li	a7,0
  68:	4901                	li	s2,0
  6a:	4981                	li	s3,0
  6c:	4a01                	li	s4,0
  6e:	4a81                	li	s5,0
  70:	4b01                	li	s6,0
  72:	4b81                	li	s7,0
  74:	4c01                	li	s8,0
  76:	4c81                	li	s9,0
  78:	4d01                	li	s10,0
  7a:	4d81                	li	s11,0
  7c:	4e01                	li	t3,0
  7e:	4e81                	li	t4,0
  80:	4f01                	li	t5,0
  82:	4f81                	li	t6,0

00000084 <__crt0_smp_check>:
  84:	04008263          	beqz	ra,c8 <__crt0_data_copy>

00000088 <__crt0_smp_setup>:
  88:	00000797          	auipc	a5,0x0
  8c:	01c78793          	addi	a5,a5,28 # a4 <__crt0_smp_wakeup>
  90:	30579073          	csrw	mtvec,a5
  94:	30445073          	csrwi	mie,8
  98:	30046073          	csrsi	mstatus,8

0000009c <__crt0_smp_sleep>:
  9c:	10500073          	wfi
  a0:	bff5                	j	9c <__crt0_smp_sleep>
  a2:	0001                	nop

000000a4 <__crt0_smp_wakeup>:
  a4:	00000797          	auipc	a5,0x0
  a8:	0d078793          	addi	a5,a5,208 # 174 <__crt0_panic>
  ac:	30579073          	csrw	mtvec,a5
  b0:	30405073          	csrwi	mie,0
  b4:	fff44737          	lui	a4,0xfff44
  b8:	00872103          	lw	sp,8(a4) # fff44008 <__crt0_stack_top+0x7ff40008>
  bc:	4750                	lw	a2,12(a4)
  be:	fff40737          	lui	a4,0xfff40
  c2:	00072223          	sw	zero,4(a4) # fff40004 <__crt0_stack_top+0x7ff3c004>
  c6:	a881                	j	116 <__crt0_main_entry>

000000c8 <__crt0_data_copy>:
  c8:	00838b63          	beq	t2,s0,de <__crt0_bss_clear>
  cc:	00945963          	bge	s0,s1,de <__crt0_bss_clear>

000000d0 <__crt0_data_copy_loop>:
  d0:	0003a783          	lw	a5,0(t2)
  d4:	c01c                	sw	a5,0(s0)
  d6:	0391                	addi	t2,t2,4
  d8:	0411                	addi	s0,s0,4
  da:	fe944be3          	blt	s0,s1,d0 <__crt0_data_copy_loop>

000000de <__crt0_bss_clear>:
  de:	00b55763          	bge	a0,a1,ec <__crt0_bss_clear_end>

000000e2 <__crt0_bss_clear_loop>:
  e2:	00052023          	sw	zero,0(a0)
  e6:	0511                	addi	a0,a0,4
  e8:	feb54de3          	blt	a0,a1,e2 <__crt0_bss_clear_loop>

000000ec <__crt0_bss_clear_end>:
// (t0-t6, a0-a7, ra). Loop counters use s0/s1 (callee-saved), which are
// preserved by the called functions according to the RISC-V calling convention.
// ************************************************************************************************
#ifndef MAKE_BOOTLOADER
__crt0_constructors_primary:
  la    x8, __init_array_start
  ec:	00001417          	auipc	s0,0x1
  f0:	96040413          	addi	s0,s0,-1696 # a4c <__fini_array_end>
  la    x9, __init_array_end
  f4:	00001497          	auipc	s1,0x1
  f8:	95848493          	addi	s1,s1,-1704 # a4c <__fini_array_end>

000000fc <__crt0_constructors>:

__crt0_constructors:
  bge   x8, x9, __crt0_constructors_end  // skip if empty
  fc:	00945963          	bge	s0,s1,10e <__crt0_constructors_end>

00000100 <__crt0_constructors_loop>:

__crt0_constructors_loop:
  lw    x1, 0(x8)
 100:	00042083          	lw	ra,0(s0)
  jalr  x1, 0(x1) // call constructor function; put return address in ra
 104:	000080e7          	jalr	ra
  addi  x8, x8, 4
 108:	0411                	addi	s0,s0,4
  blt   x8, x9, __crt0_constructors_loop
 10a:	fe944be3          	blt	s0,s1,100 <__crt0_constructors_loop>

0000010e <__crt0_constructors_end>:

// ************************************************************************************************
// Setup arguments and call main function.
// ************************************************************************************************
__crt0_main_primary:
  la    x12, main         // primary core's (core0) entry point (#1169)
 10e:	00000617          	auipc	a2,0x0
 112:	06e60613          	addi	a2,a2,110 # 17c <main>

00000116 <__crt0_main_entry>:
__crt0_main_entry:
  fence                   // synchronize loads/stores
 116:	0ff0000f          	fence
  fence.i                 // synchronize instruction fetch
 11a:	0000100f          	fence.i
  li    x10, 0            // x10 = a0 = argc = 0
 11e:	4501                	li	a0,0
  li    x11, 0            // x11 = a1 = argv = 0
 120:	4581                	li	a1,0
  jalr  x1, x12           // call actual main function
 122:	000600e7          	jalr	a2

00000126 <__crt0_main_exit>:

.global __crt0_main_exit
__crt0_main_exit:         // main's "return" and "exit" will arrive here
  csrci mstatus, 1 << 3   // disable machine-level interrupts
 126:	30047073          	csrci	mstatus,8
  csrw  mie, zero         // disable all interrupt sources
 12a:	30401073          	csrw	mie,zero
  la    x11, __crt0_panic // re-install default crt0 trap handler
 12e:	00000597          	auipc	a1,0x0
 132:	04658593          	addi	a1,a1,70 # 174 <__crt0_panic>
  csrw  mtvec, x11
 136:	30559073          	csrw	mtvec,a1
  csrw  mscratch, x10     // backup main's return code to mscratch (for debugger or destructors)
 13a:	34051073          	csrw	mscratch,a0

0000013e <__crt0_destructors_primary>:
// (t0-t6, a0-a7, ra). Loop counters use s0/s1 (callee-saved), which are
// preserved by the called functions according to the RISC-V calling convention.
// ************************************************************************************************
#ifndef MAKE_BOOTLOADER
__crt0_destructors_primary:
  csrr  x8, mhartid
 13e:	f1402473          	csrr	s0,mhartid
  bnez  x8, __crt0_destructors_end // execute destructors only on core 0
 142:	e015                	bnez	s0,166 <__crt0_destructors_end>

  la    x8, __fini_array_start
 144:	00001417          	auipc	s0,0x1
 148:	90840413          	addi	s0,s0,-1784 # a4c <__fini_array_end>
  la    x9, __fini_array_end
 14c:	00001497          	auipc	s1,0x1
 150:	90048493          	addi	s1,s1,-1792 # a4c <__fini_array_end>

00000154 <__crt0_destructors>:

__crt0_destructors:
  bge   x8, x9, __crt0_destructors_end
 154:	00945963          	bge	s0,s1,166 <__crt0_destructors_end>

00000158 <__crt0_destructors_loop>:

__crt0_destructors_loop:
  lw    x1, 0(x8)
 158:	00042083          	lw	ra,0(s0)
  jalr  x1, 0(x1)                  // call destructor function; put return address in ra
 15c:	000080e7          	jalr	ra
  addi  x8, x8, 4
 160:	0411                	addi	s0,s0,4
  blt   x8, x9, __crt0_destructors_loop
 162:	fe944be3          	blt	s0,s1,158 <__crt0_destructors_loop>

00000166 <__crt0_destructors_end>:
// ************************************************************************************************
// Halt CPU. Bootloader should never return; if it does -> panic.
// ************************************************************************************************
#ifndef MAKE_BOOTLOADER
__crt0_halting:
  csrr x8, mhartid
 166:	f1402473          	csrr	s0,mhartid
  bnez x8, __crt0_halt
 16a:	e011                	bnez	s0,16e <__crt0_halt>

0000016c <__crt0_halt_primary>:

.global __crt0_halt_primary
__crt0_halt_primary:
  ebreak     // execution done; try to transfer control to external debugger; otherwise -> panic
 16c:	9002                	ebreak

0000016e <__crt0_halt>:

.global __crt0_halt
__crt0_halt: // same code as trap handler but with different label/address to track origin
  wfi
 16e:	10500073          	wfi
  j __crt0_halt
 172:	bff5                	j	16e <__crt0_halt>

00000174 <__crt0_panic>:
// ************************************************************************************************
.balign 4     // trap handler has to be 32-bit aligned
.option norvc // no compressed instruction to make this valid code on any platform configuration
.global __crt0_panic
__crt0_panic:
  wfi
 174:	10500073          	wfi
  j __crt0_panic
 178:	ffdff06f          	j	174 <__crt0_panic>

0000017c <main>:
static uint32_t corrected_cycles(uint32_t start, uint32_t end, uint32_t overhead) {
  uint32_t elapsed = end - start;
  return elapsed > overhead ? elapsed - overhead : 0;
}

int main(void) {
 17c:	7159                	addi	sp,sp,-112
  neorv32_gpio_dir_set(0xffffffffu);
 17e:	557d                	li	a0,-1
int main(void) {
 180:	d686                	sw	ra,108(sp)
 182:	d4a2                	sw	s0,104(sp)
 184:	d2a6                	sw	s1,100(sp)
 186:	d0ca                	sw	s2,96(sp)
 188:	cece                	sw	s3,92(sp)
 18a:	ccd2                	sw	s4,88(sp)
 18c:	c8da                	sw	s6,80(sp)
 18e:	c6de                	sw	s7,76(sp)
 190:	c4e2                	sw	s8,72(sp)
 192:	c2e6                	sw	s9,68(sp)
 194:	c0ea                	sw	s10,64(sp)
 196:	cad6                	sw	s5,84(sp)
 198:	de6e                	sw	s11,60(sp)
  neorv32_gpio_dir_set(0xffffffffu);
 19a:	296d                	jal	654 <neorv32_gpio_dir_set>
  neorv32_gpio_port_set(0);
 19c:	4501                	li	a0,0
 19e:	217d                	jal	64c <neorv32_gpio_port_set>
  neorv32_uart0_setup(BAUDRATE, 0);
 1a0:	65f1                	lui	a1,0x1c
 1a2:	4601                	li	a2,0
 1a4:	20058593          	addi	a1,a1,512 # 1c200 <__neorv32_rom_size+0xc200>
 1a8:	fff50537          	lui	a0,0xfff50
 1ac:	2945                	jal	65c <neorv32_uart_setup>
  neorv32_uart0_printf("\r\n =========== Inicando Simulacao ISE PQ_ALU NEORV32 =========== \r\n");
 1ae:	6585                	lui	a1,0x1
 1b0:	a4c58593          	addi	a1,a1,-1460 # a4c <__fini_array_end>
 1b4:	fff50537          	lui	a0,0xfff50
 1b8:	684000ef          	jal	83c <neorv32_uart_printf>
  uint32_t fqmul_errors = 0, reduce_errors = 0;
  uint32_t ntt_errors = 0, intt_errors = 0;
  uint32_t idx = 0;

  /* Calibra apenas o overhead das duas leituras do contador de ciclos. */
  c0 = (uint32_t)neorv32_cpu_get_cycle();
 1bc:	29bd                	jal	63a <neorv32_cpu_get_cycle>
 1be:	89aa                	mv	s3,a0
  c1 = (uint32_t)neorv32_cpu_get_cycle();
 1c0:	29ad                	jal	63a <neorv32_cpu_get_cycle>
  uint32_t cycle_overhead = c1 - c0;

  while (idx < FQMUL_LEN) {
    int32_t a = (int16_t)a_fqmul_i[idx];
 1c2:	6685                	lui	a3,0x1
    int32_t b = (int16_t)b_fqmul_i[idx];
 1c4:	6605                	lui	a2,0x1
  c1 = (uint32_t)neorv32_cpu_get_cycle();
 1c6:	892a                	mv	s2,a0
  uint32_t cycle_overhead = c1 - c0;
 1c8:	413504b3          	sub	s1,a0,s3
 1cc:	4a01                	li	s4,0
  uint32_t fqmul_errors = 0, reduce_errors = 0;
 1ce:	4401                	li	s0,0
  uint32_t fqmul_latency = 0, ise_fqmul_latency = 0;
 1d0:	4d01                	li	s10,0
 1d2:	4b01                	li	s6,0
    int32_t a = (int16_t)a_fqmul_i[idx];
 1d4:	0fc68c13          	addi	s8,a3,252 # 10fc <a_fqmul_i>
    int32_t b = (int16_t)b_fqmul_i[idx];
 1d8:	0bc60c93          	addi	s9,a2,188 # 10bc <b_fqmul_i>
  return elapsed > overhead ? elapsed - overhead : 0;
 1dc:	40a988b3          	sub	a7,s3,a0
  while (idx < FQMUL_LEN) {
 1e0:	04000b93          	li	s7,64
    int32_t a = (int16_t)a_fqmul_i[idx];
 1e4:	018a07b3          	add	a5,s4,s8
 1e8:	00079a83          	lh	s5,0(a5)
 
    int32_t b = (int16_t)b_fqmul_i[idx];
 1ec:	019a07b3          	add	a5,s4,s9
 1f0:	00079d83          	lh	s11,0(a5)

    c2 = (uint32_t)neorv32_cpu_get_cycle();
 1f4:	ca46                	sw	a7,20(sp)
 1f6:	2191                	jal	63a <neorv32_cpu_get_cycle>
 1f8:	c22a                	sw	a0,4(sp)
    uint32_t result = (uint32_t)(int32_t)montgomery_reduce(a * b);
 1fa:	03ba8533          	mul	a0,s5,s11
 1fe:	2ebd                	jal	57c <pqcrystals_kyber512_ref_montgomery_reduce>
 200:	c42a                	sw	a0,8(sp)
    c3 = (uint32_t)neorv32_cpu_get_cycle();
 202:	2925                	jal	63a <neorv32_cpu_get_cycle>
 204:	c62a                	sw	a0,12(sp)

    c4 = (uint32_t)neorv32_cpu_get_cycle();
 206:	2915                	jal	63a <neorv32_cpu_get_cycle>
 208:	c82a                	sw	a0,16(sp)

 20a:	01ba8a8b          	.insn	4, 0x01ba8a8b
    uint32_t ise_result = pq_fqmul((uint32_t)a, (uint32_t)b);
    c5 = (uint32_t)neorv32_cpu_get_cycle();
 20e:	2135                	jal	63a <neorv32_cpu_get_cycle>

    fqmul_results[idx].software = result;
    fqmul_results[idx].ise = ise_result;
    if (result != ise_result || result != r_fqmul_o[idx] ||
 210:	47a2                	lw	a5,8(sp)
 212:	6705                	lui	a4,0x1
 214:	48d2                	lw	a7,20(sp)
 216:	07c70813          	addi	a6,a4,124 # 107c <r_fqmul_o>
 21a:	00fa9763          	bne	s5,a5,228 <main+0xac>
 21e:	010a07b3          	add	a5,s4,a6
 222:	439c                	lw	a5,0(a5)
 224:	01578363          	beq	a5,s5,22a <main+0xae>
        ise_result != r_fqmul_o[idx])
      ++fqmul_errors;
 228:	0405                	addi	s0,s0,1
  uint32_t elapsed = end - start;
 22a:	47b2                	lw	a5,12(sp)
 22c:	4712                	lw	a4,4(sp)
  return elapsed > overhead ? elapsed - overhead : 0;
 22e:	4581                	li	a1,0
  uint32_t elapsed = end - start;
 230:	8f99                	sub	a5,a5,a4
  return elapsed > overhead ? elapsed - overhead : 0;
 232:	00f4f463          	bgeu	s1,a5,23a <main+0xbe>
 236:	00f885b3          	add	a1,a7,a5
  uint32_t elapsed = end - start;
 23a:	47c2                	lw	a5,16(sp)
    fqmul_latency += corrected_cycles(c2, c3, cycle_overhead);
 23c:	9b2e                	add	s6,s6,a1
  uint32_t elapsed = end - start;
 23e:	8d1d                	sub	a0,a0,a5
  return elapsed > overhead ? elapsed - overhead : 0;
 240:	4781                	li	a5,0
 242:	00a4f463          	bgeu	s1,a0,24a <main+0xce>
 246:	00a887b3          	add	a5,a7,a0
  while (idx < FQMUL_LEN) {
 24a:	0a11                	addi	s4,s4,4
    ise_fqmul_latency += corrected_cycles(c4, c5, cycle_overhead);
 24c:	9d3e                	add	s10,s10,a5
  while (idx < FQMUL_LEN) {
 24e:	f97a1be3          	bne	s4,s7,1e4 <main+0x68>
    ++idx;
  }
  fqmul_latency /= FQMUL_LEN;
 252:	004b5793          	srli	a5,s6,0x4
 256:	c23e                	sw	a5,4(sp)
  ise_fqmul_latency /= FQMUL_LEN;
  idx = 0;

  while (idx < REDUCE_LEN) {
    int32_t a = (int16_t)a_reduce_i[idx];
 258:	6705                	lui	a4,0x1
  ise_fqmul_latency /= FQMUL_LEN;
 25a:	004d5793          	srli	a5,s10,0x4
    uint32_t ise_result = pq_reduce((uint32_t)a);
    c5 = (uint32_t)neorv32_cpu_get_cycle();

    reduce_results[idx].software = result;
    reduce_results[idx].ise = ise_result;
    if (result != ise_result || result != r_reduce_o[idx] ||
 25e:	6685                	lui	a3,0x1
  ise_fqmul_latency /= FQMUL_LEN;
 260:	c43e                	sw	a5,8(sp)
 262:	4a81                	li	s5,0
  uint32_t fqmul_errors = 0, reduce_errors = 0;
 264:	4a01                	li	s4,0
  uint32_t reduce_latency = 0, ise_reduce_latency = 0;
 266:	4d01                	li	s10,0
 268:	4d81                	li	s11,0
    int32_t a = (int16_t)a_reduce_i[idx];
 26a:	03c70b93          	addi	s7,a4,60 # 103c <a_reduce_i>
    if (result != ise_result || result != r_reduce_o[idx] ||
 26e:	ffc68c13          	addi	s8,a3,-4 # ffc <r_reduce_o>
  return elapsed > overhead ? elapsed - overhead : 0;
 272:	41298633          	sub	a2,s3,s2
  while (idx < REDUCE_LEN) {
 276:	04000b13          	li	s6,64
    int32_t a = (int16_t)a_reduce_i[idx];
 27a:	017a87b3          	add	a5,s5,s7
 27e:	00079c83          	lh	s9,0(a5)
 282:	ce32                	sw	a2,28(sp)
    c2 = (uint32_t)neorv32_cpu_get_cycle();
 284:	2e5d                	jal	63a <neorv32_cpu_get_cycle>
 286:	c62a                	sw	a0,12(sp)
    uint32_t result = (uint32_t)(int32_t)barrett_reduce((int16_t)a);
 288:	8566                	mv	a0,s9
 28a:	2e01                	jal	59a <pqcrystals_kyber512_ref_barrett_reduce>
 28c:	cc2a                	sw	a0,24(sp)
    c3 = (uint32_t)neorv32_cpu_get_cycle();
 28e:	2675                	jal	63a <neorv32_cpu_get_cycle>
 290:	c82a                	sw	a0,16(sp)
    c4 = (uint32_t)neorv32_cpu_get_cycle();
 292:	2665                	jal	63a <neorv32_cpu_get_cycle>
 294:	ca2a                	sw	a0,20(sp)
 296:	4581                	li	a1,0
 298:	02bc8c8b          	.insn	4, 0x02bc8c8b
    c5 = (uint32_t)neorv32_cpu_get_cycle();
 29c:	2e79                	jal	63a <neorv32_cpu_get_cycle>
    if (result != ise_result || result != r_reduce_o[idx] ||
 29e:	47e2                	lw	a5,24(sp)
 2a0:	4672                	lw	a2,28(sp)
 2a2:	01979763          	bne	a5,s9,2b0 <main+0x134>
 2a6:	018a85b3          	add	a1,s5,s8
 2aa:	418c                	lw	a1,0(a1)
 2ac:	00f58363          	beq	a1,a5,2b2 <main+0x136>
        ise_result != r_reduce_o[idx])
      ++reduce_errors;
 2b0:	0a05                	addi	s4,s4,1
  uint32_t elapsed = end - start;
 2b2:	47c2                	lw	a5,16(sp)
 2b4:	4732                	lw	a4,12(sp)
  return elapsed > overhead ? elapsed - overhead : 0;
 2b6:	4581                	li	a1,0
  uint32_t elapsed = end - start;
 2b8:	8f99                	sub	a5,a5,a4
  return elapsed > overhead ? elapsed - overhead : 0;
 2ba:	00f4f463          	bgeu	s1,a5,2c2 <main+0x146>
 2be:	00f605b3          	add	a1,a2,a5
  uint32_t elapsed = end - start;
 2c2:	47d2                	lw	a5,20(sp)
    reduce_latency += corrected_cycles(c2, c3, cycle_overhead);
 2c4:	9dae                	add	s11,s11,a1
  uint32_t elapsed = end - start;
 2c6:	8d1d                	sub	a0,a0,a5
  return elapsed > overhead ? elapsed - overhead : 0;
 2c8:	4781                	li	a5,0
 2ca:	00a4f463          	bgeu	s1,a0,2d2 <main+0x156>
 2ce:	00a607b3          	add	a5,a2,a0
  while (idx < REDUCE_LEN) {
 2d2:	0a91                	addi	s5,s5,4
    ise_reduce_latency += corrected_cycles(c4, c5, cycle_overhead);
 2d4:	9d3e                	add	s10,s10,a5
  while (idx < REDUCE_LEN) {
 2d6:	fb6a92e3          	bne	s5,s6,27a <main+0xfe>
    ++idx;
  }
  reduce_latency /= REDUCE_LEN;
 2da:	004dd793          	srli	a5,s11,0x4
 2de:	c63e                	sw	a5,12(sp)
  ise_reduce_latency /= REDUCE_LEN;
  idx = 0;

  while (idx < NTT_LEN) {
    int32_t a = (int16_t)a_ntt_i[idx];
 2e0:	6705                	lui	a4,0x1
  ise_reduce_latency /= REDUCE_LEN;
 2e2:	004d5793          	srli	a5,s10,0x4
    int32_t b = (int16_t)b_ntt_i[idx];
 2e6:	6685                	lui	a3,0x1

    c2 = (uint32_t)neorv32_cpu_get_cycle();
   
    int32_t zeta = (int16_t)zeta_ntt_i[idx];
 2e8:	6a85                	lui	s5,0x1
   
    c3 = (uint32_t)neorv32_cpu_get_cycle();

    c4 = (uint32_t)neorv32_cpu_get_cycle();
   
    (void)pq_set_twiddle(twiddle_ntt_i[idx]);
 2ea:	6b05                	lui	s6,0x1
  ise_reduce_latency /= REDUCE_LEN;
 2ec:	c83e                	sw	a5,16(sp)
 2ee:	4c01                	li	s8,0
  uint32_t ntt_errors = 0, intt_errors = 0;
 2f0:	4781                	li	a5,0
  uint32_t ntt_latency = 0, ise_ntt_latency = 0;
 2f2:	4d01                	li	s10,0
 2f4:	4d81                	li	s11,0
    int32_t a = (int16_t)a_ntt_i[idx];
 2f6:	fbc70713          	addi	a4,a4,-68 # fbc <a_ntt_i>
    int32_t b = (int16_t)b_ntt_i[idx];
 2fa:	f7c68693          	addi	a3,a3,-132 # f7c <b_ntt_i>
    int32_t zeta = (int16_t)zeta_ntt_i[idx];
 2fe:	f3ca8a93          	addi	s5,s5,-196 # f3c <zeta_ntt_i>
    (void)pq_set_twiddle(twiddle_ntt_i[idx]);
 302:	efcb0b13          	addi	s6,s6,-260 # efc <twiddle_ntt_i>
  return elapsed > overhead ? elapsed - overhead : 0;
 306:	41298833          	sub	a6,s3,s2
    int32_t a = (int16_t)a_ntt_i[idx];
 30a:	00ec05b3          	add	a1,s8,a4
 30e:	00059c83          	lh	s9,0(a1)
    int32_t b = (int16_t)b_ntt_i[idx];
 312:	00dc05b3          	add	a1,s8,a3
 316:	d442                	sw	a6,40(sp)
 318:	d23e                	sw	a5,36(sp)
 31a:	00059b83          	lh	s7,0(a1)
    c2 = (uint32_t)neorv32_cpu_get_cycle();
 31e:	2e31                	jal	63a <neorv32_cpu_get_cycle>
    int32_t zeta = (int16_t)zeta_ntt_i[idx];
 320:	015c05b3          	add	a1,s8,s5
    c2 = (uint32_t)neorv32_cpu_get_cycle();
 324:	ca2a                	sw	a0,20(sp)
    int32_t zeta = (int16_t)zeta_ntt_i[idx];
 326:	00059503          	lh	a0,0(a1)
    int16_t t = montgomery_reduce(zeta * b);
 32a:	03750533          	mul	a0,a0,s7
 32e:	24b9                	jal	57c <pqcrystals_kyber512_ref_montgomery_reduce>
  return (uint32_t)(uint16_t)first | ((uint32_t)(uint16_t)second << 16);
 330:	40ac88b3          	sub	a7,s9,a0
    uint32_t result = pack_coefficients((int16_t)(a + t),
 334:	9566                	add	a0,a0,s9
  return (uint32_t)(uint16_t)first | ((uint32_t)(uint16_t)second << 16);
 336:	0542                	slli	a0,a0,0x10
 338:	8141                	srli	a0,a0,0x10
 33a:	08c2                	slli	a7,a7,0x10
 33c:	00a8e8b3          	or	a7,a7,a0
 340:	d046                	sw	a7,32(sp)
    c3 = (uint32_t)neorv32_cpu_get_cycle();
 342:	2ce5                	jal	63a <neorv32_cpu_get_cycle>
 344:	cc2a                	sw	a0,24(sp)
    c4 = (uint32_t)neorv32_cpu_get_cycle();
 346:	2cd5                	jal	63a <neorv32_cpu_get_cycle>
    (void)pq_set_twiddle(twiddle_ntt_i[idx]);
 348:	016c05b3          	add	a1,s8,s6
    c4 = (uint32_t)neorv32_cpu_get_cycle();
 34c:	ce2a                	sw	a0,28(sp)
 34e:	418c                	lw	a1,0(a1)
 350:	4501                	li	a0,0
 352:	04a5858b          	.insn	4, 0x04a5858b
 356:	077c8c8b          	.insn	4, 0x077c8c8b
    uint32_t ise_result = pq_ntt((uint32_t)a, (uint32_t)b);
   
    c5 = (uint32_t)neorv32_cpu_get_cycle();
 35a:	24c5                	jal	63a <neorv32_cpu_get_cycle>

    ntt_results[idx].software = result;
    ntt_results[idx].ise = ise_result;
    if (result != ise_result || result != r_ntt_o[idx] ||
 35c:	5882                	lw	a7,32(sp)
 35e:	6785                	lui	a5,0x1
 360:	f7c78693          	addi	a3,a5,-132 # f7c <b_ntt_i>
 364:	6605                	lui	a2,0x1
 366:	6785                	lui	a5,0x1
 368:	fbc78713          	addi	a4,a5,-68 # fbc <a_ntt_i>
 36c:	5822                	lw	a6,40(sp)
 36e:	5792                	lw	a5,36(sp)
 370:	ebc60613          	addi	a2,a2,-324 # ebc <r_ntt_o>
 374:	011c9763          	bne	s9,a7,382 <main+0x206>
 378:	00cc05b3          	add	a1,s8,a2
 37c:	418c                	lw	a1,0(a1)
 37e:	01958363          	beq	a1,s9,384 <main+0x208>
        ise_result != r_ntt_o[idx])
      ++ntt_errors;
 382:	0785                	addi	a5,a5,1
  uint32_t elapsed = end - start;
 384:	48d2                	lw	a7,20(sp)
 386:	45e2                	lw	a1,24(sp)
 388:	411585b3          	sub	a1,a1,a7
  return elapsed > overhead ? elapsed - overhead : 0;
 38c:	4881                	li	a7,0
 38e:	00b4f463          	bgeu	s1,a1,396 <main+0x21a>
 392:	00b808b3          	add	a7,a6,a1
  uint32_t elapsed = end - start;
 396:	45f2                	lw	a1,28(sp)
    ntt_latency += corrected_cycles(c2, c3, cycle_overhead);
 398:	9dc6                	add	s11,s11,a7
  uint32_t elapsed = end - start;
 39a:	8d0d                	sub	a0,a0,a1
  return elapsed > overhead ? elapsed - overhead : 0;
 39c:	4581                	li	a1,0
 39e:	00a4f463          	bgeu	s1,a0,3a6 <main+0x22a>
 3a2:	00a805b3          	add	a1,a6,a0
    ise_ntt_latency += corrected_cycles(c4, c5, cycle_overhead);
 3a6:	9d2e                	add	s10,s10,a1
  while (idx < NTT_LEN) {
 3a8:	0c11                	addi	s8,s8,4
 3aa:	04000593          	li	a1,64
 3ae:	f4bc1ee3          	bne	s8,a1,30a <main+0x18e>
    ++idx;
  }
  ntt_latency /= NTT_LEN;
 3b2:	004dd713          	srli	a4,s11,0x4
 3b6:	ca3a                	sw	a4,20(sp)
    int32_t a = (int16_t)a_intt_i[idx];
    int32_t b = (int16_t)b_intt_i[idx];

    c2 = (uint32_t)neorv32_cpu_get_cycle();
   
    int32_t zeta = (int16_t)zeta_intt_i[idx];
 3b8:	6585                	lui	a1,0x1
  ise_ntt_latency /= NTT_LEN;
 3ba:	004d5713          	srli	a4,s10,0x4
 3be:	cc3a                	sw	a4,24(sp)
    int32_t a = (int16_t)a_intt_i[idx];
 3c0:	6805                	lui	a6,0x1
    int32_t b = (int16_t)b_intt_i[idx];
 3c2:	6885                	lui	a7,0x1
    int32_t zeta = (int16_t)zeta_intt_i[idx];
 3c4:	dfc58713          	addi	a4,a1,-516 # dfc <zeta_intt_i>
   
    c3 = (uint32_t)neorv32_cpu_get_cycle();

    c4 = (uint32_t)neorv32_cpu_get_cycle();
   
    (void)pq_set_twiddle(twiddle_intt_i[idx]);
 3c8:	6b85                	lui	s7,0x1
  ise_ntt_latency /= NTT_LEN;
 3ca:	4c81                	li	s9,0
  uint32_t ntt_errors = 0, intt_errors = 0;
 3cc:	4601                	li	a2,0
  uint32_t intt_latency = 0, ise_intt_latency = 0;
 3ce:	4a81                	li	s5,0
 3d0:	4b01                	li	s6,0
    int32_t a = (int16_t)a_intt_i[idx];
 3d2:	e7c80813          	addi	a6,a6,-388 # e7c <a_intt_i>
    int32_t b = (int16_t)b_intt_i[idx];
 3d6:	e3c88893          	addi	a7,a7,-452 # e3c <b_intt_i>
    int32_t zeta = (int16_t)zeta_intt_i[idx];
 3da:	ce3a                	sw	a4,28(sp)
    (void)pq_set_twiddle(twiddle_intt_i[idx]);
 3dc:	dbcb8b93          	addi	s7,s7,-580 # dbc <twiddle_intt_i>
  return elapsed > overhead ? elapsed - overhead : 0;
 3e0:	41298e33          	sub	t3,s3,s2
    int32_t a = (int16_t)a_intt_i[idx];
 3e4:	010c85b3          	add	a1,s9,a6
 3e8:	00059c03          	lh	s8,0(a1)
    int32_t b = (int16_t)b_intt_i[idx];
 3ec:	011c85b3          	add	a1,s9,a7
 3f0:	d672                	sw	t3,44(sp)
 3f2:	d432                	sw	a2,40(sp)
 3f4:	00059d03          	lh	s10,0(a1)
 3f8:	d23e                	sw	a5,36(sp)
    c2 = (uint32_t)neorv32_cpu_get_cycle();
 3fa:	2481                	jal	63a <neorv32_cpu_get_cycle>
    int32_t zeta = (int16_t)zeta_intt_i[idx];
 3fc:	47f2                	lw	a5,28(sp)
    c2 = (uint32_t)neorv32_cpu_get_cycle();
 3fe:	d02a                	sw	a0,32(sp)
    int16_t sum = (int16_t)(a + b);
 400:	01ac0533          	add	a0,s8,s10
    int32_t zeta = (int16_t)zeta_intt_i[idx];
 404:	00fc85b3          	add	a1,s9,a5
 408:	00059d83          	lh	s11,0(a1)
    int16_t difference = (int16_t)(b - a);
 40c:	418d0933          	sub	s2,s10,s8
    int16_t first = barrett_reduce(sum);
 410:	0542                	slli	a0,a0,0x10
    int16_t difference = (int16_t)(b - a);
 412:	0942                	slli	s2,s2,0x10
    int16_t first = barrett_reduce(sum);
 414:	8541                	srai	a0,a0,0x10
 416:	2251                	jal	59a <pqcrystals_kyber512_ref_barrett_reduce>
    int16_t difference = (int16_t)(b - a);
 418:	41095913          	srai	s2,s2,0x10
  return (uint32_t)(uint16_t)first | ((uint32_t)(uint16_t)second << 16);
 41c:	01051993          	slli	s3,a0,0x10
    int16_t second = montgomery_reduce(zeta * difference);
 420:	03b90533          	mul	a0,s2,s11
  return (uint32_t)(uint16_t)first | ((uint32_t)(uint16_t)second << 16);
 424:	0109d993          	srli	s3,s3,0x10
    int16_t second = montgomery_reduce(zeta * difference);
 428:	2a91                	jal	57c <pqcrystals_kyber512_ref_montgomery_reduce>
  return (uint32_t)(uint16_t)first | ((uint32_t)(uint16_t)second << 16);
 42a:	01051d93          	slli	s11,a0,0x10
    c3 = (uint32_t)neorv32_cpu_get_cycle();
 42e:	2431                	jal	63a <neorv32_cpu_get_cycle>
  return (uint32_t)(uint16_t)first | ((uint32_t)(uint16_t)second << 16);
 430:	013dedb3          	or	s11,s11,s3
    c3 = (uint32_t)neorv32_cpu_get_cycle();
 434:	89aa                	mv	s3,a0
    c4 = (uint32_t)neorv32_cpu_get_cycle();
 436:	2411                	jal	63a <neorv32_cpu_get_cycle>
    (void)pq_set_twiddle(twiddle_intt_i[idx]);
 438:	017c85b3          	add	a1,s9,s7
    c4 = (uint32_t)neorv32_cpu_get_cycle();
 43c:	892a                	mv	s2,a0
 43e:	418c                	lw	a1,0(a1)
 440:	4501                	li	a0,0
 442:	04a5858b          	.insn	4, 0x04a5858b
 446:	09ac0d0b          	.insn	4, 0x09ac0d0b
    uint32_t ise_result = pq_intt((uint32_t)a, (uint32_t)b);
    
    c5 = (uint32_t)neorv32_cpu_get_cycle();
 44a:	2ac5                	jal	63a <neorv32_cpu_get_cycle>

    intt_results[idx].software = result;
    intt_results[idx].ise = ise_result;
    if (result != ise_result || result != r_intt_o[idx] ||
 44c:	6785                	lui	a5,0x1
 44e:	e3c78893          	addi	a7,a5,-452 # e3c <b_intt_i>
 452:	6705                	lui	a4,0x1
 454:	6785                	lui	a5,0x1
 456:	e7c78813          	addi	a6,a5,-388 # e7c <a_intt_i>
 45a:	5622                	lw	a2,40(sp)
 45c:	5792                	lw	a5,36(sp)
 45e:	5e32                	lw	t3,44(sp)
 460:	d7c70313          	addi	t1,a4,-644 # d7c <r_intt_o>
 464:	01bd1763          	bne	s10,s11,472 <main+0x2f6>
 468:	006c85b3          	add	a1,s9,t1
 46c:	418c                	lw	a1,0(a1)
 46e:	01a58363          	beq	a1,s10,474 <main+0x2f8>
        ise_result != r_intt_o[idx])
      ++intt_errors;
 472:	0605                	addi	a2,a2,1
  uint32_t elapsed = end - start;
 474:	5702                	lw	a4,32(sp)
  return elapsed > overhead ? elapsed - overhead : 0;
 476:	4581                	li	a1,0
  uint32_t elapsed = end - start;
 478:	40e989b3          	sub	s3,s3,a4
  return elapsed > overhead ? elapsed - overhead : 0;
 47c:	0134f463          	bgeu	s1,s3,484 <main+0x308>
 480:	013e05b3          	add	a1,t3,s3
  uint32_t elapsed = end - start;
 484:	41250533          	sub	a0,a0,s2
    intt_latency += corrected_cycles(c2, c3, cycle_overhead);
 488:	9b2e                	add	s6,s6,a1
  return elapsed > overhead ? elapsed - overhead : 0;
 48a:	4581                	li	a1,0
 48c:	00a4f463          	bgeu	s1,a0,494 <main+0x318>
 490:	00ae05b3          	add	a1,t3,a0
    ise_intt_latency += corrected_cycles(c4, c5, cycle_overhead);
 494:	9aae                	add	s5,s5,a1
  while (idx < INTT_LEN) {
 496:	0c91                	addi	s9,s9,4
 498:	04000593          	li	a1,64
 49c:	f4bc94e3          	bne	s9,a1,3e4 <main+0x268>
    ++idx;
  }
  intt_latency /= INTT_LEN;
  ise_intt_latency /= INTT_LEN;

  uint16_t total_errors = fqmul_errors + reduce_errors + ntt_errors + intt_errors;
 4a0:	9452                	add	s0,s0,s4
  uint8_t pass = (total_errors != 0) ? 0 : 1;

  neorv32_uart0_printf("========= Resumo Teste com implementacao base NEORV32 ==============\r\n");
 4a2:	6585                	lui	a1,0x1
  uint16_t total_errors = fqmul_errors + reduce_errors + ntt_errors + intt_errors;
 4a4:	943e                	add	s0,s0,a5
  neorv32_uart0_printf("========= Resumo Teste com implementacao base NEORV32 ==============\r\n");
 4a6:	a9058593          	addi	a1,a1,-1392 # a90 <__fini_array_end+0x44>
 4aa:	fff50537          	lui	a0,0xfff50
  uint16_t total_errors = fqmul_errors + reduce_errors + ntt_errors + intt_errors;
 4ae:	9432                	add	s0,s0,a2
  neorv32_uart0_printf("========= Resumo Teste com implementacao base NEORV32 ==============\r\n");
 4b0:	2671                	jal	83c <neorv32_uart_printf>
  neorv32_uart0_printf("Número medio de ciclos sem ISE p/ FQMUL: %d\n", fqmul_latency);
 4b2:	4612                	lw	a2,4(sp)
 4b4:	6585                	lui	a1,0x1
 4b6:	adc58593          	addi	a1,a1,-1316 # adc <__fini_array_end+0x90>
 4ba:	fff50537          	lui	a0,0xfff50
 4be:	2ebd                	jal	83c <neorv32_uart_printf>
  neorv32_uart0_printf("Número medio de ciclos sem ISE p/ REDUCE: %d\n", reduce_latency);
 4c0:	4632                	lw	a2,12(sp)
 4c2:	6585                	lui	a1,0x1
 4c4:	b0c58593          	addi	a1,a1,-1268 # b0c <__fini_array_end+0xc0>
 4c8:	fff50537          	lui	a0,0xfff50
 4cc:	2e85                	jal	83c <neorv32_uart_printf>
  neorv32_uart0_printf("Número medio de ciclos sem ISE p/ Butt. CT: %d\n", ntt_latency);
 4ce:	4652                	lw	a2,20(sp)
 4d0:	6585                	lui	a1,0x1
 4d2:	b3c58593          	addi	a1,a1,-1220 # b3c <__fini_array_end+0xf0>
 4d6:	fff50537          	lui	a0,0xfff50
 4da:	268d                	jal	83c <neorv32_uart_printf>
  neorv32_uart0_printf("Número medio de ciclos sem ISE p/ Butt. GS: %d\n", intt_latency);
 4dc:	6585                	lui	a1,0x1
 4de:	004b5613          	srli	a2,s6,0x4
 4e2:	b7058593          	addi	a1,a1,-1168 # b70 <__fini_array_end+0x124>
 4e6:	fff50537          	lui	a0,0xfff50
 4ea:	2e89                	jal	83c <neorv32_uart_printf>

  neorv32_uart0_printf("\r\n========= Resumo Teste com implementacao de ISE NEORV32 ==============\r\n");
 4ec:	6585                	lui	a1,0x1
 4ee:	ba458593          	addi	a1,a1,-1116 # ba4 <__fini_array_end+0x158>
 4f2:	fff50537          	lui	a0,0xfff50
 4f6:	2699                	jal	83c <neorv32_uart_printf>
  neorv32_uart0_printf("Número medio de ciclos com ISE p/ FQMUL: %d\n", ise_fqmul_latency);
 4f8:	4622                	lw	a2,8(sp)
 4fa:	6585                	lui	a1,0x1
 4fc:	bf058593          	addi	a1,a1,-1040 # bf0 <__fini_array_end+0x1a4>
 500:	fff50537          	lui	a0,0xfff50
 504:	2e25                	jal	83c <neorv32_uart_printf>
  neorv32_uart0_printf("Número medio de ciclos com ISE p/ REDUCE: %d\n", ise_reduce_latency);
 506:	4642                	lw	a2,16(sp)
 508:	6585                	lui	a1,0x1
 50a:	c2058593          	addi	a1,a1,-992 # c20 <__fini_array_end+0x1d4>
 50e:	fff50537          	lui	a0,0xfff50
 512:	262d                	jal	83c <neorv32_uart_printf>
  neorv32_uart0_printf("Número medio de ciclos com ISE p/ Butt. CT: %d\n", ise_ntt_latency);
 514:	4662                	lw	a2,24(sp)
 516:	6585                	lui	a1,0x1
 518:	c5058593          	addi	a1,a1,-944 # c50 <__fini_array_end+0x204>
 51c:	fff50537          	lui	a0,0xfff50
 520:	2e31                	jal	83c <neorv32_uart_printf>
  neorv32_uart0_printf("Número medio de ciclos com ISE p/ Butt. GS: %d\n", ise_intt_latency);
 522:	6585                	lui	a1,0x1
 524:	004ad613          	srli	a2,s5,0x4
 528:	c8458593          	addi	a1,a1,-892 # c84 <__fini_array_end+0x238>
 52c:	fff50537          	lui	a0,0xfff50
 530:	2631                	jal	83c <neorv32_uart_printf>
  neorv32_uart0_printf("Overhead da medicao: ciclos=%d\n", cycle_overhead);
 532:	6585                	lui	a1,0x1
 534:	8626                	mv	a2,s1
 536:	cb858593          	addi	a1,a1,-840 # cb8 <__fini_array_end+0x26c>
 53a:	fff50537          	lui	a0,0xfff50
 53e:	2cfd                	jal	83c <neorv32_uart_printf>

  neorv32_uart0_printf("\r\n========= RESUMO ==============\r\n");
 540:	6585                	lui	a1,0x1
 542:	cd858593          	addi	a1,a1,-808 # cd8 <__fini_array_end+0x28c>
 546:	fff50537          	lui	a0,0xfff50
 54a:	2ccd                	jal	83c <neorv32_uart_printf>
  uint16_t total_errors = fqmul_errors + reduce_errors + ntt_errors + intt_errors;
 54c:	0442                	slli	s0,s0,0x10
 54e:	8041                	srli	s0,s0,0x10
  neorv32_uart0_printf("Erros: %d\n", total_errors);
 550:	6585                	lui	a1,0x1
 552:	8622                	mv	a2,s0
 554:	cfc58593          	addi	a1,a1,-772 # cfc <__fini_array_end+0x2b0>
 558:	fff50537          	lui	a0,0xfff50
 55c:	24c5                	jal	83c <neorv32_uart_printf>

  if (pass)
 55e:	e801                	bnez	s0,56e <main+0x3f2>
    neorv32_uart0_printf("===============  [PASS] SUCESSO! ===========\n");
 560:	6585                	lui	a1,0x1
 562:	d0858593          	addi	a1,a1,-760 # d08 <__fini_array_end+0x2bc>
 566:	fff50537          	lui	a0,0xfff50
 56a:	2cc9                	jal	83c <neorv32_uart_printf>
  else
    neorv32_uart0_printf("===============  [FAIL] FALHA! ==============\n");

  for (;;) { }
 56c:	a001                	j	56c <main+0x3f0>
    neorv32_uart0_printf("===============  [FAIL] FALHA! ==============\n");
 56e:	6585                	lui	a1,0x1
 570:	d3858593          	addi	a1,a1,-712 # d38 <__fini_array_end+0x2ec>
 574:	fff50537          	lui	a0,0xfff50
 578:	24d1                	jal	83c <neorv32_uart_printf>
 57a:	bfcd                	j	56c <main+0x3f0>

0000057c <pqcrystals_kyber512_ref_montgomery_reduce>:
  #else

  int32_t t;
  int16_t u;

  u = a*QINV;
 57c:	77fd                	lui	a5,0xfffff
 57e:	30178793          	addi	a5,a5,769 # fffff301 <__crt0_stack_top+0x7fffb301>
 582:	02f507b3          	mul	a5,a0,a5
  t = (int32_t)u*KYBER_Q;
 586:	6705                	lui	a4,0x1
 588:	d0170713          	addi	a4,a4,-767 # d01 <__fini_array_end+0x2b5>
 58c:	07c2                	slli	a5,a5,0x10
 58e:	87c1                	srai	a5,a5,0x10
 590:	02e787b3          	mul	a5,a5,a4
  t = a - t;
 594:	8d1d                	sub	a0,a0,a5
  t >>= 16;
  return t;

  #endif

}
 596:	8541                	srai	a0,a0,0x10
 598:	8082                	ret

0000059a <pqcrystals_kyber512_ref_barrett_reduce>:
  #else

  int16_t t;
  const int16_t v = ((1U << 26) + KYBER_Q/2)/KYBER_Q;

  t  = (int32_t)v*a >> 26;
 59a:	6795                	lui	a5,0x5
 59c:	ebf78793          	addi	a5,a5,-321 # 4ebf <__neorv32_ram_size+0xebf>
 5a0:	02f507b3          	mul	a5,a0,a5
  t *= KYBER_Q;
 5a4:	6705                	lui	a4,0x1
 5a6:	d0170713          	addi	a4,a4,-767 # d01 <__fini_array_end+0x2b5>
  t  = (int32_t)v*a >> 26;
 5aa:	87e9                	srai	a5,a5,0x1a
  t *= KYBER_Q;
 5ac:	02e787b3          	mul	a5,a5,a4

  #ifdef KYBER_NTT_TRACE
    kyber_trace_barret(a, t, a - t);
  #endif
  return a - t;
 5b0:	8d1d                	sub	a0,a0,a5

  #endif

}
 5b2:	0542                	slli	a0,a0,0x10
 5b4:	8541                	srai	a0,a0,0x10
 5b6:	8082                	ret

000005b8 <neorv32_aux_itoa>:
 *
 * @param[in,out] buffer Pointer to array for the result string [33 chars].
 * @param[in] num Number to convert.
 * @param[in] base Base of number representation (2..16).
 **************************************************************************/
void neorv32_aux_itoa(char *buffer, uint32_t num, uint32_t base) {
 5b8:	715d                	addi	sp,sp,-80
 5ba:	c2a6                	sw	s1,68(sp)
 5bc:	84ae                	mv	s1,a1

  const char digits[16] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
 5be:	6585                	lui	a1,0x1
void neorv32_aux_itoa(char *buffer, uint32_t num, uint32_t base) {
 5c0:	c4a2                	sw	s0,72(sp)
 5c2:	c0ca                	sw	s2,64(sp)
  const char digits[16] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
 5c4:	d6858593          	addi	a1,a1,-664 # d68 <__fini_array_end+0x31c>
void neorv32_aux_itoa(char *buffer, uint32_t num, uint32_t base) {
 5c8:	8932                	mv	s2,a2
 5ca:	842a                	mv	s0,a0
  const char digits[16] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
 5cc:	4641                	li	a2,16
 5ce:	0068                	addi	a0,sp,12
void neorv32_aux_itoa(char *buffer, uint32_t num, uint32_t base) {
 5d0:	c686                	sw	ra,76(sp)
  const char digits[16] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
 5d2:	263d                	jal	900 <memcpy>
  char *tmp_ptr = 0;
  unsigned int i = 0;

  // prevent uninitialized stack bytes
  for (i=0; i<sizeof(tmp); i++) {
    tmp[i] = 0;
 5d4:	02400613          	li	a2,36
 5d8:	4581                	li	a1,0
 5da:	0868                	addi	a0,sp,28
 5dc:	2cb5                	jal	858 <memset>
  }

  if ((base < 2) || (base > 16)) { // invalid base?
 5de:	ffe90613          	addi	a2,s2,-2
 5e2:	4739                	li	a4,14
 5e4:	00c77a63          	bgeu	a4,a2,5f8 <neorv32_aux_itoa+0x40>
      buffer++;
    }
  }

  // terminate result string
  *buffer = '\0';
 5e8:	00040023          	sb	zero,0(s0)
}
 5ec:	40b6                	lw	ra,76(sp)
 5ee:	4426                	lw	s0,72(sp)
 5f0:	4496                	lw	s1,68(sp)
 5f2:	4906                	lw	s2,64(sp)
 5f4:	6161                	addi	sp,sp,80
 5f6:	8082                	ret
 5f8:	86aa                	mv	a3,a0
 5fa:	03f10793          	addi	a5,sp,63
    *tmp_ptr = digits[num%base];
 5fe:	0324f733          	remu	a4,s1,s2
    tmp_ptr--;
 602:	17fd                	addi	a5,a5,-1
    *tmp_ptr = digits[num%base];
 604:	04070713          	addi	a4,a4,64
 608:	970a                	add	a4,a4,sp
 60a:	fcc74703          	lbu	a4,-52(a4)
 60e:	00e78023          	sb	a4,0(a5)
    num /= base;
 612:	8726                	mv	a4,s1
 614:	0324d4b3          	divu	s1,s1,s2
  } while (num != 0);
 618:	ff2773e3          	bgeu	a4,s2,5fe <neorv32_aux_itoa+0x46>
  for (i=0; i<sizeof(tmp); i++) {
 61c:	4781                	li	a5,0
 61e:	02400613          	li	a2,36
    if (tmp[i] != '\0') {
 622:	00f68733          	add	a4,a3,a5
 626:	00074703          	lbu	a4,0(a4)
 62a:	c701                	beqz	a4,632 <neorv32_aux_itoa+0x7a>
      *buffer = tmp[i];
 62c:	00e40023          	sb	a4,0(s0)
      buffer++;
 630:	0405                	addi	s0,s0,1
  for (i=0; i<sizeof(tmp); i++) {
 632:	0785                	addi	a5,a5,1
 634:	fec797e3          	bne	a5,a2,622 <neorv32_aux_itoa+0x6a>
 638:	bf45                	j	5e8 <neorv32_aux_itoa+0x30>

0000063a <neorv32_cpu_get_cycle>:
 * @return Read data (uint32_t).
 **************************************************************************/
inline uint32_t __attribute__ ((always_inline)) neorv32_cpu_csr_read(const int csr_id) {

  uint32_t csr_data;
  asm volatile ("csrr %[dst], %[id]" : [dst] "=r" (csr_data) : [id] "i" (csr_id));
 63a:	c80027f3          	rdcycleh	a5
 63e:	c0002573          	rdcycle	a0
 642:	c80025f3          	rdcycleh	a1
  uint32_t tmp1 = 0, tmp2 = 0, tmp3 = 0;
  while(1) {
    tmp1 = neorv32_cpu_csr_read(CSR_CYCLEH);
    tmp2 = neorv32_cpu_csr_read(CSR_CYCLE);
    tmp3 = neorv32_cpu_csr_read(CSR_CYCLEH);
    if (tmp1 == tmp3) {
 646:	fef59ae3          	bne	a1,a5,63a <neorv32_cpu_get_cycle>
  subwords64_t data;
  data.uint32[0] = tmp2;
  data.uint32[1] = tmp3;

  return data.uint64;
}
 64a:	8082                	ret

0000064c <neorv32_gpio_port_set>:
 *
 * @param[in] pin_mask New output port value (32-bit).
 **************************************************************************/
void neorv32_gpio_port_set(uint32_t pin_mask) {

  NEORV32_GPIO->PORT_OUT = pin_mask;
 64c:	fffc07b7          	lui	a5,0xfffc0
 650:	c3c8                	sw	a0,4(a5)
}
 652:	8082                	ret

00000654 <neorv32_gpio_dir_set>:
 *
 * @param[in] pin_mask Direction port configuration (32-bit), one bit per port: 0 = input, 1 = output.
 **************************************************************************/
void neorv32_gpio_dir_set(uint32_t pin_mask) {

  NEORV32_GPIO->PORT_DIR = pin_mask;
 654:	fffc07b7          	lui	a5,0xfffc0
 658:	c788                	sw	a0,8(a5)
}
 65a:	8082                	ret

0000065c <neorv32_uart_setup>:

  uint32_t prsc_sel = 0;
  uint32_t baud_div = 0;

  // reset
  UARTx->CTRL = 0;
 65c:	00052023          	sw	zero,0(a0) # fff50000 <__crt0_stack_top+0x7ff4c000>
/**********************************************************************//**
 * Get current processor clock frequency.
 * @return Clock frequency in Hz.
 **************************************************************************/
inline uint32_t __attribute__ ((always_inline)) neorv32_sysinfo_get_clk(void) {
  return NEORV32_SYSINFO->CLK;
 660:	7781                	lui	a5,0xfffe0
 662:	439c                	lw	a5,0(a5)

  // raw clock prescaler
  uint32_t clock = neorv32_sysinfo_get_clk(); // system clock in Hz
#ifndef MAKE_BOOTLOADER // use div instructions / library functions
  baud_div = clock / (2*baudrate);
 664:	0586                	slli	a1,a1,0x1
  uint32_t prsc_sel = 0;
 666:	4701                	li	a4,0
  baud_div = clock / (2*baudrate);
 668:	02b7d7b3          	divu	a5,a5,a1
    baud_div++;
  }
#endif

  // find baud prescaler (10-bit wide))
  while (baud_div >= 0x3ffU) {
 66c:	3fe00593          	li	a1,1022
 670:	02f5e163          	bltu	a1,a5,692 <neorv32_uart_setup+0x36>
  }

  uint32_t tmp = 0;
  tmp |= (uint32_t)(1              & 1U)     << UART_CTRL_EN;
  tmp |= (uint32_t)(prsc_sel       & 3U)     << UART_CTRL_PRSC_LSB;
  tmp |= (uint32_t)((baud_div - 1) & 0x3ffU) << UART_CTRL_BAUD_LSB;
 674:	17fd                	addi	a5,a5,-1 # fffdffff <__crt0_stack_top+0x7ffdbfff>
 676:	3ff7f793          	andi	a5,a5,1023
  tmp |= (uint32_t)(irq_mask       & (0xfu   << UART_CTRL_IRQ_RX_NEMPTY));
 67a:	00f006b7          	lui	a3,0xf00
  tmp |= (uint32_t)((baud_div - 1) & 0x3ffU) << UART_CTRL_BAUD_LSB;
 67e:	079a                	slli	a5,a5,0x6
  tmp |= (uint32_t)(irq_mask       & (0xfu   << UART_CTRL_IRQ_RX_NEMPTY));
 680:	8e75                	and	a2,a2,a3
  tmp |= (uint32_t)(prsc_sel       & 3U)     << UART_CTRL_PRSC_LSB;
 682:	070e                	slli	a4,a4,0x3
  tmp |= (uint32_t)(irq_mask       & (0xfu   << UART_CTRL_IRQ_RX_NEMPTY));
 684:	8fd1                	or	a5,a5,a2
  tmp |= (uint32_t)(prsc_sel       & 3U)     << UART_CTRL_PRSC_LSB;
 686:	8b61                	andi	a4,a4,24
  tmp |= (uint32_t)(irq_mask       & (0xfu   << UART_CTRL_IRQ_RX_NEMPTY));
 688:	8fd9                	or	a5,a5,a4
 68a:	0017e793          	ori	a5,a5,1
  if (((uint32_t)UARTx) == NEORV32_UART1_BASE) {
    tmp |= 1U << UART_CTRL_SIM_MODE;
  }
#endif

  UARTx->CTRL = tmp;
 68e:	c11c                	sw	a5,0(a0)
}
 690:	8082                	ret
    if ((prsc_sel == 2) || (prsc_sel == 4))
 692:	ffe70693          	addi	a3,a4,-2
 696:	9af5                	andi	a3,a3,-3
 698:	e681                	bnez	a3,6a0 <neorv32_uart_setup+0x44>
      baud_div >>= 3;
 69a:	838d                	srli	a5,a5,0x3
    prsc_sel++;
 69c:	0705                	addi	a4,a4,1
 69e:	bfc9                	j	670 <neorv32_uart_setup+0x14>
      baud_div >>= 1;
 6a0:	8385                	srli	a5,a5,0x1
 6a2:	bfed                	j	69c <neorv32_uart_setup+0x40>

000006a4 <neorv32_uart_putc>:
 * @param[in,out] UARTx Hardware handle to UART register struct, #neorv32_uart_t.
 * @param[in] c Char to be send.
 **************************************************************************/
void neorv32_uart_putc(neorv32_uart_t *UARTx, char c) {

  while ((UARTx->CTRL & (1<<UART_CTRL_TX_NFULL)) == 0); // wait for free space in TX FIFO
 6a4:	411c                	lw	a5,0(a0)
 6a6:	00c79713          	slli	a4,a5,0xc
 6aa:	fe075de3          	bgez	a4,6a4 <neorv32_uart_putc>
void neorv32_uart_tx_put(neorv32_uart_t *UARTx, char c) {

#ifdef UART_SEMIHOSTING
  neorv32_semihosting_putc(c);
#else
  UARTx->DATA = (uint32_t)c << UART_DATA_RTX_LSB;
 6ae:	c14c                	sw	a1,4(a0)
}
 6b0:	8082                	ret

000006b2 <neorv32_uart_puts>:
 * @warning "/n" line breaks are automatically converted to "/r/n".
 *
 * @param[in,out] UARTx Hardware handle to UART register struct, #neorv32_uart_t.
 * @param[in] s Pointer to string.
 **************************************************************************/
void neorv32_uart_puts(neorv32_uart_t *UARTx, const char *s) {
 6b2:	1101                	addi	sp,sp,-32
 6b4:	cc22                	sw	s0,24(sp)
 6b6:	c84a                	sw	s2,16(sp)
 6b8:	ce06                	sw	ra,28(sp)
 6ba:	ca26                	sw	s1,20(sp)
 6bc:	842e                	mv	s0,a1
#ifdef UART_SEMIHOSTING
  neorv32_semihosting_puts(s);
#else
  char c = 0;
  while ((c = *s++)) {
    if (c == '\n') {
 6be:	4929                	li	s2,10
  while ((c = *s++)) {
 6c0:	00044483          	lbu	s1,0(s0)
 6c4:	e499                	bnez	s1,6d2 <neorv32_uart_puts+0x20>
      neorv32_uart_putc(UARTx, '\r');
    }
    neorv32_uart_putc(UARTx, c);
  }
#endif
}
 6c6:	40f2                	lw	ra,28(sp)
 6c8:	4462                	lw	s0,24(sp)
 6ca:	44d2                	lw	s1,20(sp)
 6cc:	4942                	lw	s2,16(sp)
 6ce:	6105                	addi	sp,sp,32
 6d0:	8082                	ret
  while ((c = *s++)) {
 6d2:	0405                	addi	s0,s0,1
    if (c == '\n') {
 6d4:	01249663          	bne	s1,s2,6e0 <neorv32_uart_puts+0x2e>
      neorv32_uart_putc(UARTx, '\r');
 6d8:	45b5                	li	a1,13
 6da:	c62a                	sw	a0,12(sp)
 6dc:	37e1                	jal	6a4 <neorv32_uart_putc>
 6de:	4532                	lw	a0,12(sp)
    neorv32_uart_putc(UARTx, c);
 6e0:	85a6                	mv	a1,s1
 6e2:	c62a                	sw	a0,12(sp)
 6e4:	37c1                	jal	6a4 <neorv32_uart_putc>
 6e6:	4532                	lw	a0,12(sp)
 6e8:	bfe1                	j	6c0 <neorv32_uart_puts+0xe>

000006ea <neorv32_uart_vprintf>:
 *
 * @param[in,out] UARTx Hardware handle to UART register struct, #neorv32_uart_t.
 * @param[in] format Pointer to format string.
 * @param[in] args A value identifying a variable arguments list.
 **************************************************************************/
void neorv32_uart_vprintf(neorv32_uart_t *UARTx, const char *format, va_list args) {
 6ea:	711d                	addi	sp,sp,-96
 6ec:	cca2                	sw	s0,88(sp)
 6ee:	caa6                	sw	s1,84(sp)
 6f0:	c8ca                	sw	s2,80(sp)
 6f2:	da66                	sw	s9,52(sp)
 6f4:	84ae                	mv	s1,a1
 6f6:	8caa                	mv	s9,a0
 6f8:	8432                	mv	s0,a2
  int32_t n = 0;
  unsigned int i = 0;

  // prevent uninitialized stack bytes
  for (i=0; i<sizeof(string_buf); i++) {
    string_buf[i] = 0;
 6fa:	4581                	li	a1,0
 6fc:	02400613          	li	a2,36
 700:	0068                	addi	a0,sp,12
  }

  while ((c = *format++)) {
    if (c == '%') {
      c = tolower(*format++);
 702:	6905                	lui	s2,0x1
void neorv32_uart_vprintf(neorv32_uart_t *UARTx, const char *format, va_list args) {
 704:	c6ce                	sw	s3,76(sp)
 706:	c2d6                	sw	s5,68(sp)
 708:	c0da                	sw	s6,64(sp)
 70a:	de5e                	sw	s7,60(sp)
 70c:	ce86                	sw	ra,92(sp)
 70e:	c4d2                	sw	s4,72(sp)
 710:	dc62                	sw	s8,56(sp)
    if (c == '%') {
 712:	02500a93          	li	s5,37
    string_buf[i] = 0;
 716:	2289                	jal	858 <memset>
          neorv32_uart_putc(UARTx, c);
          break;
      }
    }
    else {
      if (c == '\n') {
 718:	4b29                	li	s6,10
      c = tolower(*format++);
 71a:	13d90913          	addi	s2,s2,317 # 113d <_ctype_+0x1>
 71e:	4b85                	li	s7,1
      switch (c) {
 720:	07000993          	li	s3,112
  while ((c = *format++)) {
 724:	0004cc03          	lbu	s8,0(s1)
 728:	000c1f63          	bnez	s8,746 <neorv32_uart_vprintf+0x5c>
        neorv32_uart_putc(UARTx, '\r');
      }
      neorv32_uart_putc(UARTx, c);
    }
  }
}
 72c:	40f6                	lw	ra,92(sp)
 72e:	4466                	lw	s0,88(sp)
 730:	44d6                	lw	s1,84(sp)
 732:	4946                	lw	s2,80(sp)
 734:	49b6                	lw	s3,76(sp)
 736:	4a26                	lw	s4,72(sp)
 738:	4a96                	lw	s5,68(sp)
 73a:	4b06                	lw	s6,64(sp)
 73c:	5bf2                	lw	s7,60(sp)
 73e:	5c62                	lw	s8,56(sp)
 740:	5cd2                	lw	s9,52(sp)
 742:	6125                	addi	sp,sp,96
 744:	8082                	ret
    if (c == '%') {
 746:	0f5c1263          	bne	s8,s5,82a <neorv32_uart_vprintf+0x140>
      c = tolower(*format++);
 74a:	00248a13          	addi	s4,s1,2
 74e:	0014c483          	lbu	s1,1(s1)
 752:	012487b3          	add	a5,s1,s2
 756:	0007c783          	lbu	a5,0(a5)
 75a:	8b8d                	andi	a5,a5,3
 75c:	01779463          	bne	a5,s7,764 <neorv32_uart_vprintf+0x7a>
 760:	02048493          	addi	s1,s1,32
      switch (c) {
 764:	0ff4f593          	zext.b	a1,s1
 768:	0b358063          	beq	a1,s3,808 <neorv32_uart_vprintf+0x11e>
 76c:	06b9c163          	blt	s3,a1,7ce <neorv32_uart_vprintf+0xe4>
 770:	06300793          	li	a5,99
 774:	06f58d63          	beq	a1,a5,7ee <neorv32_uart_vprintf+0x104>
 778:	00b7cf63          	blt	a5,a1,796 <neorv32_uart_vprintf+0xac>
 77c:	02500793          	li	a5,37
 780:	00f58863          	beq	a1,a5,790 <neorv32_uart_vprintf+0xa6>
          neorv32_uart_putc(UARTx, '%');
 784:	02500593          	li	a1,37
 788:	8566                	mv	a0,s9
 78a:	3f29                	jal	6a4 <neorv32_uart_putc>
          neorv32_uart_putc(UARTx, c);
 78c:	0ff4f593          	zext.b	a1,s1
      neorv32_uart_putc(UARTx, c);
 790:	8566                	mv	a0,s9
 792:	3f09                	jal	6a4 <neorv32_uart_putc>
 794:	a095                	j	7f8 <neorv32_uart_vprintf+0x10e>
      switch (c) {
 796:	06400793          	li	a5,100
 79a:	00f58663          	beq	a1,a5,7a6 <neorv32_uart_vprintf+0xbc>
 79e:	06900793          	li	a5,105
 7a2:	fef591e3          	bne	a1,a5,784 <neorv32_uart_vprintf+0x9a>
          n = (int32_t)va_arg(args, int32_t);
 7a6:	00440493          	addi	s1,s0,4
 7aa:	4000                	lw	s0,0(s0)
          if (n < 0) {
 7ac:	00045863          	bgez	s0,7bc <neorv32_uart_vprintf+0xd2>
            neorv32_uart_putc(UARTx, '-');
 7b0:	02d00593          	li	a1,45
 7b4:	8566                	mv	a0,s9
            n = -n;
 7b6:	40800433          	neg	s0,s0
            neorv32_uart_putc(UARTx, '-');
 7ba:	35ed                	jal	6a4 <neorv32_uart_putc>
          neorv32_aux_itoa(string_buf, (uint32_t)n, 10);
 7bc:	4629                	li	a2,10
 7be:	85a2                	mv	a1,s0
 7c0:	0068                	addi	a0,sp,12
 7c2:	3bdd                	jal	5b8 <neorv32_aux_itoa>
          neorv32_uart_puts(UARTx, string_buf);
 7c4:	006c                	addi	a1,sp,12
 7c6:	8566                	mv	a0,s9
 7c8:	35ed                	jal	6b2 <neorv32_uart_puts>
          neorv32_aux_itoa(string_buf, va_arg(args, uint32_t), 16);
 7ca:	8426                	mv	s0,s1
          break;
 7cc:	a035                	j	7f8 <neorv32_uart_vprintf+0x10e>
      switch (c) {
 7ce:	07500793          	li	a5,117
 7d2:	02f58563          	beq	a1,a5,7fc <neorv32_uart_vprintf+0x112>
 7d6:	07800793          	li	a5,120
 7da:	02f58763          	beq	a1,a5,808 <neorv32_uart_vprintf+0x11e>
 7de:	07300793          	li	a5,115
 7e2:	faf591e3          	bne	a1,a5,784 <neorv32_uart_vprintf+0x9a>
          neorv32_uart_puts(UARTx, va_arg(args, char*));
 7e6:	400c                	lw	a1,0(s0)
          neorv32_uart_puts(UARTx, string_buf);
 7e8:	8566                	mv	a0,s9
 7ea:	35e1                	jal	6b2 <neorv32_uart_puts>
          break;
 7ec:	a029                	j	7f6 <neorv32_uart_vprintf+0x10c>
          neorv32_uart_putc(UARTx, (char)va_arg(args, int));
 7ee:	00044583          	lbu	a1,0(s0)
 7f2:	8566                	mv	a0,s9
 7f4:	3d45                	jal	6a4 <neorv32_uart_putc>
 7f6:	0411                	addi	s0,s0,4
          neorv32_uart_puts(UARTx, va_arg(args, char*));
 7f8:	84d2                	mv	s1,s4
 7fa:	b72d                	j	724 <neorv32_uart_vprintf+0x3a>
          neorv32_aux_itoa(string_buf, va_arg(args, uint32_t), 10);
 7fc:	400c                	lw	a1,0(s0)
 7fe:	4629                	li	a2,10
 800:	0068                	addi	a0,sp,12
 802:	3b5d                	jal	5b8 <neorv32_aux_itoa>
          neorv32_uart_puts(UARTx, string_buf);
 804:	006c                	addi	a1,sp,12
 806:	b7cd                	j	7e8 <neorv32_uart_vprintf+0xfe>
          neorv32_aux_itoa(string_buf, va_arg(args, uint32_t), 16);
 808:	400c                	lw	a1,0(s0)
 80a:	4641                	li	a2,16
 80c:	0068                	addi	a0,sp,12
 80e:	336d                	jal	5b8 <neorv32_aux_itoa>
          i = 8 - strlen(string_buf);
 810:	0068                	addi	a0,sp,12
          neorv32_aux_itoa(string_buf, va_arg(args, uint32_t), 16);
 812:	00440493          	addi	s1,s0,4
          i = 8 - strlen(string_buf);
 816:	2ac9                	jal	9e8 <strlen>
 818:	4421                	li	s0,8
 81a:	8c09                	sub	s0,s0,a0
          while (i--) { // add leading zeros
 81c:	d445                	beqz	s0,7c4 <neorv32_uart_vprintf+0xda>
            neorv32_uart_putc(UARTx, '0');
 81e:	03000593          	li	a1,48
 822:	8566                	mv	a0,s9
          while (i--) { // add leading zeros
 824:	147d                	addi	s0,s0,-1
            neorv32_uart_putc(UARTx, '0');
 826:	3dbd                	jal	6a4 <neorv32_uart_putc>
 828:	bfd5                	j	81c <neorv32_uart_vprintf+0x132>
  while ((c = *format++)) {
 82a:	00148a13          	addi	s4,s1,1
      if (c == '\n') {
 82e:	016c1563          	bne	s8,s6,838 <neorv32_uart_vprintf+0x14e>
        neorv32_uart_putc(UARTx, '\r');
 832:	45b5                	li	a1,13
 834:	8566                	mv	a0,s9
 836:	35bd                	jal	6a4 <neorv32_uart_putc>
      neorv32_uart_putc(UARTx, c);
 838:	85e2                	mv	a1,s8
 83a:	bf99                	j	790 <neorv32_uart_vprintf+0xa6>

0000083c <neorv32_uart_printf>:
 * @note This function is blocking.
 *
 * @param[in,out] UARTx Hardware handle to UART register struct, #neorv32_uart_t.
 * @param[in] format Pointer to format string. See neorv32_uart_vprintf.
 **************************************************************************/
void neorv32_uart_printf(neorv32_uart_t *UARTx, const char *format, ...) {
 83c:	7139                	addi	sp,sp,-64
 83e:	d432                	sw	a2,40(sp)

  va_list args;
  va_start(args, format);
 840:	1030                	addi	a2,sp,40
void neorv32_uart_printf(neorv32_uart_t *UARTx, const char *format, ...) {
 842:	ce06                	sw	ra,28(sp)
 844:	d636                	sw	a3,44(sp)
 846:	d83a                	sw	a4,48(sp)
 848:	da3e                	sw	a5,52(sp)
 84a:	dc42                	sw	a6,56(sp)
 84c:	de46                	sw	a7,60(sp)
  va_start(args, format);
 84e:	c632                	sw	a2,12(sp)
  neorv32_uart_vprintf(UARTx, format, args);
 850:	3d69                	jal	6ea <neorv32_uart_vprintf>
  va_end(args);
}
 852:	40f2                	lw	ra,28(sp)
 854:	6121                	addi	sp,sp,64
 856:	8082                	ret

00000858 <memset>:
 858:	433d                	li	t1,15
 85a:	872a                	mv	a4,a0
 85c:	02c37363          	bgeu	t1,a2,882 <memset+0x2a>
 860:	00f77793          	andi	a5,a4,15
 864:	efbd                	bnez	a5,8e2 <memset+0x8a>
 866:	e5ad                	bnez	a1,8d0 <memset+0x78>
 868:	ff067693          	andi	a3,a2,-16
 86c:	8a3d                	andi	a2,a2,15
 86e:	96ba                	add	a3,a3,a4
 870:	c30c                	sw	a1,0(a4)
 872:	c34c                	sw	a1,4(a4)
 874:	c70c                	sw	a1,8(a4)
 876:	c74c                	sw	a1,12(a4)
 878:	0741                	addi	a4,a4,16
 87a:	fed76be3          	bltu	a4,a3,870 <memset+0x18>
 87e:	e211                	bnez	a2,882 <memset+0x2a>
 880:	8082                	ret
 882:	40c306b3          	sub	a3,t1,a2
 886:	068a                	slli	a3,a3,0x2
 888:	00000297          	auipc	t0,0x0
 88c:	9696                	add	a3,a3,t0
 88e:	00a68067          	jr	10(a3) # f0000a <__neorv32_rom_size+0xef000a>
 892:	00b70723          	sb	a1,14(a4)
 896:	00b706a3          	sb	a1,13(a4)
 89a:	00b70623          	sb	a1,12(a4)
 89e:	00b705a3          	sb	a1,11(a4)
 8a2:	00b70523          	sb	a1,10(a4)
 8a6:	00b704a3          	sb	a1,9(a4)
 8aa:	00b70423          	sb	a1,8(a4)
 8ae:	00b703a3          	sb	a1,7(a4)
 8b2:	00b70323          	sb	a1,6(a4)
 8b6:	00b702a3          	sb	a1,5(a4)
 8ba:	00b70223          	sb	a1,4(a4)
 8be:	00b701a3          	sb	a1,3(a4)
 8c2:	00b70123          	sb	a1,2(a4)
 8c6:	00b700a3          	sb	a1,1(a4)
 8ca:	00b70023          	sb	a1,0(a4)
 8ce:	8082                	ret
 8d0:	0ff5f593          	zext.b	a1,a1
 8d4:	00859693          	slli	a3,a1,0x8
 8d8:	8dd5                	or	a1,a1,a3
 8da:	01059693          	slli	a3,a1,0x10
 8de:	8dd5                	or	a1,a1,a3
 8e0:	b761                	j	868 <memset+0x10>
 8e2:	00279693          	slli	a3,a5,0x2
 8e6:	00000297          	auipc	t0,0x0
 8ea:	9696                	add	a3,a3,t0
 8ec:	8286                	mv	t0,ra
 8ee:	fa8680e7          	jalr	-88(a3)
 8f2:	8096                	mv	ra,t0
 8f4:	17c1                	addi	a5,a5,-16
 8f6:	8f1d                	sub	a4,a4,a5
 8f8:	963e                	add	a2,a2,a5
 8fa:	f8c374e3          	bgeu	t1,a2,882 <memset+0x2a>
 8fe:	b7a5                	j	866 <memset+0xe>

00000900 <memcpy>:
 900:	00a5c7b3          	xor	a5,a1,a0
 904:	8b8d                	andi	a5,a5,3
 906:	00c508b3          	add	a7,a0,a2
 90a:	e7b1                	bnez	a5,956 <memcpy+0x56>
 90c:	00463613          	sltiu	a2,a2,4
 910:	e239                	bnez	a2,956 <memcpy+0x56>
 912:	00357793          	andi	a5,a0,3
 916:	872a                	mv	a4,a0
 918:	e7cd                	bnez	a5,9c2 <memcpy+0xc2>
 91a:	ffc8f613          	andi	a2,a7,-4
 91e:	40e606b3          	sub	a3,a2,a4
 922:	02000793          	li	a5,32
 926:	04d7c463          	blt	a5,a3,96e <memcpy+0x6e>
 92a:	86ae                	mv	a3,a1
 92c:	87ba                	mv	a5,a4
 92e:	02c77163          	bgeu	a4,a2,950 <memcpy+0x50>
 932:	0006a803          	lw	a6,0(a3)
 936:	0791                	addi	a5,a5,4
 938:	0691                	addi	a3,a3,4
 93a:	ff07ae23          	sw	a6,-4(a5)
 93e:	fec7eae3          	bltu	a5,a2,932 <memcpy+0x32>
 942:	167d                	addi	a2,a2,-1
 944:	8e19                	sub	a2,a2,a4
 946:	9a71                	andi	a2,a2,-4
 948:	0591                	addi	a1,a1,4
 94a:	0711                	addi	a4,a4,4
 94c:	95b2                	add	a1,a1,a2
 94e:	9732                	add	a4,a4,a2
 950:	01176663          	bltu	a4,a7,95c <memcpy+0x5c>
 954:	8082                	ret
 956:	872a                	mv	a4,a0
 958:	ff157ee3          	bgeu	a0,a7,954 <memcpy+0x54>
 95c:	0005c783          	lbu	a5,0(a1)
 960:	0705                	addi	a4,a4,1
 962:	0585                	addi	a1,a1,1
 964:	fef70fa3          	sb	a5,-1(a4)
 968:	fee89ae3          	bne	a7,a4,95c <memcpy+0x5c>
 96c:	8082                	ret
 96e:	4194                	lw	a3,0(a1)
 970:	0045a283          	lw	t0,4(a1)
 974:	0085af83          	lw	t6,8(a1)
 978:	00c5af03          	lw	t5,12(a1)
 97c:	0105ae83          	lw	t4,16(a1)
 980:	0145ae03          	lw	t3,20(a1)
 984:	0185a303          	lw	t1,24(a1)
 988:	01c5a803          	lw	a6,28(a1)
 98c:	c314                	sw	a3,0(a4)
 98e:	5194                	lw	a3,32(a1)
 990:	02470713          	addi	a4,a4,36
 994:	fe572023          	sw	t0,-32(a4)
 998:	fed72e23          	sw	a3,-4(a4)
 99c:	fff72223          	sw	t6,-28(a4)
 9a0:	40e606b3          	sub	a3,a2,a4
 9a4:	ffe72423          	sw	t5,-24(a4)
 9a8:	ffd72623          	sw	t4,-20(a4)
 9ac:	ffc72823          	sw	t3,-16(a4)
 9b0:	fe672a23          	sw	t1,-12(a4)
 9b4:	ff072c23          	sw	a6,-8(a4)
 9b8:	02458593          	addi	a1,a1,36
 9bc:	fad7c9e3          	blt	a5,a3,96e <memcpy+0x6e>
 9c0:	b7ad                	j	92a <memcpy+0x2a>
 9c2:	0005c683          	lbu	a3,0(a1)
 9c6:	0705                	addi	a4,a4,1
 9c8:	00377793          	andi	a5,a4,3
 9cc:	fed70fa3          	sb	a3,-1(a4)
 9d0:	0585                	addi	a1,a1,1
 9d2:	d7a1                	beqz	a5,91a <memcpy+0x1a>
 9d4:	0005c683          	lbu	a3,0(a1)
 9d8:	0705                	addi	a4,a4,1
 9da:	00377793          	andi	a5,a4,3
 9de:	fed70fa3          	sb	a3,-1(a4)
 9e2:	0585                	addi	a1,a1,1
 9e4:	fff9                	bnez	a5,9c2 <memcpy+0xc2>
 9e6:	bf15                	j	91a <memcpy+0x1a>

000009e8 <strlen>:
 9e8:	00357793          	andi	a5,a0,3
 9ec:	872a                	mv	a4,a0
 9ee:	ef9d                	bnez	a5,a2c <strlen+0x44>
 9f0:	7f7f86b7          	lui	a3,0x7f7f8
 9f4:	f7f68693          	addi	a3,a3,-129 # 7f7f7f7f <__neorv32_rom_size+0x7f7e7f7f>
 9f8:	55fd                	li	a1,-1
 9fa:	4310                	lw	a2,0(a4)
 9fc:	0711                	addi	a4,a4,4
 9fe:	00d677b3          	and	a5,a2,a3
 a02:	97b6                	add	a5,a5,a3
 a04:	8fd1                	or	a5,a5,a2
 a06:	8fd5                	or	a5,a5,a3
 a08:	feb789e3          	beq	a5,a1,9fa <strlen+0x12>
 a0c:	ffc74683          	lbu	a3,-4(a4)
 a10:	40a707b3          	sub	a5,a4,a0
 a14:	ca8d                	beqz	a3,a46 <strlen+0x5e>
 a16:	ffd74683          	lbu	a3,-3(a4)
 a1a:	c29d                	beqz	a3,a40 <strlen+0x58>
 a1c:	ffe74503          	lbu	a0,-2(a4)
 a20:	00a03533          	snez	a0,a0
 a24:	953e                	add	a0,a0,a5
 a26:	1579                	addi	a0,a0,-2
 a28:	8082                	ret
 a2a:	d2f9                	beqz	a3,9f0 <strlen+0x8>
 a2c:	00074783          	lbu	a5,0(a4)
 a30:	0705                	addi	a4,a4,1
 a32:	00377693          	andi	a3,a4,3
 a36:	fbf5                	bnez	a5,a2a <strlen+0x42>
 a38:	8f09                	sub	a4,a4,a0
 a3a:	fff70513          	addi	a0,a4,-1
 a3e:	8082                	ret
 a40:	ffd78513          	addi	a0,a5,-3
 a44:	8082                	ret
 a46:	ffc78513          	addi	a0,a5,-4
 a4a:	8082                	ret
