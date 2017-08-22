library ieee; 
use ieee.std_logic_1164.all; 

entity AND2 is
	Port (	A:	In	std_logic;
			B:	In	std_logic;
		S:	Out	std_logic);
end AND2; 

architecture BEHAVIORAL of AND2 is

begin

  S <= A AND B;

  
end BEHAVIORAL;