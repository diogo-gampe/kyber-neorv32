
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- FQMUL por enquanto é combinacional
entity fq_mul is
  port (
    a         : in  signed(15 downto 0);
    b         : in  signed(15 downto 0);
    fq_result : out signed(15 downto 0)
  );
end entity fq_mul;

architecture rtl of fq_mul is
  constant KYBER_Q    : signed(15 downto 0)   := to_signed(3329, 16);
  constant KYBER_QINV : unsigned(15 downto 0) := to_unsigned(62209, 16);

  signal fq_product      : signed(31 downto 0);
  signal qinv_product    : unsigned(31 downto 0);
  signal mont_u          : signed(15 downto 0);
  signal mont_uq         : signed(31 downto 0);
  signal mont_difference : signed(31 downto 0);
  signal mont_shifted    : signed(31 downto 0);
begin
  fq_product      <= a * b;
  qinv_product    <= unsigned(fq_product(15 downto 0)) * KYBER_QINV;
  mont_u          <= signed(qinv_product(15 downto 0));
  mont_uq         <= mont_u * KYBER_Q;
  mont_difference <= fq_product - mont_uq;
  mont_shifted    <= shift_right(mont_difference, 16);
  fq_result       <= signed(mont_shifted(15 downto 0));
end architecture rtl;
