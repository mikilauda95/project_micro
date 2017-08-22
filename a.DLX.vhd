library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
use work.constants.all;
--use ieee.numeric_std.all;
--use work.all;

entity DLX is
port(clock : in std_logic;
reset : in std_logic
);
end DLX;


architecture structural of DLX is

component datapath 
  generic (
    n_bit: integer := 32;
	CW_SIZE            :     integer := CW_SIZE);  -- Control Word Size
  port (
	clk: in std_logic;
	reset: in std_logic;

    --controls: in std_logic_vector(CW_SIZE-1 downto 0); --previous implementation
    
    -- IF Control Signal
    IR_LATCH_EN        : in std_logic;  -- Instruction Register Latch Enable
    NPC_LATCH_EN       : in std_logic;
                         
    -- ID Control Signalsin
    RegA_LATCH_EN      : in std_logic;  -- Register A Latch Enable
    RegB_LATCH_EN      : in std_logic;  -- Register B Latch Enable
    RegIMM_LATCH_EN    : in std_logic;  -- Immediate Register Latch Enable

    -- EX Control Signalsin
    MUXA_SEL           : in std_logic;  -- MUX-A Sel
    MUXB_SEL           : in std_logic;  -- MUX-B Sel
    ALU_OUTREG_EN      : in std_logic;  -- ALU Output Register Enable
    EQ_COND            : in std_logic;  -- Branch if (not) Equal to Zero
    -- ALU Operation Codein
    ALU_OPCODE         : in aluOp; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);
    
    -- MEM Control Signalin
    DRAM_WE            : in std_logic;  -- Data RAM Write Enable
    LMD_LATCH_EN       : in std_logic;  -- LMD Register Latch Enable
    JUMP_EN            : in std_logic;  -- JUMP Enable Signal for PC input MUX
    PC_LATCH_EN        : in std_logic;  -- Program Counte Latch Enable

    -- WB Control signalsin
    WB_MUX_SEL         : in std_logic;  -- Write Back MUX Sel
    RF_WE              : in std_logic;  -- Register File Write Enable		
    IRAMout: in std_logic_vector(IR_SIZE-1 downto 0);
    PC_out : out std_logic_vector(IR_SIZE-1 downto 0)
 );
end component;


component dlx_cu is
  generic (
    MICROCODE_MEM_SIZE :     integer := 10;  -- Microcode Memory Size
    FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
    -- ALU_OPC_SIZE       :     integer := 6;  -- ALU Op Code Word Size
    IR_SIZE            :     integer := 32;  -- Instruction Register Size    
    CW_SIZE            :     integer := 15);  -- Control Word Size
  port (
    Clk                : in  std_logic;  -- Clock
    Rst                : in  std_logic;  -- Reset:Active-Low
    -- Instruction Register
    IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);
    
    -- IF Control Signal
    IR_LATCH_EN        : out std_logic;  -- Instruction Register Latch Enable
    NPC_LATCH_EN       : out std_logic;
                                        -- NextProgramCounter Register Latch Enable
    -- ID Control Signals
    RegA_LATCH_EN      : out std_logic;  -- Register A Latch Enable
    RegB_LATCH_EN      : out std_logic;  -- Register B Latch Enable
    RegIMM_LATCH_EN    : out std_logic;  -- Immediate Register Latch Enable

    -- EX Control Signals
    MUXA_SEL           : out std_logic;  -- MUX-A Sel
    MUXB_SEL           : out std_logic;  -- MUX-B Sel
    ALU_OUTREG_EN      : out std_logic;  -- ALU Output Register Enable
    EQ_COND            : out std_logic;  -- Branch if (not) Equal to Zero
    -- ALU Operation Code
    ALU_OPCODE         : out aluOp; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);
    
    -- MEM Control Signals
    DRAM_WE            : out std_logic;  -- Data RAM Write Enable
    LMD_LATCH_EN       : out std_logic;  -- LMD Register Latch Enable
    JUMP_EN            : out std_logic;  -- JUMP Enable Signal for PC input MUX
    PC_LATCH_EN        : out std_logic;  -- Program Counte Latch Enable

    -- WB Control signals
    WB_MUX_SEL         : out std_logic;  -- Write Back MUX Sel
    RF_WE              : out std_logic);  -- Register File Write Enable
end component;


component IRAM is
  generic (
    RAM_DEPTH : integer := RAM_DEPTH;
    I_SIZE : integer := IR_SIZE);
  port (
    Rst  : in  std_logic;
    Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
    Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );
end component;

signal s_IR_LATCH_EN : std_logic;
signal s_NPC_LATCH_EN : std_logic;
signal s_RegA_LATCH_EN : std_logic;
signal s_RegB_LATCH_EN : std_logic;
signal s_RegIMM_LATCH_EN : std_logic;
signal s_MUXA_SEL : std_logic;
signal s_MUXB_SEL : std_logic;
signal s_ALU_OUTREG_EN : std_logic;
signal s_EQ_COND : std_logic;
signal s_ALU_OPCODE : aluOp;
signal s_DRAM_WE : std_logic;
signal s_LMD_LATCH_EN : std_logic;
signal s_JUMP_EN : std_logic;
signal s_PC_LATCH_EN : std_logic;
signal s_WB_MUX_SEL : std_logic;
signal s_RF_WE : std_logic;
signal s_IR_IN: std_logic_vector(IR_SIZE-1 downto 0);
signal s_PC_out : std_logic_vector(IR_SIZE-1 downto 0);

begin
datapath_1 : datapath
  generic map (
    n_bit => 32,
	CW_SIZE             => CW_SIZE )
  port map (
	clk => clock,
	reset => reset,
    --controls: in std_logic_vector(CW_SIZE-1 downto 0) --previous implementation
    -- IF Control Signal
    IR_LATCH_EN         => s_IR_LATCH_EN,
    NPC_LATCH_EN        => s_NPC_LATCH_EN,
    -- ID Control Signalsin
    RegA_LATCH_EN       => s_RegA_LATCH_EN,
    RegB_LATCH_EN       => s_RegB_LATCH_EN,
    RegIMM_LATCH_EN     => s_RegIMM_LATCH_EN,
    -- EX Control Signalsin
    MUXA_SEL            => s_MUXA_SEL,
    MUXB_SEL            => s_MUXB_SEL,
    ALU_OUTREG_EN       => s_ALU_OUTREG_EN,
    EQ_COND             => s_EQ_COND,
    -- ALU Operation Codein
    ALU_OPCODE          => s_ALU_OPCODE,
    -- MEM Control Signalin
    DRAM_WE             => s_DRAM_WE,
    LMD_LATCH_EN        => s_LMD_LATCH_EN,
    JUMP_EN             => s_JUMP_EN,
    PC_LATCH_EN         => s_PC_LATCH_EN,
    -- WB Control signalsin
    WB_MUX_SEL          => s_WB_MUX_SEL,
    RF_WE               => s_RF_WE,
	IRAMout            => s_IR_IN,
	PC_OUT              => s_PC_OUT);
        






dlx_cu_0 : dlx_cu
  generic map (
    MICRocode_mem_size  => MICROCODE_MEM_SIZE,
    FUNC_size           => FUNC_SIZE,
    OP_Code_size        => OP_CODE_SIZE,
    -- Alu_opc_size       :     integer := 6  -- ALU Op Code Word Size
    IR_Size             => IR_SIZE,
    CW_Size             => CW_SIZE )
  port map (
    Clk                 => clock,
    Rst                 => reset,
    -- Instruction register
    IR_In               => s_IR_IN,
    -- If control signal
    IR_Latch_en         => s_IR_LATCH_EN,
    NPC_latch_en        => s_NPC_LATCH_EN,
                                        -- NextProgramCounter Register Latch Enable
    -- Id control signals
    RegA_latch_en       => s_RegA_LATCH_EN,
    RegB_latch_en       => s_RegB_LATCH_EN,
    RegImm_latch_en     => s_RegIMM_LATCH_EN,
    -- Ex control signals
    MUXA_sel            => s_MUXA_SEL,
    MUXB_sel            => s_MUXB_SEL,
    ALU_outreg_en       => s_ALU_OUTREG_EN,
    EQ_Cond             => s_EQ_COND,
    -- Alu operation code
    ALU_opcode          => s_ALU_OPCODE,
    -- Mem control signals
    DRAM_we             => s_DRAM_WE,
    LMD_latch_en        => s_LMD_LATCH_EN,
    JUMP_en             => s_JUMP_EN,
    PC_Latch_en         => s_PC_LATCH_EN,
    -- Wb control signals
    WB_Mux_sel          => s_WB_MUX_SEL,
    RF_We               => s_RF_WE );


IRAM_0 : iram
  generic map (
    RAM_DEPTH  => RAM_DEPTH,
    I_SIZE  => IR_SIZE )
  port map (
    Rst   => Reset,
    Addr  => s_PC_OUT,
    Dout  => s_IR_IN
    );
end structural;
