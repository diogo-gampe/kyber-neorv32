library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;
use std.textio.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_pq_alu_ise_tb is
  generic (
    CLOCK_FREQUENCY : natural := 50_000_000;
    CLK_PERIOD      : time    := 20 ns;
    IMEM_SIZE       : natural := 64*1024;
    DMEM_SIZE       : natural := 16*1024;
    TRACE_LOG_EN    : boolean := false;
    UART0_BAUD      : natural := 115_200
  );
end entity;

architecture sim of neorv32_pq_alu_ise_tb is

  signal clk        : std_ulogic := '0';
  signal rstn       : std_ulogic := '0';

  signal trace_cpu0 : trace_port_t;
  signal trace_cpu1 : trace_port_t;

  -- Campos achatados da porta de trace para formatos como VCD, que nao
  -- registram diretamente records VHDL. Estes sinais mostram a instrucao
  -- aposentada e os operandos/resultados observados pelo pipeline.
  signal trace_valid     : std_ulogic;
  signal trace_order     : std_ulogic_vector(31 downto 0);
  signal trace_pc        : std_ulogic_vector(31 downto 0);
  signal trace_insn      : std_ulogic_vector(31 downto 0);
  signal trace_cmd32     : std_ulogic_vector(31 downto 0);
  signal trace_rs1_addr  : std_ulogic_vector(4 downto 0);
  signal trace_rs2_addr  : std_ulogic_vector(4 downto 0);
  signal trace_rd_addr   : std_ulogic_vector(4 downto 0);
  signal trace_rs1_data  : std_ulogic_vector(31 downto 0);
  signal trace_rs2_data  : std_ulogic_vector(31 downto 0);
  signal trace_rd_data   : std_ulogic_vector(31 downto 0);

  signal gpio_dir   : std_ulogic_vector(31 downto 0);
  signal gpio_out   : std_ulogic_vector(31 downto 0);
  signal gpio_in    : std_ulogic_vector(31 downto 0) := (others => '0');

  signal uart0_txd  : std_ulogic;

  signal mtime      : std_ulogic_vector(63 downto 0);

begin

  clk <= not clk after CLK_PERIOD/2;

  trace_valid    <= trace_cpu0.valid;
  trace_order    <= trace_cpu0.order;
  trace_pc       <= trace_cpu0.pc_rdata;
  trace_insn     <= trace_cpu0.insn;
  trace_cmd32    <= trace_cpu0.cmd32;
  trace_rs1_addr <= trace_cpu0.rs1_addr;
  trace_rs2_addr <= trace_cpu0.rs2_addr;
  trace_rd_addr  <= trace_cpu0.rd_addr;
  trace_rs1_data <= trace_cpu0.rs1_rdata;
  trace_rs2_data <= trace_cpu0.rs2_rdata;
  trace_rd_data  <= trace_cpu0.rd_rdata;

  reset_gen: process
  begin
    rstn <= '0';
    wait for 20*CLK_PERIOD;
    rstn <= '1';
    wait;
  end process reset_gen;

  neorv32_top_inst: neorv32_top
  generic map (
    -- General --
    CLOCK_FREQUENCY     => CLOCK_FREQUENCY,
    TRACE_PORT_EN       => true,
    DUAL_CORE_EN        => false,
    -- Boot Configuration --
    BOOT_MODE_SELECT    => 2,
    BOOT_ADDR_CUSTOM    => x"00000000",
    -- On-Chip Debugger (OCD) --
    OCD_EN              => false,
    OCD_NUM_HW_TRIGGERS => 0,
    OCD_AUTHENTICATION  => false,
    -- RISC-V CPU Extensions --
    RISCV_ISA_C         => true,
    RISCV_ISA_E         => false,
    RISCV_ISA_M         => true,
    RISCV_ISA_U         => false,
    RISCV_ISA_Zaamo     => false,
    RISCV_ISA_Zalrsc    => false,
    RISCV_ISA_Zcb       => true,
    RISCV_ISA_Zba       => true,
    RISCV_ISA_Zbb       => true,
    RISCV_ISA_Zbc       => true,
    RISCV_ISA_Zbkb      => true,
    RISCV_ISA_Zbkc      => true,
    RISCV_ISA_Zbkx      => true,
    RISCV_ISA_Zbs       => true,
    RISCV_ISA_Zfinx     => false,
    RISCV_ISA_Zibi      => false,
    RISCV_ISA_Zicntr    => true,
    RISCV_ISA_Zicond    => false,
    RISCV_ISA_Zihpm     => false,
    RISCV_ISA_Zimop     => false,
    RISCV_ISA_Zknd      => true,
    RISCV_ISA_Zkne      => true,
    RISCV_ISA_Zknh      => true,
    RISCV_ISA_Zksed     => true,
    RISCV_ISA_Zksh      => true,
    RISCV_ISA_Zmmul     => true,
    RISCV_ISA_Smcntrpmf => false,
    RISCV_ISA_Xcfu      => true,
    -- Extension Options --
    CPU_CONSTT_BR_EN    => true,
    CPU_FAST_MUL_EN     => true,
    CPU_FAST_SHIFT_EN   => true,
    CPU_RF_ARCH_SEL     => 0,
    -- Physical Memory Protection (PMP) --
    PMP_NUM_REGIONS     => 0,
    PMP_MIN_GRANULARITY => 4,
    PMP_TOR_MODE_EN     => false,
    PMP_NAP_MODE_EN     => false,
    -- Hardware Performance Monitors (HPM) --
    HPM_NUM_CNTS        => 0,
    HPM_CNT_WIDTH       => 0,
    -- Internal Instruction memory --
    IMEM_EN             => true,
    IMEM_BASE           => x"00000000",
    IMEM_SIZE           => IMEM_SIZE,
    IMEM_OUTREG_EN      => false,
    -- Internal Data memory --
    DMEM_EN             => true,
    DMEM_BASE           => x"80000000",
    DMEM_SIZE           => DMEM_SIZE,
    DMEM_OUTREG_EN      => false,
    -- CPU Caches --
    ICACHE_EN           => true,
    ICACHE_NUM_BLOCKS   => 16,
    DCACHE_EN           => true,
    DCACHE_NUM_BLOCKS   => 16,
    CACHE_BLOCK_SIZE    => 1024,
    CACHE_BURSTS_EN     => false,
    CACHE_UC_BASE       => x"F0000000",
    -- External Bus Interface (XBUS) --
    XBUS_EN             => false,
    XBUS_TIMEOUT        => 2048,
    XBUS_REGSTAGE_EN    => false,
    -- General-Purpose Input/Output Controller (GPIO) --
    IO_GPIO_NUM         => 32,
    IO_GPIO_DIR_EN      => true,
    -- RISC-V Core-Local Interruptor (CLINT) --
    IO_CLINT_EN         => false,
    -- Universal Asynchronous Receiver/Transmitter (UART0/UART1) --
    IO_UART0_EN         => true,
    IO_UART0_RX_FIFO    => 1,
    IO_UART0_TX_FIFO    => 1,
    IO_UART1_EN         => false,
    IO_UART1_RX_FIFO    => 1,
    IO_UART1_TX_FIFO    => 1,
    -- Serial Peripheral Interface (SPI Host, SDI Device) --
    IO_SPI_EN           => false,
    IO_SPI_FIFO         => 1,
    IO_SDI_EN           => false,
    IO_SDI_FIFO         => 1,
    -- Two-Wire Interface (TWI Host, TWD Device) --
    IO_TWI_EN           => false,
    IO_TWI_FIFO         => 1,
    IO_TWD_EN           => false,
    IO_TWD_RX_FIFO      => 1,
    IO_TWD_TX_FIFO      => 1,
    -- Pulse-Width Modulation Controller (PWM) --
    IO_PWM_NUM          => 0,
    -- Watchdog Timer (WDT) --
    IO_WDT_EN           => false,
    -- True-Random Number Generator (TRNG) --
    IO_TRNG_EN          => false,
    IO_TRNG_FIFO        => 1,
    IO_TRNG_NUM_RO      => 3,
    IO_TRNG_NUM_INV     => 5,
    IO_TRNG_NUM_RBIT    => 64,
    -- Custom Functions Subsystem (CFS) --
    IO_CFS_EN           => false,
    -- Smart LED interface (NEOLED) --
    IO_NEOLED_EN        => false,
    IO_NEOLED_TX_FIFO   => 1,
    -- General-Purpose Timer (GPTMR) --
    IO_GPTMR_NUM        => 0,
    -- 1-Wire Interface (ONEWIRE) --
    IO_ONEWIRE_EN       => false,
    IO_ONEWIRE_FIFO     => 1,
    -- Direct Memory Access Controller (DMA) --
    IO_DMA_EN           => false,
    IO_DMA_DSC_FIFO     => 4,
    -- Stream Link Interface (SLINK) --
    IO_SLINK_EN         => false,
    IO_SLINK_RX_FIFO    => 1,
    IO_SLINK_TX_FIFO    => 1,
    -- Instruction Tracer (TRACER) --
    IO_TRACER_EN        => TRACE_LOG_EN,
    IO_TRACER_BUFFER    => 32,
    IO_TRACER_SIMLOG_EN => TRACE_LOG_EN
  )
  port map (
    -- Global control --
    clk_i          => clk,
    rstn_i         => rstn,
    rstn_ocd_o     => open,
    rstn_wdt_o     => open,
    -- Execution trace --
    trace_cpu0_o   => trace_cpu0,
    trace_cpu1_o   => trace_cpu1,
    -- JTAG on-chip debugger interface --
    jtag_tck_i     => '0',
    jtag_tdi_i     => '0',
    jtag_tdo_o     => open,
    jtag_tms_i     => '0',
    -- External bus interface --
    xbus_adr_o     => open,
    xbus_dat_o     => open,
    xbus_cti_o     => open,
    xbus_tag_o     => open,
    xbus_we_o      => open,
    xbus_sel_o     => open,
    xbus_stb_o     => open,
    xbus_cyc_o     => open,
    xbus_dat_i     => (others => '0'),
    xbus_ack_i     => '0',
    xbus_err_i     => '0',
    -- Stream Link Interface --
    slink_rx_dat_i => (others => '0'),
    slink_rx_src_i => (others => '0'),
    slink_rx_val_i => '0',
    slink_rx_lst_i => '0',
    slink_rx_rdy_o => open,
    slink_tx_dat_o => open,
    slink_tx_dst_o => open,
    slink_tx_val_o => open,
    slink_tx_lst_o => open,
    slink_tx_rdy_i => '0',
    -- GPIO --
    gpio_dir_o     => gpio_dir,
    gpio_o         => gpio_out,
    gpio_i         => gpio_in,
    -- primary UART0 --
    uart0_txd_o    => uart0_txd,
    uart0_rxd_i    => '1',
    uart0_rtsn_o   => open,
    uart0_ctsn_i   => '0',
    -- secondary UART1 --
    uart1_txd_o    => open,
    uart1_rxd_i    => '1',
    uart1_rtsn_o   => open,
    uart1_ctsn_i   => '0',
    -- SPI --
    spi_clk_o      => open,
    spi_dat_o      => open,
    spi_dat_i      => '0',
    spi_csn_o      => open,
    -- SDI --
    sdi_clk_i      => '0',
    sdi_dat_o      => open,
    sdi_dat_i      => '0',
    sdi_csn_i      => '1',
    -- TWI --
    twi_sda_i      => '1',
    twi_sda_o      => open,
    twi_scl_i      => '1',
    twi_scl_o      => open,
    -- TWD --
    twd_sda_i      => '1',
    twd_sda_o      => open,
    twd_scl_i      => '1',
    -- 1-Wire Interface --
    onewire_i      => '1',
    onewire_o      => open,
    -- PWM --
    pwm_o          => open,
    -- Custom Functions Subsystem IO --
    cfs_in_i       => (others => '0'),
    cfs_out_o      => open,
    -- NeoPixel-compatible smart LED interface --
    neoled_o       => open,
    -- Machine timer system time --
    mtime_time_o   => mtime,
    -- CPU Interrupts --
    irq_msi_i      => '0',
    irq_mti_i      => '0',
    irq_mei_i      => '0'
  );

  -- ---------------------------------------------------------------------
  -- Receptor UART0 (8N1): decodifica o que o firmware transmite via
  -- neorv32_uart0_printf() e imprime cada linha recebida.
  -- ---------------------------------------------------------------------
  uart0_monitor: process
    constant BIT_PERIOD : time := 1000 ms / UART0_BAUD;
    constant LF   : character := character'val(10);
    constant CR   : character := character'val(13);
    variable l    : line;
    variable data : std_ulogic_vector(7 downto 0);
    variable ch   : character;
  begin
    loop
      wait until falling_edge(uart0_txd); -- bit de start

      wait for BIT_PERIOD/2; -- centraliza a amostragem no meio de cada bit
      assert uart0_txd = '0'
        report "UART0: bit de start invalido" severity warning;

      for i in 0 to 7 loop -- LSB primeiro
        wait for BIT_PERIOD;
        data(i) := uart0_txd;
      end loop;

      wait for BIT_PERIOD; -- bit de stop (nao verificado)

      ch := character'val(to_integer(unsigned(data)));

      if ch = LF then
        writeline(output, l); -- imprime a linha acumulada
      elsif ch /= CR then
        write(l, ch);
      end if;
    end loop;
  end process uart0_monitor;

end architecture sim;
