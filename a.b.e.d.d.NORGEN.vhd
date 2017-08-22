library ieee; 
use ieee.std_logic_1164.all; 

entity NORGEN is
	generic (
		 n_bit :	integer := 32); 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		S:	Out	std_logic);
end NORGEN; 

architecture BEHAVIORAL of NORGEN is
signal int: std_logic;
begin

  int <= A(0) or A(1) or A(2) or A(3) or A(4) or A(5) or A(6) or A(7) or A(8) or A(9) or A(10) or A(11) or A(12) or A(13) or A(14) or A(15) or
A(16) or A(17) or A(18) or A(19) or A(20) or A(21) or A(22) or A(23) or A(24) or A(25) or A(26) or A(27) or A(28) or A(29) or A(30) or A(31);
  S <= not(int);
  

  
end BEHAVIORAL;