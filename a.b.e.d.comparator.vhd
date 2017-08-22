library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity comparator is
generic(
	n_bit: integer := 32);
port(
	A: in std_logic_vector(n_bit-1 downto 0);
	B: in std_logic_vector(n_bit-1 downto 0);
	AaboveB: out std_logic;
	Aabove_equalB: out std_logic;
	AequalB: out std_logic;
	Anot_equalB: out std_logic;
	AbelowB: out std_logic;
	Abelow_equalB: out std_logic);
	
end comparator;

architecture structural of comparator is

component RCA_s
	generic (
		 n_bit :	integer := 32);
		 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(n_bit-1 downto 0);
		Co:	Out	std_logic);
end component; 

component INV 
	Port (	A:	In	std_logic;
		S:	Out	std_logic);
end component; 

component AND2 
	Port (	A:	In	std_logic;
			B:	In	std_logic;
		S:	Out	std_logic);
end component; 

component OR2 
	Port (	A:	In	std_logic;
			B:	In	std_logic;
		S:	Out	std_logic);
end component; 

component NORGEN 
	generic (
		 n_bit :	integer := 32); 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		S:	Out	std_logic);
end component; 

signal s: std_logic_vector(n_bit-1 downto 0);
signal output_nor: std_logic;
signal cout,Ci_sig: std_logic;
signal int1, int2, int3, int4, int5: std_logic;

begin
Ci_sig <= '0';
sum: RCA_s
generic map(n_bit => 32)
port map (A, B, Ci_sig, s, cout);

nor1: NORGEN
generic map(n_bit => 32)
port map (s, output_nor);

Aabove_equalB <= cout;

inv1: INV
port map (cout, int5);

AbelowB <= int5;

int4 <= output_nor;
AequalB <= int4;

inv2: INV
port map(output_nor, Anot_equalB);

inv3: INV
port map(int4, int1);

and1: AND2
port map(int1, cout, AaboveB);

or1: OR2
port map(int5, output_nor, Abelow_equalB);

end structural;

 





	
