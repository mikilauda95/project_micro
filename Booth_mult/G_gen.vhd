library ieee;
use ieee.std_logic_1164.all;

entity G_gen is
	port (
		     p1: in std_logic;
		     g1: in std_logic;
		     g2: in std_logic;
		     g: out std_logic

);
    end G_gen;

architecture behavior of G_gen is
begin
	g <= g1 or (p1 and g2);	--Gi:j = Gi:k + Pi:k · Gk-1:j 

end behavior;
