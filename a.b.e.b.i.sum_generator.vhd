library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.constants.all; -- libreria WORK user-defined

entity sum_generator is 
	generic (n_block : 	integer := 4;
		 n_bit :	integer := 32);
		 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
		Ci:	In	std_logic_vector(n_bit/n_block-1 downto 0);
		S:	Out	std_logic_vector(n_bit-1 downto 0);
		Co:	Out	std_logic);
end sum_generator; 

architecture STRUCTURAL of sum_generator is

 signal c_out: std_logic_vector(n_bit/n_block-1 downto 0);

 component carry_select_block  
	generic (
			n_bit :	integer := numbit); -- numbit is a variable defined in constants.vhd
		 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(n_bit-1 downto 0);
		Co:	Out	std_logic);
 end component;
  

begin

 ADDER2: for i in 1 to n_bit/n_block generate
     ADD: carry_select_block 
	  generic map (n_bit => n_block)
	  Port Map (A(i*n_block-1 downto (i-1)*n_block),B(i*n_block-1 downto (i-1)*n_block),Ci(i-1),S(i*n_block-1 downto (i-1)*n_block),c_out(i-1)); 
  end generate;

co <= c_out(n_bit/n_block-1);

end STRUCTURAL;

