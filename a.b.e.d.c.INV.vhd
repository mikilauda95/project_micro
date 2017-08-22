library ieee; 
use ieee.std_logic_1164.all; 

entity INV is
	Port (	A:	In	std_logic;
		S:	Out	std_logic);
end INV; 

architecture BEHAVIORAL of INV is

begin

  S <= NOT(A);

  
end BEHAVIORAL;