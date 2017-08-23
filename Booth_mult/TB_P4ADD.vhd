library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
entity TBP4ADD is 
    end TBP4ADD; 

architecture TEST of TBP4ADD is


    component P4ADD 
        generic (n_block:	integer := 4; 
                 n_bit :	integer := 32);

        Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
               B:	In	std_logic_vector(n_bit-1 downto 0);
               Ci:	In	std_logic;
               S:	Out	std_logic_vector(n_bit-1 downto 0);
               Co:	Out	std_logic);
    end component; 

    constant NBIT : integer := 32;
    constant NBLOCK : integer := 4;
    signal Ci, Co1 : std_logic;

  signal A_mp_i : std_logic_vector(NBIT-1 downto 0) := (others => '0');
  signal B_mp_i : std_logic_vector(NBIT-1 downto 0) := (others => '0');

  -- output
  signal Y_mp_i : std_logic_vector(NBIT-1 downto 0);

Begin

  -- Instanciate the ADDER without delay in the carry generation
    UADDER1: P4ADD
    generic map (n_block => NBLOCK, n_bit => NBIT)
    port map (A_mp_i, B_mp_i, Ci, Y_mp_i, Co1); 
-- PROCESS FOR TESTING TEST - COMLETE CYCLE ---------
  test: process
  begin

Ci <= '0';
A_mp_i <= x"FFFF_FFFF";
B_mp_i <= x"0000_0001";
wait for 30 ns;

Ci <= '1';
A_mp_i <= x"FFFF_FFFF";
B_mp_i <= x"0000_0001";
wait for 30 ns;
--   --cycle for operand A
--  NumROW : for i in 0 to 2**(NBIT/4)-1 loop
--      -- cycle for operand B
-- 	NumCOL : for i in 0 to 2**(NBIT/4)-1 loop
--	    wait for 10 ns;
--	    B_mp_i <= B_mp_i + "011"; --B = B+3
--	end loop NumCOL ;
--       
--	A_mp_i <= A_mp_i + "101"; --A = A+3	
--    end loop NumROW ;
--
--    wait;          
  end process test;
    
end TEST;

