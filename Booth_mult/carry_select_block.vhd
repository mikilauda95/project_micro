library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.constants.all; -- libreria WORK user-defined

entity carry_select_block is 
	generic (
		 n_bit :	integer := numbit);
		 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(n_bit-1 downto 0);
		Co:	Out	std_logic);
end carry_select_block; 

architecture STRUCTURAL of carry_select_block is

 signal c_out: std_logic_vector(1 downto 0);
 signal sumc0: std_logic_vector(n_bit-1 downto 0);
 signal sumc1: std_logic_vector(n_bit-1 downto 0);
 signal cin1: std_logic;
 signal cin2: std_logic;

  component RCA  
	generic (--DRCAS : 	Time := 0 ns;
	         --DRCAC : 	Time := 0 ns;
		 n_bit :	integer := numbit);
		 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(n_bit-1 downto 0);
		Co:	Out	std_logic);
end component; 
  
  component MUX21_GENERIC 
	generic (n_bit: integer:= numBit
                 );
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(n_bit-1 downto 0));
end component;

begin


  
  ADDER1: RCA 
	  generic map (n_bit => n_bit) 
	  Port Map (A, B, cin1, sumc0 , c_out(1)); 
  ADDER2: RCA 
	  generic map (n_bit => n_bit) 
	  Port Map (A, B, cin2, sumc1 , c_out(0));
  MUX1: MUX21_GENERIC
      generic map ( n_bit => n_bit)
	  Port map (sumc1, sumc0, ci, S);

cin1 <= '0';
cin2 <= '1';
Co <= '0';     --the total carry out is useless here as we get it from sparsetree
end STRUCTURAL;

