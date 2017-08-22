library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use IEEE.math_real.all;

entity RCA_s is 
	generic (
		 n_bit :	integer := 32);
		 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(n_bit-1 downto 0);
		Co:	Out	std_logic);
end RCA_s; 

architecture STRUCTURAL of RCA_s is

  signal STMP,B1 : std_logic_vector(n_bit-1 downto 0);
  signal CTMP : std_logic_vector(n_bit downto 0);
  component FA 
  Port ( A:	In	std_logic;
	 B:	In	std_logic;
	 Ci:	In	std_logic;
	 S:	Out	std_logic;
	 Co:	Out	std_logic);
  end component; 

begin

  B1 <= not(B) + '1';
  CTMP(0) <= Ci;
  S <= STMP;
  Co <= CTMP(n_bit);
  
  ADDER1: for I in 1 to n_bit generate
    FAI : FA 
	  Port Map (A(I-1), B1(I-1), CTMP(I-1), STMP(I-1), CTMP(I)); 
  end generate;

end STRUCTURAL;


