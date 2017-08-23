library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity NAND4 is
	generic(
		n_bit: integer :=32);
	port(

		input1: in std_logic_vector(n_bit-1 downto 0);
		input2: in std_logic_vector(n_bit-1 downto 0);
		input3: in std_logic_vector(n_bit-1 downto 0);
		input4: in std_logic_vector(n_bit-1 downto 0);
		output1: out std_logic_vector(n_bit-1 downto 0));
		
end NAND4;

architecture behavioral of NAND4 is 
signal int1: std_logic_vector(n_bit-1 downto 0);
begin
int1<= input1 AND input2 AND input3 AND input4;
output1 <= not(int1);

end behavioral;
		
