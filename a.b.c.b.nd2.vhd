library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use WORK.constants.all; -- libreria WORK user-defined

entity ND2 is
	
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		Y:	Out	std_logic);
end ND2;

architecture ARCH2 of ND2 is

begin

	P1: process(A,B) -- tutti gli ingressi utilizzati devono essere nella sensitivity list
	begin
	  if (A='1') and (B='1') then
	    Y <='0';
	  elsif (A='0') or (B='0') then 
	    Y <='1';
	  end if;
	end process;

end ARCH2;


