library IEEE;
use IEEE.std_logic_1164.all; 
use WORK.constants.all;

entity register_gen is
	generic(n_bit: integer:=64);
	Port (	D:	In	std_logic_vector(n_bit-1 downto 0);
		CK:	In	std_logic;
		RESET:	In	std_logic;
		Q:	Out	std_logic_vector(n_bit-1 downto 0));
end register_gen;


architecture behaviour of register_gen is 

component FD
	Port (	D:	In	std_logic;
		CK:	In	std_logic;
		RESET:	In	std_logic;
		Q:	Out	std_logic);
end component;

begin
	G1: for i in 0 to n_bit-1 generate
		ffd: FD port map(D(i),CK,RESET,Q(i));
			
	end generate;
	

end behaviour;


--configuration SYNCHRONOUS of register_gen is
	--for behaviour
		--for all : FD
			--use configuration WORK.CFG_FD_PIPPO;
		--end for;
	--end for;
--end SYNCHRONOUS;




