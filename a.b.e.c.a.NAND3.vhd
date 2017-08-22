library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity NAND3 is
	generic(
		n_bit: integer := 32);
	port(
		control: in std_logic;
		input1: in std_logic_vector(n_bit-1 downto 0);
		input2: in std_logic_vector(n_bit-1 downto 0);
		output1: out std_logic_vector(n_bit-1 downto 0));
		
end NAND3;

architecture behavioral of NAND3 is
signal int: std_logic_vector(n_bit-1 downto 0);
begin

nandloop: for i in 0 to n_bit-1 generate

int(i) <= input1(i) AND input2(i) AND control;
output1(i) <= not(int(i));
end generate nandloop;

end behavioral;
		
	
