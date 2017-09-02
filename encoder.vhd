library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use WORK.constants.all; -- libreria WORK user-defined

entity encoder is

	Port (	A:	In	std_logic_vector(2 downto 0);

		Y:	Out	std_logic_vector(2 downto 0));
end encoder;



architecture BEHAVIORAL of encoder is
begin
 enc: process(A)
   begin
    case A is
	when "000" 	=> Y <= "000" ; --0
	when "001"	=> Y <= "001";  --A
	when "010" 	=> Y <= "001";  --A
	when "011" 	=> Y <= "011";  -- 2A
	when "100" 	=> Y <= "100";  -- -2A
	when "101"	=> Y <= "010";  -- -A
	when "110"	=> Y <= "010";  -- -A
	when "111"	=> Y <= "000";  --0
        when others =>  Y <= (others => '0');
      end case;
    end process enc;

end BEHAVIORAL;



