library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use WORK.constants.all; -- libreria WORK user-defined

entity MUX21_GENERIC is
	generic (n_bit: integer:= numBit
                 );
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(n_bit-1 downto 0));
end MUX21_GENERIC;


--architecture BEHAVIORAL_1 of MUX21_GENERIC is
--
--begin
--   process
--       begin
--           
--   G: for i in 0 to n_bit-1 loop
--	Y(i) <= (A(i) and S) or (B(i) and not(S)); -- processo implicito
--	end loop;
--	end process;
--
--end BEHAVIORAL_1;


architecture BEHAVIORAL_2 of MUX21_GENERIC is

begin
	Y <= A when S='1' else B;

end BEHAVIORAL_2;


--architecture BEHAVIORAL_3 of MUX21_GENERIC is
--
--begin
--	pmux: process(A,B,S)
--	begin
--		if S='1' then
 --			Y <= A;
--		else
--			Y <= B;
--		end if;
--
--	end process;
--
--end BEHAVIORAL_3;
--
--
--
--architecture STRUCTURAL of MUX21_GENERIC is
--        
--        
--	signal Y1: std_logic_vector(n_bit-1 downto 0);
--	signal Y2: std_logic_vector(n_bit-1 downto 0);
--	signal SB: std_logic;
--
--	component ND2
--	
--	
--	Port (	A:	In	std_logic;
--		B:	In	std_logic;
--		Y:	Out	std_logic);
--	end component;
--	
--	component IV
--	
--	Port (	A:	In	std_logic;
--		Y:	Out	std_logic);
--	end component;
--
--begin
--	
--	UIV : IV
--        Port Map ( S, SB);
--	
--	G1: for i in 0 to n_bit-1 generate
--	UND1 : ND2       
--	Port Map ( A(i), S, Y1(i));
--   end generate;
--	G2: for i in 0 to n_bit-1 generate
--	UND2 : ND2
--	Port Map ( B(i), SB, Y2(i));
--   end generate;
--	G3: for i in 0 to n_bit-1 generate
--	UND3 : ND2
--	Port Map ( Y1(i), Y2(i), Y(i));
--   end generate;
--
--end STRUCTURAL;
--
--
--configuration CFG_MUX21_GEN_BEHAVIORAL of MUX21_GENERIC is
--	for BEHAVIORAL_1
--	end for;
--end CFG_MUX21_GEN_BEHAVIORAL;
--
--configuration CFG_MUX21_GEN_BEHAVIORAL_2 of MUX21_GENERIC is
--	for BEHAVIORAL_2
--	end for;
--end CFG_MUX21_GEN_BEHAVIORAL_2;
--
--configuration CFG_MUX21_GEN_BEHAVIORAL_3 of MUX21_GENERIC is
--	for BEHAVIORAL_3
--	end for;
--end CFG_MUX21_GEN_BEHAVIORAL_3;
--
--configuration CFG_MUX21_GEN_STRUCTURAL of MUX21_GENERIC is
--	for STRUCTURAL
--		for all : IV
--			use configuration WORK.CFG_IV_BEHAVIORAL;
--		end for;
--		for all : ND2
--			use configuration WORK.CFG_ND2_ARCH2;
--		end for;
--	end for;
--end CFG_MUX21_GEN_STRUCTURAL;
