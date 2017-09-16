library ieee;
use ieee.std_logic_1164.all;

entity PG is
    port (
        a: in std_logic;
        b: in std_logic;
    	p: out std_logic;
    	g: out std_logic
    	
    );
end PG;

architecture behavior of PG is
begin
    p <= a xor b;
    g <= a and b;

end behavior;
