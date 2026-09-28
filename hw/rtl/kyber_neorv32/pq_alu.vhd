-- VHDL translation of pq_alu.v (VHDL-2008 / ieee.numeric_std).
-- Kyber PQ-ALU derived from the proposal by Nannipieri et al.
--
-- R-type CUSTOM-0 instructions: opcode = 0001011, funct3 = 000.
-- funct7: 0 = fqmul_k, 1 = reduce_k, 2 = set_twiddle_k,
--         3 = ntt_k (Cooley-Tukey), 4 = intt_k (Gentleman-Sande).
--
-- Operands are signed rs1_i(15 downto 0) and rs2_i(15 downto 0).
-- Scalar results are sign-extended to 32 bits. Butterfly results contain
-- the first output in bits 15:0 and the second output in bits 31:16.
-- SET_TWIDDLE loads LUT index rs1_i(6 downto 0) and returns zero.
-- Only twiddle_q is clocked; the arithmetic and valid_o are combinational.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pq_alu is
  port (
    clk_i    : in  std_ulogic;
    rstn_i   : in  std_ulogic;
    start_i  : in  std_ulogic;
    inst_i   : in  std_ulogic_vector(31 downto 0);
    rs1_i    : in  std_ulogic_vector(31 downto 0);
    rs2_i    : in  std_ulogic_vector(31 downto 0);
    result_o : out std_ulogic_vector(31 downto 0);
    valid_o  : out std_ulogic
  );
end entity pq_alu;

architecture rtl of pq_alu is
  
  constant OPCODE_CUSTOM0 : std_ulogic_vector(6 downto 0) := "0001011";
  constant FUNCT3_KYBER   : std_ulogic_vector(2 downto 0) := "000";
  constant FUNCT7_FQMUL       : std_ulogic_vector(6 downto 0) := "0000000";
  constant FUNCT7_REDUCE      : std_ulogic_vector(6 downto 0) := "0000001";
  constant FUNCT7_SET_TWIDDLE : std_ulogic_vector(6 downto 0) := "0000010";
  constant FUNCT7_NTT         : std_ulogic_vector(6 downto 0) := "0000011";
  constant FUNCT7_INTT        : std_ulogic_vector(6 downto 0) := "0000100";

  signal funct7         : std_ulogic_vector(6 downto 0);
  signal is_kyber_inst  : std_ulogic;
  signal op_fqmul       : std_ulogic;
  signal op_reduce      : std_ulogic;
  signal op_set_twiddle : std_ulogic;
  signal op_ntt         : std_ulogic;
  signal op_intt        : std_ulogic;
  signal op_supported  : std_ulogic;
  signal operand_a : signed(15 downto 0);
  signal operand_b : signed(15 downto 0);
  signal twiddle_q : signed(15 downto 0);

  type zeta_lut_t is array (0 to 127) of signed(15 downto 0);
  signal zeta_lut : zeta_lut_t := (
      0 => to_signed(2285, 16),   1 => to_signed(2571, 16),
      2 => to_signed(2970, 16),   3 => to_signed(1812, 16),
      4 => to_signed(1493, 16),   5 => to_signed(1422, 16),
      6 => to_signed(287, 16),    7 => to_signed(202, 16),
      8 => to_signed(3158, 16),   9 => to_signed(622, 16),
     10 => to_signed(1577, 16),  11 => to_signed(182, 16),
     12 => to_signed(962, 16),   13 => to_signed(2127, 16),
     14 => to_signed(1855, 16),  15 => to_signed(1468, 16),
     16 => to_signed(573, 16),   17 => to_signed(2004, 16),
     18 => to_signed(264, 16),   19 => to_signed(383, 16),
     20 => to_signed(2500, 16),  21 => to_signed(1458, 16),
     22 => to_signed(1727, 16),  23 => to_signed(3199, 16),
     24 => to_signed(2648, 16),  25 => to_signed(1017, 16),
     26 => to_signed(732, 16),   27 => to_signed(608, 16),
     28 => to_signed(1787, 16),  29 => to_signed(411, 16),
     30 => to_signed(3124, 16),  31 => to_signed(1758, 16),
     32 => to_signed(1223, 16),  33 => to_signed(652, 16),
     34 => to_signed(2777, 16),  35 => to_signed(1015, 16),
     36 => to_signed(2036, 16),  37 => to_signed(1491, 16),
     38 => to_signed(3047, 16),  39 => to_signed(1785, 16),
     40 => to_signed(516, 16),   41 => to_signed(3321, 16),
     42 => to_signed(3009, 16),  43 => to_signed(2663, 16),
     44 => to_signed(1711, 16),  45 => to_signed(2167, 16),
     46 => to_signed(126, 16),   47 => to_signed(1469, 16),
     48 => to_signed(2476, 16),  49 => to_signed(3239, 16),
     50 => to_signed(3058, 16),  51 => to_signed(830, 16),
     52 => to_signed(107, 16),   53 => to_signed(1908, 16),
     54 => to_signed(3082, 16),  55 => to_signed(2378, 16),
     56 => to_signed(2931, 16),  57 => to_signed(961, 16),
     58 => to_signed(1821, 16),  59 => to_signed(2604, 16),
     60 => to_signed(448, 16),   61 => to_signed(2264, 16),
     62 => to_signed(677, 16),   63 => to_signed(2054, 16),
     64 => to_signed(2226, 16),  65 => to_signed(430, 16),
     66 => to_signed(555, 16),   67 => to_signed(843, 16),
     68 => to_signed(2078, 16),  69 => to_signed(871, 16),
     70 => to_signed(1550, 16),  71 => to_signed(105, 16),
     72 => to_signed(422, 16),   73 => to_signed(587, 16),
     74 => to_signed(177, 16),   75 => to_signed(3094, 16),
     76 => to_signed(3038, 16),  77 => to_signed(2869, 16),
     78 => to_signed(1574, 16),  79 => to_signed(1653, 16),
     80 => to_signed(3083, 16),  81 => to_signed(778, 16),
     82 => to_signed(1159, 16),  83 => to_signed(3182, 16),
     84 => to_signed(2552, 16),  85 => to_signed(1483, 16),
     86 => to_signed(2727, 16),  87 => to_signed(1119, 16),
     88 => to_signed(1739, 16),  89 => to_signed(644, 16),
     90 => to_signed(2457, 16),  91 => to_signed(349, 16),
     92 => to_signed(418, 16),   93 => to_signed(329, 16),
     94 => to_signed(3173, 16),  95 => to_signed(3254, 16),
     96 => to_signed(817, 16),   97 => to_signed(1097, 16),
     98 => to_signed(603, 16),   99 => to_signed(610, 16),
    100 => to_signed(1322, 16), 101 => to_signed(2044, 16),
    102 => to_signed(1864, 16), 103 => to_signed(384, 16),
    104 => to_signed(2114, 16), 105 => to_signed(3193, 16),
    106 => to_signed(1218, 16), 107 => to_signed(1994, 16),
    108 => to_signed(2455, 16), 109 => to_signed(220, 16),
    110 => to_signed(2142, 16), 111 => to_signed(1670, 16),
    112 => to_signed(2144, 16), 113 => to_signed(1799, 16),
    114 => to_signed(2051, 16), 115 => to_signed(794, 16),
    116 => to_signed(1819, 16), 117 => to_signed(2475, 16),
    118 => to_signed(2459, 16), 119 => to_signed(478, 16),
    120 => to_signed(3221, 16), 121 => to_signed(3021, 16),
    122 => to_signed(996, 16),  123 => to_signed(991, 16),
    124 => to_signed(958, 16),  125 => to_signed(1869, 16),
    126 => to_signed(1522, 16), 127 => to_signed(1628, 16)
  );

  signal intt_diff        : signed(15 downto 0);
  signal ntt_diff         : signed(15 downto 0);
  signal fq_a             : signed(15 downto 0);
  signal fq_b             : signed(15 downto 0);
  signal fq_result        : signed(15 downto 0);

  signal intermediate_sum : signed(15 downto 0);
  signal barrett_input    : signed(15 downto 0);
  signal barrett_result   : signed(15 downto 0);

  signal rd_low  : signed(15 downto 0);
  signal rd_high : signed(15 downto 0);

begin

  funct7 <= inst_i(31 downto 25);
  is_kyber_inst <= '1' when (inst_i(6 downto 0) = OPCODE_CUSTOM0) and
                            (inst_i(14 downto 12) = FUNCT3_KYBER) else '0';
  op_fqmul       <= is_kyber_inst when funct7 = FUNCT7_FQMUL       else '0';
  op_reduce      <= is_kyber_inst when funct7 = FUNCT7_REDUCE      else '0';
  op_set_twiddle <= is_kyber_inst when funct7 = FUNCT7_SET_TWIDDLE else '0';
  op_ntt         <= is_kyber_inst when funct7 = FUNCT7_NTT         else '0';
  op_intt        <= is_kyber_inst when funct7 = FUNCT7_INTT        else '0';
  op_supported   <= op_fqmul or op_reduce or op_set_twiddle or op_ntt or op_intt;

  valid_o        <= start_i and op_supported;

  operand_a <= signed(rs1_i(15 downto 0));
  operand_b <= signed(rs2_i(15 downto 0));

  twiddle_register : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rstn_i = '0' then
        twiddle_q <= (others => '0');
      elsif (start_i = '1') and (op_set_twiddle = '1') then
        twiddle_q <= zeta_lut(to_integer(unsigned(rs1_i(6 downto 0))));
      end if;
    end if;
  end process;

  -- FQMUL multiplies a*b, NTT multiplies b*twiddle, and INTT multiplies
  -- (b-a)*twiddle. All additions/subtractions retain 16-bit wraparound.
  intt_diff <= operand_b - operand_a;

  fqmul_input_mux : process(op_fqmul, op_intt, op_ntt, operand_a, operand_b,
                            intt_diff, twiddle_q)
  begin
    fq_a <= (others => '0');
    fq_b <= (others => '0');

    if op_fqmul = '1' then
      fq_a <= operand_a;
      fq_b <= operand_b;
    elsif op_intt = '1' then
      fq_a <= twiddle_q;
      fq_b <= intt_diff;
    elsif op_ntt = '1' then
      fq_a <= twiddle_q;
      fq_b <= operand_b;
    end if;
  end process;

  fqmul_inst : entity work.fq_mul(rtl)
    port map (
      a         => fq_a,
      b         => fq_b,
      fq_result => fq_result
    );

  ntt_diff <= operand_a - fq_result;

  fq_mul_output_mux : process(op_ntt, op_intt, operand_a, operand_b, fq_result)
  begin
    if op_ntt = '1' then
      intermediate_sum <= operand_a + fq_result;
    elsif op_intt = '1' then
      intermediate_sum <= operand_a + operand_b;
    else
      intermediate_sum <= (others => '0');
    end if;
  end process;

  barrett_mux : process(op_reduce, op_intt, operand_a, intermediate_sum)
  begin
    if op_reduce = '1' then
      barrett_input <= operand_a;
    elsif op_intt = '1' then
      barrett_input <= intermediate_sum;
    else
      barrett_input <= (others => '0');
    end if;
  end process;

  barrett_inst : entity work.barret_reduce(rtl)
    port map (
      a             => barrett_input,
      barret_result => barrett_result
    );

  rd_high_mux : process(op_fqmul, op_reduce, op_ntt, op_intt,
                        fq_result, barrett_result, ntt_diff)
  begin
    rd_high <= (others => '0');

    if op_fqmul = '1' then
      rd_high <= (others => fq_result(15));
    elsif op_reduce = '1' then
      rd_high <= (others => barrett_result(15));
    elsif op_ntt = '1' then
      rd_high <= ntt_diff;
    elsif op_intt = '1' then
      rd_high <= fq_result;
    end if;
  end process;

  rd_low_mux : process(op_fqmul, op_reduce, op_ntt, op_intt,
                       fq_result, barrett_result, intermediate_sum)
  begin
    rd_low <= (others => '0');

    if op_fqmul = '1' then
      rd_low <= fq_result;
    elsif (op_reduce = '1') or (op_intt = '1') then
      rd_low <= barrett_result;
    elsif op_ntt = '1' then
      rd_low <= intermediate_sum;
    end if;
  end process;

  result_o <= std_ulogic_vector(rd_high) & std_ulogic_vector(rd_low);
end architecture rtl;
