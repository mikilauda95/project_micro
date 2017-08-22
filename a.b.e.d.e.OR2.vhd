library ieee; 
use ieee.std_logic_1164.all; 

entity OR2 is

	Port (	A:	In	std_logic;
			B:	In	std_logic;
		S:	Out	std_logic);
end OR2; 

architecture BEHAVIORAL of OR2 is

begin

  S <= A or B;

  
end BEHAVIORAL;