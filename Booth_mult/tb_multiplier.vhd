library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use WORK.constants.all;

entity MULTIPLIER_tb is
end MULTIPLIER_tb;


architecture TEST of MULTIPLIER_tb is


  constant numBit : integer := 32;    -- :=8  --:=16    

  --  input	 
  signal A_mp_i : std_logic_vector(numBit-1 downto 0) := x"FFFF_FFF6";--starting value = -10
  signal B_mp_i : std_logic_vector(numBit-1 downto 0) := (others => '0');

  -- output
  signal Y_mp_i : std_logic_vector(2*numBit-1 downto 0);


component BOOTHMUL 
	generic (n_bit: integer:= numBit);

	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
                B:      In      std_logic_vector(n_bit-1 downto 0);
		P:	Out	std_logic_vector(n_bit-1+n_bit downto 0));
end component;


begin

  
    Mult: BOOTHMUL
      generic map (numbit) 
	  Port Map (A_mp_i, B_mp_i , Y_mp_i);

-- PROCESS FOR TESTING TEST - COMLETE CYCLE ---------
  test: process
  begin

   --cycle for operand A
  NumROW : for i in 0 to 2**(NumBit/2)-1 loop
--      -- cycle for operand B
 	NumCOL : for i in 0 to 2**(NumBit/2)-1 loop
	    wait for 10 ns;
	    B_mp_i <= B_mp_i + '1';
	end loop NumCOL ;
 --       
	A_mp_i <= A_mp_i + '1'; 	
    end loop NumROW ;

    wait;          
  end process test;
  



end TEST;
