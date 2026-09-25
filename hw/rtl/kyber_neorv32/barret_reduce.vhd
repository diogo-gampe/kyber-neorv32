


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Todas operações por enquanto são combinacionais
entity barret_reduce is
  port (
  
    a    : in  std_ulogic_vector(15 downto 0);
    b    : in  std_ulogic_vector(15 downto 0);
    barret_result : out std_ulogic_vector(15 downto 0);

  );
end entity barret_reduce;

architecture rtl of barret_reduce is

    constant KYBER_Q    : signed(15 downto 0)   := to_signed(3329, 16); 
    constant BARRETT_V  : signed(15 downto 0)   := to_signed(20159, 16);

    signal fq_product      : signed(31 downto 0);
    signal qinv_product    : unsigned(31 downto 0);
    signal mont_u          : signed(15 downto 0);
    signal mont_uq         : signed(31 downto 0);
    signal mont_difference : signed(31 downto 0);
    signal mont_shifted    : signed(31 downto 0);
    signal fq_result       : signed(15 downto 0);
begin

    fq_product      <= fq_a * fq_b;
    qinv_product    <= unsigned(fq_product(15 downto 0)) * KYBER_QINV;
    mont_u          <= signed(qinv_product(15 downto 0));
    mont_uq         <= mont_u * KYBER_Q;
    mont_difference <= fq_product - mont_uq;
    mont_shifted    <= mont_differenc >> 16; 
    
    fq_result       <= mont_shifted(15 downto 0);

end architecture rtl; 