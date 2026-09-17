-- VHDL-2008 translation of pq_alu_tb.v.
-- The same 48 checks use independent constants from ntt_trace.csv.
-- VHDL-2008 external names preserve the direct twiddle_q check without
-- adding a debug port to the DUT. Tested with GHDL 5.0.1.
--
-- Standalone run from the repository root (build files outside the sources):
--   mkdir -p /tmp/pq_alu_ghdl
--   ghdl -a --std=08 --workdir=/tmp/pq_alu_ghdl \
--     hw/rtl/kyber_neorv32/pq_alu.vhd hw/tb/pq_alu_tb/pq_alu_tb.vhd
--   ghdl -e --std=08 --workdir=/tmp/pq_alu_ghdl pq_alu_tb
--   ghdl -r --std=08 --workdir=/tmp/pq_alu_ghdl pq_alu_tb

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity pq_alu_tb is
end entity pq_alu_tb;

architecture sim of pq_alu_tb is
  subtype word_t is std_ulogic_vector(31 downto 0);
  subtype funct7_t is std_ulogic_vector(6 downto 0);
  constant FUNCT7_FQMUL       : funct7_t := "0000000";
  constant FUNCT7_REDUCE      : funct7_t := "0000001";
  constant FUNCT7_SET_TWIDDLE : funct7_t := "0000010";
  constant FUNCT7_NTT         : funct7_t := "0000011";
  constant FUNCT7_INTT        : funct7_t := "0000100";

  signal clk_i    : std_ulogic := '0';
  signal rstn_i   : std_ulogic := '0';
  signal start_i  : std_ulogic := '0';
  signal inst_i   : word_t := (others => '0');
  signal rs1_i    : word_t := (others => '0');
  signal rs2_i    : word_t := (others => '0');
  signal result_o : word_t;
  signal valid_o  : std_ulogic;

  function kyber_inst(funct7 : funct7_t) return word_t is
  begin
    -- funct7 | rs2=x2 | rs1=x1 | funct3=0 | rd=x3 | CUSTOM-0
    return funct7 & "00010" & "00001" & "000" & "00011" & "0001011";
  end function;

  function operation_name(funct7 : funct7_t) return string is
  begin
    case funct7 is
      when FUNCT7_FQMUL  => return "FQMUL";
      when FUNCT7_REDUCE => return "BARRETT_REDUCE";
      when FUNCT7_NTT    => return "NTT";
      when FUNCT7_INTT   => return "INTT";
      when others       => return "DESCONHECIDA";
    end case;
  end function;
begin
  dut : entity work.pq_alu
    port map (
      clk_i => clk_i, rstn_i => rstn_i, start_i => start_i,
      inst_i => inst_i, rs1_i => rs1_i, rs2_i => rs2_i,
      result_o => result_o, valid_o => valid_o
    );

  clk_i <= not clk_i after 5 ns;

  stimulus : process
    alias dut_twiddle is
      << signal .pq_alu_tb.dut.twiddle_q : signed(15 downto 0) >>;
    variable errors : natural := 0;
    variable tests  : natural := 0;

    procedure check_outputs(
      constant expected       : in word_t;
      constant expected_valid : in std_ulogic
    ) is
    begin
      -- Comparacoes exatas tambem rejeitam X/U, como !== no Verilog.
      if (valid_o /= expected_valid) or (result_o /= expected) then
        errors := errors + 1;
        report "FAIL | esperado=0x" & to_hstring(expected) &
               " | recebido=0x" & to_hstring(result_o) &
               " | valid esperado=" & std_ulogic'image(expected_valid) &
               " recebido=" & std_ulogic'image(valid_o);
      else
        report "PASS | esperado=0x" & to_hstring(expected) &
               " | recebido=0x" & to_hstring(result_o) &
               " | valid esperado=" & std_ulogic'image(expected_valid) &
               " recebido=" & std_ulogic'image(valid_o);
      end if;
    end procedure;

    procedure check_operation(
      constant funct7    : in funct7_t;
      constant operand_a : in word_t;
      constant operand_b : in word_t;
      constant expected  : in word_t
    ) is
    begin
      wait until falling_edge(clk_i);
      inst_i  <= kyber_inst(funct7);
      rs1_i   <= operand_a;
      rs2_i   <= operand_b;
      start_i <= '1';
      wait for 1 ns;

      tests := tests + 1;
      if funct7 = FUNCT7_REDUCE then
        report "[" & operation_name(funct7) & "] Teste " & natural'image(tests) &
               " | A=0x" & to_hstring(operand_a(15 downto 0)) &
               " (" & integer'image(to_integer(signed(operand_a(15 downto 0)))) &
               ") | saida esperada=0x" & to_hstring(expected);
      elsif (funct7 = FUNCT7_NTT) or (funct7 = FUNCT7_INTT) then
        report "[" & operation_name(funct7) & "] Teste " & natural'image(tests) &
               " | A=0x" & to_hstring(operand_a(15 downto 0)) &
               " (" & integer'image(to_integer(signed(operand_a(15 downto 0)))) &
               ") | B=0x" & to_hstring(operand_b(15 downto 0)) &
               " (" & integer'image(to_integer(signed(operand_b(15 downto 0)))) &
               ") | zeta=0x" & to_hstring(dut_twiddle) &
               " (" & integer'image(to_integer(dut_twiddle)) &
               ") | saida esperada=0x" & to_hstring(expected);
      else
        report "[" & operation_name(funct7) & "] Teste " & natural'image(tests) &
               " | A=0x" & to_hstring(operand_a(15 downto 0)) &
               " (" & integer'image(to_integer(signed(operand_a(15 downto 0)))) &
               ") | B=0x" & to_hstring(operand_b(15 downto 0)) &
               " (" & integer'image(to_integer(signed(operand_b(15 downto 0)))) &
               ") | saida esperada=0x" & to_hstring(expected);
      end if;

      check_outputs(expected, '1');
      wait until falling_edge(clk_i);
      start_i <= '0';
    end procedure;

    procedure set_twiddle(
      constant index         : in natural range 0 to 127;
      constant expected_zeta : in integer range -32768 to 32767
    ) is
    begin
      wait until falling_edge(clk_i);
      inst_i  <= kyber_inst(FUNCT7_SET_TWIDDLE);
      rs1_i   <= std_ulogic_vector(to_unsigned(index, 32));
      rs2_i   <= (others => '0');
      start_i <= '1';
      wait for 1 ns;

      -- The selected ROM word is captured on this rising edge.
      wait until rising_edge(clk_i);
      wait for 1 ns;

      tests := tests + 1;
      report "[SET_TWIDDLE] Teste " & natural'image(tests) &
             " | indice=" & natural'image(index) &
             " | zeta esperada=0x" & to_hstring(to_signed(expected_zeta, 16)) &
             " (" & integer'image(expected_zeta) &
             ") recebida=0x" & to_hstring(dut_twiddle) &
             " | saida esperada=0x00000000";
      -- Compara o twiddle diretamente com a constante esperada.
      -- Registra no maximo uma falha por teste.
      if std_ulogic_vector(dut_twiddle) /=
         std_ulogic_vector(to_signed(expected_zeta, 16)) then
        errors := errors + 1;
        report "FAIL | zeta esperada=0x" & to_hstring(to_signed(expected_zeta, 16)) &
               " recebida=0x" & to_hstring(dut_twiddle) &
               " | saida esperada=0x00000000 recebida=0x" & to_hstring(result_o) &
               " | valid esperado='1' recebido=" & std_ulogic'image(valid_o);
      else
        check_outputs(x"00000000", '1');
      end if;

      wait until falling_edge(clk_i);
      start_i <= '0';
    end procedure;

    procedure check_invalid_instruction is
    begin
      wait until falling_edge(clk_i);
      inst_i  <= (others => '0');
      rs1_i   <= (others => '0');
      rs2_i   <= (others => '0');
      start_i <= '1';
      wait for 1 ns;

      tests := tests + 1;
      report "[INSTRUCAO_INVALIDA] Teste " & natural'image(tests) &
             " | instrucao=0x" & to_hstring(inst_i) &
             " | saida esperada=0x00000000";
      check_outputs(x"00000000", '0');

      wait until falling_edge(clk_i);
      start_i <= '0';
    end procedure;
  begin
    wait until rising_edge(clk_i);
    wait until rising_edge(clk_i);
    rstn_i <= '1';

    check_invalid_instruction;

    -- Ten FQMUL vectors from the indicated ntt_trace.csv lines.
    -- Negative 16-bit scalar results are sign-extended to 32 bits.
    check_operation(FUNCT7_FQMUL, x"0000_0a0b", x"0000_00be", x"ffff_fbdb"); -- Linha 386
    check_operation(FUNCT7_FQMUL, x"0000_0a0b", x"0000_0080", x"0000_063e"); -- Linha 262
    check_operation(FUNCT7_FQMUL, x"0000_0b9a", x"ffff_fd04", x"ffff_fea0"); -- Linha 572
    check_operation(FUNCT7_FQMUL, x"0000_0a0b", x"0000_0081", x"ffff_fffe"); -- Linha 264
    check_operation(FUNCT7_FQMUL, x"0000_0626", x"ffff_fbf2", x"ffff_feca"); -- Linha 2352
    check_operation(FUNCT7_FQMUL, x"0000_09f8", x"0000_11b2", x"0000_046d"); -- Linha 1880
    check_operation(FUNCT7_FQMUL, x"0000_00ca", x"ffff_f7fe", x"ffff_fd6a"); -- Linha 1002
    check_operation(FUNCT7_FQMUL, x"0000_017f", x"0000_0252", x"0000_04c1"); -- Linha 1336
    check_operation(FUNCT7_FQMUL, x"0000_0bcd", x"ffff_f87c", x"ffff_f9cc"); -- Linha 2028
    check_operation(FUNCT7_FQMUL, x"0000_02dc", x"0000_05f0", x"0000_039c"); -- Linha 1458

    -- Ten BARRET_REDUCE vectors. Trace field b is an intermediate value;
    -- the instruction uses only rs1_i.
    check_operation(FUNCT7_REDUCE, x"0000_2528", x"0000_0000", x"0000_0b26"); -- Linha 2054
    check_operation(FUNCT7_REDUCE, x"ffff_f436", x"0000_0000", x"0000_0137"); -- Linha 2057
    check_operation(FUNCT7_REDUCE, x"0000_30bc", x"0000_0000", x"0000_09b9"); -- Linha 2060
    check_operation(FUNCT7_REDUCE, x"ffff_f86a", x"0000_0000", x"0000_056b"); -- Linha 2063
    check_operation(FUNCT7_REDUCE, x"0000_1458", x"0000_0000", x"0000_0757"); -- Linha 2066
    check_operation(FUNCT7_REDUCE, x"0000_0600", x"0000_0000", x"0000_0600"); -- Linha 2069
    check_operation(FUNCT7_REDUCE, x"0000_1d64", x"0000_0000", x"0000_0362"); -- Linha 2072
    check_operation(FUNCT7_REDUCE, x"0000_1798", x"0000_0000", x"0000_0a97"); -- Linha 2075
    check_operation(FUNCT7_REDUCE, x"0000_184e", x"0000_0000", x"0000_0b4d"); -- Linha 2078
    check_operation(FUNCT7_REDUCE, x"ffff_fee0", x"0000_0000", x"0000_0be1"); -- Linha 2375

    -- Nine first-layer butterflies use zeta[1] = 2571.
    set_twiddle(1, 2571);
    check_operation(FUNCT7_NTT, x"0000_0000", x"0000_0080", x"f9c2_063e"); -- Linha 263
    check_operation(FUNCT7_NTT, x"0000_0001", x"0000_0081", x"0003_ffff"); -- Linha 265
    check_operation(FUNCT7_NTT, x"0000_0002", x"0000_0082", x"0644_f9c0"); -- Linha 267
    check_operation(FUNCT7_NTT, x"0000_0003", x"0000_0083", x"ff84_0082"); -- Linha 269
    check_operation(FUNCT7_NTT, x"0000_0004", x"0000_0084", x"05c5_fa43"); -- Linha 271
    check_operation(FUNCT7_NTT, x"0000_0005", x"0000_0085", x"ff05_0105"); -- Linha 273
    check_operation(FUNCT7_NTT, x"0000_0006", x"0000_0086", x"0546_fac6"); -- Linha 275
    check_operation(FUNCT7_NTT, x"0000_0007", x"0000_0087", x"fe86_0188"); -- Linha 277
    check_operation(FUNCT7_NTT, x"0000_0008", x"0000_0088", x"04c7_fb49"); -- Linha 279

    -- Tenth butterfly: first operation of the second layer, zeta[2].
    set_twiddle(2, 2970);
    check_operation(FUNCT7_NTT, x"0000_063e", x"ffff_fc9c", x"026d_0a0f"); -- Linha 519

    -- Ten INTT butterflies. Each expectation concatenates
    -- {INV_BUTTERFLY.result, INV_BUTTERFLY.reduce} from ntt_trace.csv.
    set_twiddle(127, 1628);
    check_operation(FUNCT7_INTT, x"0000_167e", x"0000_0eaa", x"0449_0b26"); -- Linha 2056
    check_operation(FUNCT7_INTT, x"ffff_fe1c", x"ffff_f61a", x"fa5a_0137"); -- Linha 2059

    set_twiddle(126, 1522);
    check_operation(FUNCT7_INTT, x"0000_144a", x"0000_1c72", x"011d_09b9"); -- Linha 2062
    check_operation(FUNCT7_INTT, x"ffff_f84b", x"0000_001f", x"fccf_056b"); -- Linha 2065

    set_twiddle(125, 1869);
    check_operation(FUNCT7_INTT, x"0000_09b3", x"0000_0aa5", x"04a9_0757"); -- Linha 2068
    check_operation(FUNCT7_INTT, x"0000_0895", x"ffff_fd6b", x"0352_0600"); -- Linha 2071

    set_twiddle(124, 958);
    check_operation(FUNCT7_INTT, x"0000_0a93", x"0000_12d1", x"04cb_0362"); -- Linha 2074
    check_operation(FUNCT7_INTT, x"0000_0f06", x"0000_0892", x"feff_0a97"); -- Linha 2077

    set_twiddle(123, 991);
    check_operation(FUNCT7_INTT, x"0000_07b3", x"0000_109b", x"fcc7_0b4d"); -- Linha 2080
    check_operation(FUNCT7_INTT, x"0000_1024", x"0000_0de8", x"0285_040a"); -- Linha 2083

    report "============================================================";
    if errors = 0 then
      report "PQ_ALU_TB PASS | testes=" & natural'image(tests) &
             " | aprovados=" & natural'image(tests) & " | falhas=0";
      finish(0);
    else
      report "PQ_ALU_TB FAIL | testes=" & natural'image(tests) &
             " | aprovados=" & natural'image(tests - errors) &
             " | falhas=" & natural'image(errors);
      -- Unlike the original unconditional $finish, signal failure to scripts.
      finish(1);
    end if;
    wait;
  end process stimulus;
end architecture sim;
