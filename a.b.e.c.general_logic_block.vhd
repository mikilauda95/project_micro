library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity general_logic_block is
	generic(
		n_bit: integer :=32);
	port(
		control_signal: in std_logic_vector(3 downto 0);
		r1: in std_logic_vector(n_bit-1 downto 0);
		r2: in std_logic_vector(n_bit-1 downto 0);
		out1: out std_logic_vector(n_bit-1 downto 0));
end general_logic_block;

architecture structural of general_logic_block is

component NAND3 
	generic(
		n_bit: integer :=32);
	port(
		control: in std_logic;
		input1: in std_logic_vector(n_bit-1 downto 0);
		input2: in std_logic_vector(n_bit-1 downto 0);
		output1: out std_logic_vector(n_bit-1 downto 0));
		
end component;

component NAND4 
	generic(
		n_bit: integer :=32);
	port(

		input1: in std_logic_vector(n_bit-1 downto 0);
		input2: in std_logic_vector(n_bit-1 downto 0);
		input3: in std_logic_vector(n_bit-1 downto 0);
		input4: in std_logic_vector(n_bit-1 downto 0);
		output1: out std_logic_vector(n_bit-1 downto 0));
		
end component;


signal l0, l1, l2, l3: std_logic_vector(n_bit-1 downto 0);

signal notr1, notr2: std_logic_vector(n_bit-1 downto 0);
begin

notr1 <= not(r1);
notr2 <= not(r2);
firstNand: NAND3 
generic map (n_bit => 32)
port map (control_signal(0), notr1, notr2, l0);

secondNand: NAND3 
generic map (n_bit => 32)
port map (control_signal(1), notr1, r2, l1);

thirdNand: NAND3 
generic map (n_bit => 32)
port map (control_signal(2), r1, notr2, l2);

forthNand: NAND3 
generic map (n_bit => 32)
port map (control_signal(3), r1, r2, l3);

finalNand: NAND4
generic map (n_bit => 32)
port map (l0, l1, l2, l3, out1);

end structural;
