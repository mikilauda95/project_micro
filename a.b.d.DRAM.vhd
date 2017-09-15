library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.math_real.all;
use IEEE.math_complex.all;
entity DRAM is
    generic (
                DRAM_DEPTH : integer := 4*32;
                DATA_SIZE : integer := 8;
                WORD_SIZE : integer := 32;
                ADDR_SIZE : integer := 32);
    port (
             Rst  : in  std_logic;
             WR_enable  : in  std_logic;
             R_enable  : in  std_logic;
             clock : in std_logic;
             Addr : in  std_logic_vector(ADDR_SIZE - 1 downto 0); 
             Din : in  std_logic_vector(WORD_SIZE - 1 downto 0);
             Dout : out std_logic_vector(WORD_SIZE - 1 downto 0)
         );

end DRAM;

architecture Dram_Beh of DRAM is

    type RAMtype is array (0 to DRAM_DEPTH - 1) of std_logic_vector(DATA_SIZE - 1 downto 0); --memory with word equal to byte

    signal DRAM_mem : RAMtype;

begin  -- SRam_Bhe

    DRAM_proc: process (clock)
        file mem_fp: text;
        variable file_line : line;
        variable index : integer := 0;
        variable tmp_data_u : std_logic_vector(WORD_SIZE-1 downto 0);
    begin  -- process FILL_MEM_P
        if (Rst = '1') then
            file_open(mem_fp,"data_memory.mem",READ_MODE);
            while (not endfile(mem_fp)) loop
                readline(mem_fp,file_line);
                hread(file_line,tmp_data_u);
                DRAM_mem(index)     <=tmp_data_u(31 downto 24);
                DRAM_mem(index+1)   <=tmp_data_u(23 downto 16); 
                DRAM_mem(index+2)   <=tmp_data_u(15 downto 8); 
                DRAM_mem(index+3)   <=tmp_data_u(7 downto 0); 
                index := index + 4;
            end loop;
        elsif (Rst = '0') then
            if(rising_edge(clock)) then
                if (WR_enable = '1' ) then --Writing on the memory
                    DRAM_mem(conv_integer(unsigned(Addr))) <= Din(WORD_SIZE -1 downto WORD_SIZE-8) ;
                    DRAM_mem(conv_integer(unsigned(Addr))+1) <= Din(WORD_SIZE -9 downto WORD_SIZE-16) ;
                    DRAM_mem(conv_integer(unsigned(Addr))+2) <= Din(WORD_SIZE -17 downto WORD_SIZE-24) ;
                    DRAM_mem(conv_integer(unsigned(Addr))+3) <= Din(WORD_SIZE -25 downto WORD_SIZE-32) ;
                elsif(R_enable = '1')  then --Reading from memory (WR = 0, R_enable=1)
                    Dout(WORD_SIZE-1 downto WORD_SIZE-8) <= DRAM_mem(conv_integer(unsigned(Addr)));
                    Dout(WORD_SIZE -9 downto WORD_SIZE-16) <= DRAM_mem(conv_integer(unsigned(Addr))+1);
                    Dout(WORD_SIZE -17 downto WORD_SIZE-24) <= DRAM_mem(conv_integer(unsigned(Addr))+2);
                    Dout(WORD_SIZE -25 downto WORD_SIZE-32) <= DRAM_mem(conv_integer(unsigned(Addr))+3);
                end if;
            end if;
        end if;
    end process DRAM_proc;

--FILL_MEM_P: process (Rst)
--begin  -- process FILL_MEM_P
--if (Rst = '1') then
--file_open(mem_fp,"data_memory.mem",READ_MODE);
--while (not endfile(mem_fp)) loop
--readline(mem_fp,file_line);
--hread(file_line,tmp_data_u);
--DRAM_mem(index)     <=tmp_data_u(31 downto 24);
--DRAM_mem(index+1)   <=tmp_data_u(23 downto 16); 
--DRAM_mem(index+2)   <=tmp_data_u(15 downto 8); 
--DRAM_mem(index+3)   <=tmp_data_u(7 downto 0); 
--index := index + 4;
--end loop;
--end if;
--end process FILL_MEM_P;
end Dram_Beh;
