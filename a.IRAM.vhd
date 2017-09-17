library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.math_real.all;
use IEEE.math_complex.all;


-- Instruction memory for DLX
-- Memory filled by a process which reads from a file
-- file name is "test.asm.mem"
entity IRAM is
    generic (
                RAM_DEPTH : integer := 4*256;
                I_SIZE : integer := 32);
    port (
             Rst  : in  std_logic;
             clock  : in  std_logic;
             Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
             Dout : out std_logic_vector(I_SIZE - 1 downto 0)
         );

end IRAM;

architecture IRam_Bhe of IRAM is

    type RAMtype is array (0 to RAM_DEPTH - 1) of integer; -- std_logic_vector(I_SIZE - 1 downto 0);


    signal IRAM_mem : RAMtype;

begin  -- IRam_Bhe
    --process(clock)
    --begin 
        --if (rising_edge(clock)) then
            Dout(31 downto 24) <= conv_std_logic_vector(IRAM_mem(conv_integer(unsigned(Addr))),I_SIZE/4);
            Dout(23 downto 16)  <= conv_std_logic_vector(IRAM_mem(conv_integer(unsigned(Addr)+1)),I_SIZE/4);
            Dout(15 downto 8) <= conv_std_logic_vector(IRAM_mem(conv_integer(unsigned(Addr)+2)),I_SIZE/4);
            Dout(7 downto 0) <= conv_std_logic_vector(IRAM_mem(conv_integer(unsigned(Addr)+3)),I_SIZE/4);
        --end if;
    --end process;

  -- purpose: This process is in charge of filling the Instruction RAM with the firmware
  -- type   : combinational
  -- inputs : Rst
  -- outputs: IRAM_mem
    FILL_MEM_P: process (Rst)
        file mem_fp: text;
        variable file_line : line;
        variable index : integer := 0;
        variable tmp_data_u : std_logic_vector(I_SIZE-1 downto 0);
    begin  -- process FILL_MEM_P
        if (Rst = '0') then
            file_open(mem_fp,"test.asm.mem",READ_MODE);
            while (not endfile(mem_fp)) loop
                readline(mem_fp,file_line);
                hread(file_line,tmp_data_u);
                IRAM_mem(index) <=conv_integer(unsigned(tmp_data_u(31 downto 24)));
                IRAM_mem(index+1) <=conv_integer(unsigned(tmp_data_u(23 downto 16))); 
                IRAM_mem(index+2) <=conv_integer(unsigned(tmp_data_u(15 downto 8))); 
                IRAM_mem(index+3) <=conv_integer(unsigned(tmp_data_u(7 downto 0))); 
                index := index + 4;
            end loop;
        end if;
    end process FILL_MEM_P;

end IRam_Bhe;
