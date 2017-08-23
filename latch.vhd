library IEEE;
use IEEE.std_logic_1164.all; 
use WORK.constants.all;

entity latch is
    generic(n_bit: integer:=32);
    Port (	D:	In	std_logic_vector(n_bit-1 downto 0);
           EN:	In	std_logic;
           RESET:	In	std_logic;
           Q:	Out	std_logic_vector(n_bit-1 downto 0));
end latch;


architecture behaviour of latch is 


begin

    process(RESET,EN,D)
    begin
        if reset = '1' then
            Q <= (others => '0');
        else
            if EN = '1' then
                Q <= D;
            end if;
        end if;
    end process;
end behaviour;





