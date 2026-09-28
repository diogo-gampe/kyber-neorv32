


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Todas operações por enquanto são combinacionais
entity barret_reduce is
  port (
    a             : in  signed(15 downto 0);
    barret_result : out signed(15 downto 0)
  );
end entity barret_reduce;

architecture rtl of barret_reduce is
  constant KYBER_Q   : signed(15 downto 0) := to_signed(3329, 16);
  constant BARRETT_V : signed(15 downto 0) := to_signed(20159, 16);

  signal barrett_product       : signed(31 downto 0);
  signal barrett_shifted       : signed(31 downto 0);
  signal barrett_quotient      : signed(15 downto 0);
  signal barrett_multiple_wide : signed(31 downto 0);
  signal barrett_multiple      : signed(15 downto 0);
  signal result               : signed(15 downto 0);
  
begin

  barrett_product       <= BARRETT_V * signed(a);
  barrett_shifted       <= shift_right(barrett_product, 26);
  barrett_quotient      <= barrett_shifted(15 downto 0);
  barrett_multiple_wide <= barrett_quotient * KYBER_Q;
  barrett_multiple      <= barrett_multiple_wide(15 downto 0);
  result                <= signed(a) - barrett_multiple;
  barret_result         <= signed(result);
  
end architecture rtl;
