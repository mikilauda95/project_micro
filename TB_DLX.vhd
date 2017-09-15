library IEEE;

use IEEE.std_logic_1164.all;
use work.myTypes.all;
use work.constants.all;
use WORK.all;

entity tb_dlx is
end tb_dlx;

architecture TEST of tb_dlx is


    constant SIZE_IR      : integer := 32;       -- Instruction Register Size
    constant SIZE_PC      : integer := 32;       -- Program Counter Size
    constant SIZE_ALU_OPC : integer := 6;        -- ALU Op Code Word Size in case explicit coding is used

    signal Clock, not_clock : std_logic := '0';
    signal Reset: std_logic := '1';

signal s_DRAM_RE_byp : std_logic;
signal s_DRAM_WE_byp : std_logic;
signal s_DRAM_ADD_byp : std_logic_vector(n_bit-1 downto 0);
signal s_DRAM_DIN_byp : std_logic_vector(n_bit-1 downto 0);
signal s_DRAM_Dout_byp : std_logic_vector(n_bit-1 downto 0);

signal s_IRAMout : std_logic_vector(n_bit-1 downto 0);
signal s_PC_out : std_logic_vector(n_bit-1 downto 0);



    
component DLX is
port(clock : in std_logic;
reset : in std_logic;
DRAM_RE_byp            : out std_logic;  -- Data RAM read enable
DRAM_WE_byp            : out std_logic;  -- Data RAM Write Enable
DRAM_ADD_byp             : out std_logic_vector(n_bit-1 downto 0);
DRAM_DIN_byp             : out std_logic_vector(n_bit-1 downto 0);

DRAM_Dout_byp             : in std_logic_vector(n_bit-1 downto 0);


IRAMout : in std_logic_vector(IR_SIZE-1 downto 0);
PC_out  : out std_logic_vector(IR_SIZE-1 downto 0)
);
end component;

component IRAM is
    generic (
                RAM_DEPTH : integer := 4*256;
                I_SIZE : integer := 32);
    port (
             Rst  : in  std_logic;
             clock  : in  std_logic;
             Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
             Dout : out std_logic_vector(I_SIZE - 1 downto 0)
         );

end component;


component DRAM is
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

end component;



begin





        -- instance of DLX
--	U1: DLX
--        Generic Map (SIZE_IR, SIZE_PC) -- SIZE_ALU_OPC)   
--	Port Map (Clock, Reset);
	
--DLX_0 : DLX
--port map (
        --clock  => clock,
--reset  => reset );


DLX_0 : DLX
port map (
        clock  => clock,
reset  => reset,
DRAM_RE_byp             =>          s_DRAM_RE_byp,
DRAM_WE_byp             =>          s_DRAM_WE_byp,
DRAM_ADD_byp              =>        s_DRAM_ADD_byp,
DRAM_DIN_byp              =>        s_DRAM_DIN_byp,
DRAM_Dout_byp              =>       s_DRAM_Dout_byp,
IRAMout  =>                         s_IRAMout,
PC_out   =>                         s_PC_out 
);



        PCLOCK : process(Clock)
	begin
		Clock <= not(Clock) after 0.5 ns;	
	end process;

    not_clock <= not(Clock);


DRAM_0 : DRAM
    generic map (
                DRAM_DEPTH  => 4*32,

                DATA_SIZE  => 8
            )
    port map (
             Rst   => reset,
             WR_enable   => s_DRAM_WE_byp,
             R_enable   => s_DRAM_RE_byp,
             clock  => not_clock,
             Addr  => s_DRAM_ADD_byp,
             Din  => s_DRAM_DIN_byp,
             Dout  => s_DRAM_DOUT_byp);


IRAM_0 : IRAM
    generic map (
                RAM_DEPTH  => RAM_DEPTH,
                I_SIZE  => IR_SIZE )
    port map (
             Rst   => reset,
             clock   => not_clock,
             Addr  => s_PC_out,
             Dout  => s_IRAMout);


	
	Reset <= '1', '0' after 6 ns, '1' after 11 ns, '0' after 16 ns;
       

end TEST;

-------------------------------

configuration CFG_TB of tb_dlx  is
	for TEST
	end for;
end CFG_TB;

