--TO BE TESTED
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

entity register_gen_en IS
    generic(n_bit : integer := 32);
    PORT(
            DIN : IN STD_LOGIC_VECTOR(n_bit-1 DOWNTO 0); -- input.
            ENABLE : IN STD_LOGIC; -- load/enable.
            RESET : IN STD_LOGIC; -- async. clear.
            CLK : IN STD_LOGIC; -- clock.
            DOUT : OUT STD_LOGIC_vector(n_bit-1 DOWNTO 0)
        )
    ; -- output.
end register_gen_en;

architecture behav of register_gen_en is
begin 

    process(CLK,RESET)
    begin -- process
          -- activities triggered by asynchronous reset (active high)
        if RESET = '1' then
            DOUT <= (others =>'0');

 -- activities triggered by rising edge of clock
        elsif CLK'event and CLK = '1' then
            if ENABLE='1' then
                DOUT <= DIN;
            else
                null;
            end if;

        end if;
    end process;
end behav;
