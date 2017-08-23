library ieee;
use ieee.std_logic_1164.all;

entity PG_0 is
	port (
		     a: in std_logic;
		     b: in std_logic;
		     c: in std_logic;
		     g: out std_logic;
		     p: out std_logic

);
end PG_0;

architecture behavior of PG_0 is
begin
	g <= (a and b) or ((a xor b) and c);

end behavior;
