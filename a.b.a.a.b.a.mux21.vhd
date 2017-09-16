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

architecture BEHAVIORAL_2 of MUX21_GENERIC is

begin
	Y <= A when S='1' else B;

end BEHAVIORAL_2;

