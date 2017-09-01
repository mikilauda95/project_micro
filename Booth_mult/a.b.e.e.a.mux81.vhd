library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use WORK.constants.all; -- libreria WORK user-defined

entity MUX81_GENERIC is
	generic (n_bit: integer:= numBit);
                 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
                C:	In	std_logic_vector(n_bit-1 downto 0);
		D:	In	std_logic_vector(n_bit-1 downto 0);
		E:	In	std_logic_vector(n_bit-1 downto 0);
                F:	In	std_logic_vector(n_bit-1 downto 0);
	        G:	In	std_logic_vector(n_bit-1 downto 0);
	        H:	In	std_logic_vector(n_bit-1 downto 0);
		S:	In	std_logic_vector(2 downto 0);
		Y:	Out	std_logic_vector(n_bit-1 downto 0));
end MUX81_GENERIC;



architecture BEHAVIORAL of MUX81_GENERIC is
begin
 MUX : process (S,A,B,C,D,E,F,G,H)
   begin

    case S is
	when "000" 	=> Y <= A ; --0
	when "001"	=> Y <= B;  --A
	when "010"	=> Y <= C;  -- -A
	when "011"	=> Y <= D;  -- 2A
	when "100"	=> Y <= E;  -- -2A
	--when "101"	=> Y <= F;
	--when "110"	=> Y <= G;
	--when "111"	=> Y <= H;

	when others =>  Y <= (others => '0');
  end case;
end process MUX;


end BEHAVIORAL;



