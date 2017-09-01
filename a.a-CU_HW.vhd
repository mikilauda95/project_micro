library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
use work.constants.all;
--use ieee.numeric_std.all;
--use work.all;

entity dlx_cu is
    generic (
                MICROCODE_MEM_SIZE :     integer := MICROCODE_MEM_SIZE;  -- Microcode Memory Size
                FUNC_SIZE          :     integer := FUNC_SIZE;  -- Func Field Size for R-Type Ops
                OP_CODE_SIZE       :     integer := OP_CODE_SIZE;  -- Op Code Size
                                                                   -- ALU_OPC_SIZE       :     integer := 6;  -- ALU Op Code Word Size
                IR_SIZE            :     integer := IR_SIZE;  -- Instruction Register Size    
                CW_SIZE            :     integer := CW_SIZE);  -- Control Word Size
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

end dlx_cu;

architecture dlx_cu_hw of dlx_cu is
    constant zero_stage_cwnum : integer :=0;
    constant first_stage_cwnum : integer :=0;
    constant second_stage_cwnum : integer :=0;
    constant third_stage_cwnum : integer :=0;
    constant OFFSET_CU2 : integer := 2;
    constant OFFSET_CU3 : integer := 5;
    constant OFFSET_CU4 : integer := 9;
    constant OFFSET_CU5 : integer := 13;
    type mem_array is array (0 to MICROCODE_MEM_SIZE-1) of std_logic_vector(CW_SIZE - 1 downto 0);
    signal cw_mem : mem_array := ("111100010000111", --0 R type: IS IT CORRECT?
    "000000000000000", --1 	
	"111011111001100", --2 J (0X02) instruction encoding corresponds to the address to this ROM
    "000000000000000", --3 JAL to be filled
    "000000000000000", --4 BEQZ to be filled
    "000000000000000", --5 BNEZ
    "000000000000000", --6 bfpt (not implemented)
    "000000000000000", --7 bfpf (not implemented)
    "111010110000111", --8 ADD i
    "001000000000000", --9 Addui (not implemented)
    "111010110000111", --10 SUB i 
    "001000000000000", --11 Subui (not implemented)
    "111010110000111", --12 AND i 
    "111010110000111", --13 OR i 
    "111010110000111", --14 XOR i 
    "001000000000000", --15 lhi (not implemented)
    "001000000000000", --16 rfe (not implemented)
    "000000000000000", --17 trap (not implemented)
    "001000000000000", --18 jr (not implemented)
    "001000000000000", --19 jalr(not implemented)
    "111010110000111", --20 slli 
    "001000000000000", --21 nop
    "111010110000111", --22 srli 
    "111010110000111", --23 srai 
    "111010110000111", --24 seqi
    "111010110000111", --25 snei
    "111010110000111", --26 slti 
    "111010110000111", --27 sgti 
    "111010110000111", --28 slei
    "111010110000111", --29 sgei
    "001000000000000", --30
    "001000000000000", --31
    "001000000000000", --32 lb (not implemented)
    "001000000000000", --33 lh (not implemented)
    "001000000000000", --34
    "111110110010101", --35 lw
    "001000000000000", --36 lbu(not implemented)
    "001000000000000", --37 lhu(not implemented) 
    "001000000000000", --38 lf(not implemented)
    "001000000000000", --39 ld(not implemented)
    "001000000000000", --40 sb(not implemented)
    "001000000000000", --41 sh(not implemented)
    "001000000000000", --
    "111110110100100", --43 sw
    "000000000000000", --
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000",
    "000000000000000"); -- changed cw(cwsize-3 ) to 1 (latch for the first operand in register)


    signal IR_opcode: std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of IR
    signal IR_func : std_logic_vector(FUNC_SIZE-1 downto 0);   -- Func part of IR when Rtype
    signal cw   : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem


  -- control word is shifted to the correct stage
    signal cw1 : std_logic_vector(CW_SIZE -1 downto 0); -- first stage
    signal cw2 : std_logic_vector(CW_SIZE - 1 - OFFSET_CU2 downto 0); -- second stage
    signal cw3 : std_logic_vector(CW_SIZE - 1 - OFFSET_CU3 downto 0); -- third stage
    signal cw4 : std_logic_vector(CW_SIZE - 1 - OFFSET_CU4 downto 0); -- fourth stage
    signal cw5 : std_logic_vector(CW_SIZE -1 - OFFSET_CU5 downto 0); -- fifth stage

    signal aluOpcode_i: aluOp := NOP; -- ALUOP defined in package
    signal aluOpcode1: aluOp := NOP;
    signal aluOpcode2: aluOp := NOP;
    signal aluOpcode3: aluOp := NOP;



begin  -- dlx_cu_rtl

    IR_opcode<= IR_IN(31 downto 26);
    IR_func(10 downto 0)  <= IR_IN(FUNC_SIZE - 1 downto 0);



  -- stage one control signals
    IR_LATCH_EN  <= cw1(CW_SIZE - 1);
    NPC_LATCH_EN <= cw1(CW_SIZE - 2);

  -- stage two control signals
    RegA_LATCH_EN   <= cw2(CW_SIZE - 3);
    RegB_LATCH_EN   <= cw2(CW_SIZE - 4);
    RegIMM_LATCH_EN <= cw2(CW_SIZE - 5);

  -- stage three control signals
    MUXA_SEL      <= cw3(CW_SIZE - 6);
    MUXB_SEL      <= cw3(CW_SIZE - 7);
    ALU_OUTREG_EN <= cw3(CW_SIZE - 8);
    EQ_COND       <= cw3(CW_SIZE - 9);

  -- stage four control signals
    DRAM_WE      <= cw4(CW_SIZE - 10);
    LMD_LATCH_EN <= cw4(CW_SIZE - 11);
    JUMP_EN      <= cw4(CW_SIZE - 12);
    PC_LATCH_EN  <= cw4(CW_SIZE - 13);

  -- stage five control signals
    WB_MUX_SEL <= cw5(CW_SIZE - 14);
    RF_WE      <= cw5(CW_SIZE - 15);


  -- process to pipeline control words
    CW_PIPE: process (Clk, Rst)
    begin  -- process Clk
        if Rst = '1' then                   -- asynchronous reset (active low)
            cw <= (others => '0');
            cw1 <= (others => '0');
            cw2 <= (others => '0');
            cw3 <= (others => '0');
            cw4 <= (others => '0');
            cw5 <= (others => '0');
            aluOpcode1 <= NOP;
            aluOpcode2 <= NOP;
            aluOpcode3 <= NOP;
        elsif Clk'event and Clk = '1' then  -- rising clock edge
            cw <= cw_mem(conv_integer(IR_opcode));
            --cw1 <= cw;
            cw2 <= cw(CW_SIZE - 1 - 2 downto 0);
            cw3 <= cw2(CW_SIZE - 1 - 5 downto 0);
            cw4 <= cw3(CW_SIZE - 1 - 9 downto 0);
            cw5 <= cw4(CW_SIZE -1 - 13 downto 0);
		--ciao
            aluOpcode1 <= aluOpcode_i;
            aluOpcode2 <= aluOpcode1;
            aluOpcode3 <= aluOpcode2; 
        end if;
    end process CW_PIPE;

    ALU_OPCODE <= aluOpcode3;

   -- purpose: Generation of ALU OpCode
   -- type   : combinational
   -- inputs : IR_i
   -- outputs: aluOpcode
    ALU_OP_CODE_P : process (IR_opcode, IR_func)
    begin  -- process ALU_OP_CODE_P
        case conv_integer(unsigned(IR_opcode)) is
        -- case of R type requires analysis of FUNC
            when 0 =>
                case conv_integer(unsigned(IR_func)) is
                    when 4 => aluOpcode_i <= LLS; -- sll according to instruction set coding
                    when 6 => aluOpcode_i <= LRS; -- srl
					when 7 => aluOpcode_i <= SHARX; -- sra
                    when 32 => aluOpcode_i <= ADDS; -- add
                    when 34 => aluOpcode_i <= SUBS; -- sub
                    when 36 => aluOpcode_i <= ANDS; -- and
                    when 37 => aluOpcode_i <= ORS; -- or
                    when 38 => aluOpcode_i <= XORS; -- xor
					when 40 => aluOpcode_i <= EQU; --set if equal
                    when 41 => aluOpcode_i <= NOTEQ; -- set if not equal
                    when 45 => aluOpcode_i <= GREQ; -- set of greater or equal
                    when 44 => aluOpcode_i <= LOEQ; -- set if lower or equal 
					when 14 => aluOpcode_i <= MULS; --it's the multiplication 
					when 42 => aluOpcode_i <= LO; --set if lower
					when 43 => aluOpcode_i <= GR; --set if greater
                    when others => aluOpcode_i <= NOP;
                end case;
            when 2 => aluOpcode_i <= ADDS; -- j
            when 3 => aluOpcode_i <= NOP; -- jal
            when 8 => aluOpcode_i <= ADDS; -- addi
            when 12 => aluOpcode_i <= ANDS; -- and
            when 4 => aluOpcode_i <= EQU; -- branch if equal zero
            when 5 => aluOpcode_i <= NOTEQ; -- branch if not equal zero	
            when 13 => aluOpcode_i <= ORS; -- ori		
            when 29 => aluOpcode_i <= GREQ; -- set of greater or equal immediate
            when 28 => aluOpcode_i <= LOEQ; -- set if lower or equal immediate
            when 20 => aluOpcode_i <= LLS; -- sll immediate according to instruction set coding
            when 25 => aluOpcode_i <= NOTEQ; -- set if not equal immediate
            when 22 => aluOpcode_i <= LRS; -- srl immediate
			when 24 => aluOpcode_i <= EQU; --set if equal 
			when 23 => aluOpcode_i <= SHARX; -- sra immediate
            when 10 => aluOpcode_i <= SUBS; -- subi
            when 14 => aluOpcode_i <= XORS; -- xori
            when 35 => aluOpcode_i <= ADDS; -- lw
            when 21 => aluOpcode_i <= NOP; -- nop
            when 43 => aluOpcode_i <= ADDS; -- sw
			when 26 => aluOpcode_i <= LO; --set if lower immediate
			when 27 => aluOpcode_i <= GR; --set if greater immediate
            when others => aluOpcode_i <= NOP;
        end case;
    end process ALU_OP_CODE_P;


end dlx_cu_hw;
