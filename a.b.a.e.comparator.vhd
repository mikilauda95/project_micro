library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;

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

component RCA
	generic (
		 n_bit :	integer := 32);
		 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(n_bit-1 downto 0);
		Co:	Out	std_logic);
end component; 

--component INV 
	--Port (	A:	In	std_logic;
		--S:	Out	std_logic);
--end component; 

--component AND2 
	--Port (	A:	In	std_logic;
			--B:	In	std_logic;
		--S:	Out	std_logic);
--end component; 

--component OR2 
	--Port (	A:	In	std_logic;
			--B:	In	std_logic;
		--S:	Out	std_logic);
--end component; 

--component NORGEN 
	--generic (
		 --n_bit :	integer := 32); 
	--Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		--S:	Out	std_logic);
--end component; 

signal s, B_sig: std_logic_vector(n_bit-1 downto 0);
signal output_nor: std_logic;
signal cout,Ci_sig: std_logic;
signal int1, int2, int3, int4, int5: std_logic;

begin
B_sig <= not(B);
Ci_sig <= '1';

sum: RCA
generic map(n_bit => 32)
port map (A, B_sig, Ci_sig, s, cout);

--nor1: NORGEN
--generic map(n_bit => 32)
--port map (s, output_nor);

output_nor <= nor_reduce(s);

Aabove_equalB <= cout;

--inv1: INV
--port map (cout, int5);

int5 <= not(cout);

AbelowB <= int5;

int4 <= output_nor;
AequalB <= int4;

--inv2: INV
--port map(output_nor, Anot_equalB);

Anot_equalB <= not(output_nor);

--inv3: INV
--port map(int4, int1);

int1 <= not(int4);

--and1: AND2
--port map(int1, cout, AaboveB);

AaboveB <= int1 and cout;

--or1: OR2
--port map(int5, output_nor, Abelow_equalB);

Abelow_equalB <= int5 or output_nor;

end structural;

 





	
