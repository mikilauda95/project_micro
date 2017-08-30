library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.log.all;
use work.constants.all;
use WORK.all;

entity register_file is
    port ( CLK: 		IN std_logic;
           RESET: 	IN std_logic;
           ENABLE: 	IN std_logic;
           RD1: 		IN std_logic;
           RD2: 		IN std_logic;
           WR: 		IN std_logic;
           ADD_WR: 	IN std_logic_vector(logn-1 downto 0);
           ADD_RD1: 	IN std_logic_vector(logn-1 downto 0);
           ADD_RD2: 	IN std_logic_vector(logn-1 downto 0);
           DATAIN: 	IN std_logic_vector(n_bit-1 downto 0);
           OUT1: 		OUT std_logic_vector(n_bit-1 downto 0);
           OUT2: 		OUT std_logic_vector(n_bit-1 downto 0));
end register_file;

architecture behavioral_basic of register_file is


    -- suggested structures
    --    subtype REG_ADDR is natural range 0 to n-1; -- using natural type
    --    type REG_ARRAY is array (REG_ADDR) of std_logic_vector(n_bit-1 downto 0); 
    type REG_ARRAY is array (n-1 downto 0) of std_logic_vector(n_bit-1 downto 0); 
    signal REGISTERS : REG_ARRAY; 


begin 
    -- write your RF code 
    process(CLK)
    begin

        if rising_edge(clk) then
            if reset = '1' then
                OUT1 <= (others => '0'); 
                OUT2 <= (others => '0'); 
                REGISTERS <= (others => (others =>'0')); 
            elsif ENABLE = '1' then 
                if RD1 = '1' then
                    OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1)));
                end if;

                if RD2 = '1' then
                    OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2)));
                end if;

                if WR = '1' then

                    REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN;
                end if;

            end if;
        end if;
    end process;

--    REGISTERS(1) <= "00000101101011111010101010100101";
--    REGISTERS(2) <= "10100101101011111010101010100101";
--    REGISTERS(3) <= "10100101101011111010101010100101";
--    REGISTERS(4) <= "10100101101011111010101010100101";
--    REGISTERS(5) <= "10100101101011111010101010100101";
--    REGISTERS(6) <= "10100101101011111010101010100101";
--    REGISTERS(7) <= "10100101101011111010101010100101";
--    REGISTERS(8) <= "10100101101011111010101010100101";
--    REGISTERS(9) <= "10100101101011111010101010100101";
--    REGISTERS(10) <= "10100101101011111010101010100101";
--    REGISTERS(11) <= "10100101101011111010101010100101";
--    REGISTERS(12) <= "10100101101011111010101010100101";
--    REGISTERS(13) <= "10100101101011111010101010100101";
--    REGISTERS(14) <= "10100101101011111010101010100101";
--    REGISTERS(15) <= "10100101101011111010101010100101";


end behavioral_basic;



configuration CFG_RF_BEH of register_file is
    for behavioral_basic
    end for;
end CFG_RF_BEH;
