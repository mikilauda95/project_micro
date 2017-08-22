library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use WORK.constants.all; -- libreria WORK user-defined

entity MUX21_GENERIC is
	generic (n_bit: integer:= 64);
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(n_bit-1 downto 0));
end MUX21_GENERIC;


architecture STRUCTURAL of MUX21_GENERIC is
        
        
	signal Y1: std_logic_vector(n_bit-1 downto 0);
	signal Y2: std_logic_vector(n_bit-1 downto 0);
	signal SB: std_logic;

	component ND2
	
	
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		Y:	Out	std_logic);
	end component;
	
	component IV
	
	Port (	A:	In	std_logic;
		Y:	Out	std_logic);
	end component;

begin
	
	UIV : IV
        Port Map ( S, SB);
	
	G1: for i in 0 to n_bit-1 generate
	UND1 : ND2       
	Port Map ( A(i), S, Y1(i));
   end generate;
	G2: for i in 0 to n_bit-1 generate
	UND2 : ND2
	Port Map ( B(i), SB, Y2(i));
   end generate;
	G3: for i in 0 to n_bit-1 generate
	UND3 : ND2
	Port Map ( Y1(i), Y2(i), Y(i));
   end generate;

end STRUCTURAL;

