library ieee; 
use ieee.std_logic_1164.all; 

entity NOR5 is
	generic (
		 n_bit :	integer := 5); 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		S:	Out	std_logic);
end NOR5; 

architecture BEHAVIORAL of NOR5 is
signal int: std_logic;
begin

  int <= A(0) or A(1) or A(2) or A(3) or A(4) ;
  S <= not(int);
  

  
end BEHAVIORAL;
