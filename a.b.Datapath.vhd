--to comment with Beppe: pc register (not a latch), memory stage mux, how to manage conflicts in ram and ram input signals.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
use work.constants.all;
--use ieee.numeric_std.all;
--use work.all;

entity datapath is
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
	PC_out : out std_logic_vector(IR_SIZE-1 downto 0));
end datapath;



  -- stage one control signals
--alias IR_LATCH_EN :bit is controls(14);
--alias NPC_LATCH_EN :bit is controls(13);

  ---- stage two control signals
--alias RegA_LATCH_EN :bit is controls(12);
--alias RegB_LATCH_EN :bit is controls(11);
--alias RegIMM_LATCH_EN :bit is controls(10);

  ---- stage three control signals
--alias MUXA_SEL :bit is controls(9);
--alias MUXB_SEL :bit is controls(8);
--alias ALU_OUTREG_EN :bit is controls(7);
--alias EQ_COND :bit is controls(6);
--alias JUMP_EN :bit is controls(5);

  ---- stage four control signals
--alias DRAM_WE :bit is controls(4);
--alias LMD_LATCH_EN :bit is controls(3);
--alias PC_LATCH_EN :bit is controls(2);

  ---- stage five control signals
--alias WB_MUX_SEL :bit is controls(1);
--alias RF_WE :bit is controls(0);






architecture structure of datapath is

component register_file 
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
end component;

component ALU 
  generic (
    n_bit: integer := 32);
  port (
    control: in aluOp;
    input1: in std_logic_vector(n_bit-1 downto 0);
    input2: in std_logic_vector(n_bit-1 downto 0);
    output: out std_logic_vector(n_bit-1 downto 0));

end component;

component register_gen 
	generic(n_bit : integer := 32);
	Port (	D:	In	std_logic_vector(n_bit-1 downto 0);
		CK:	In	std_logic;
		RESET:	In	std_logic;
		Q:	Out	std_logic_vector(n_bit-1 downto 0));
end component;

component latch 
	generic(n_bit: integer:=32);
	Port (	D:	In	std_logic_vector(n_bit-1 downto 0);
		EN:	In	std_logic;
		RESET:	In	std_logic;
		Q:	Out	std_logic_vector(n_bit-1 downto 0));
end component;

component MUX21_GENERIC 
	generic (n_bit: integer:= 32);
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(n_bit-1 downto 0));
end component;

component DRAM 
    generic (
                DRAM_DEPTH : integer := 4*32;
                DATA_SIZE : integer := 8;
                WORD_SIZE : integer := 32;
                ADDR_SIZE : integer := 32);
    port (
             Rst  : in  std_logic;
             WR_enable  : in  std_logic;
             Addr : in  std_logic_vector(ADDR_SIZE - 1 downto 0); 
             Din : in  std_logic_vector(WORD_SIZE - 1 downto 0);
             Dout : out std_logic_vector(WORD_SIZE - 1 downto 0)
         );

end component;

component register_gen_en
    generic(n_bit : integer := 32);
PORT(
DIN : IN STD_LOGIC_VECTOR(n_bit-1 DOWNTO 0); -- input.
ENABLE : IN STD_LOGIC; -- load/enable.
RESET : IN STD_LOGIC; -- async. clear.
CLK : IN STD_LOGIC; -- clock.
DOUT : OUT STD_LOGIC_vector)
; -- output.
end component;


component NOR5 is
	generic (
		 n_bit :	integer := 6); 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		S:	Out	std_logic);
end component; 


--signals declarations

--used in fetch
signal ADDPC_out_sig, NPC_out_sig: std_logic_vector(n_bit-1 downto 0);
signal IRout: std_logic_vector(n_bit-1 downto 0);
signal MUX_BRANCHES_sig, PC_OUT_sig: std_logic_vector(n_bit-1 downto 0);

--used in decode
signal reg_file_in, regin1, reg_mux1, regin2, reg_mux2, imm2, imm_mux2: std_logic_vector(n_bit-1 downto 0);
signal IRout_delay, ADD_WR_SIG,ADD_WR_DEC,ADD_WR_EX : std_logic_vector(n_bit-1 downto 0);
signal ADD_WR_SIG_mux : std_logic_vector(4 downto 0);

--used in execute
signal reg_alu_out, ALUout, ALUin1, ALUin2: std_logic_vector(n_bit-1 downto 0);
signal pc_mux_sig: std_logic_vector(0 downto 0);
signal not_comp_sig, comp_sig, branch_out_sig : std_logic_vector(0 downto 0);
signal sign_ext_delay : std_logic_vector(n_bit -1  downto 0);
signal regb_bypass : std_logic_vector(n_bit-1 downto 0);

--used in memory
signal DRAMout, LMDout,reg_alu_mem : std_logic_vector(n_bit-1 downto 0);

--used in wb
signal rt_vs_it : std_logic;

begin


--------------------------------------FETCH-----------------------------------------------

---------assignments-------------

--increase program counter
ADDPC_out_sig <= PC_OUT_sig + 1;

--get output of PC
PC_out <= PC_OUT_sig;


---------processes---------------

---------interface---------------

NPC : register_gen_en
    generic map (
            n_bit  => 32 )
port map (
DIN  => ADDPC_out_sig,
ENABLE  => '1',--NPC_LATCH_EN,
RESET  => reset,
CLK  => clk,
DOUT  => NPC_out_sig );


instr_latch : register_gen_en
    generic map (
            n_bit  => 32 )
port map (
DIN  => IRAMout,
ENABLE  => '1', --IR_LATCH_EN,
RESET  => reset,
CLK  => clk,
DOUT  =>  IRout);


--NPC: latch  --Next program counter LATCH
--generic map(n_bit => 32)
--port map(ADDPC_out_sig, NPC_LATCH_EN, reset, NPC_out_sig);
--
--instr_latch: latch --Istruction Register
--generic map(n_bit => 32)
--port map(IRAMout, IR_LATCH_EN, reset, IRout);

--PC_register: register_gen --register to implement the PC
--generic map(n_bit =>32)
--port map(MUX_BRANCHES_sig, clock, reset, PC_OUT_sig ); --to be completed, PC enable is always 1, no control


--reg_pc : register_gen_en
--    generic map (
--            n_bit  => 32 )
--port map (
--DIN  => MUX_BRANCHES_sig,
--ENABLE  => '1', --PC_LATCH_EN eliminated because during first instructions it does not update the pc
--RESET  => reset,
--CLK  => clk,
--DOUT  => PC_OUT_sig );


PC_latch : latch
	generic map (
	        n_bit => 32 )
	port map (
	        	D => MUX_BRANCHES_sig,
		EN => '1',
		RESET => reset,
		Q => PC_OUT_sig);



-------------------------------------DECODE-------------------------------------------------



----------assignments-------------


--sign extention



imm2(15 downto 0) <= IRout(15 downto 0);
imm2(31 downto 16) <= (others => IRout(15));

----------processes---------------

----------interface---------------



register_file_0 : register_file  --register file
    generic map (
            n_bit  => s_n_bit )
    port map (
             CLK => clk,
           RESET => reset,
           ENABLE => '1',   
           RD1 => '1',         --probably not needed because of next latch
           RD2 => '1',
           WR => RF_WE,
           ADD_WR =>ADD_WR_SIG_mux,
           ADD_RD1 => IRout(25 downto 21),
           ADD_RD2 => IRout(20 downto 16),
           DATAIN => reg_file_in,
           OUT1 => regin1,
           OUT2 => regin2 );

latchA: latch --latch A to save the value from the rf
generic map(n_bit =>32)
port map(regin1, RegA_LATCH_EN, reset, reg_mux1 );

latchB: latch --latch B to save the value from the rf
generic map(n_bit =>32)
port map(regin2, RegB_LATCH_EN, reset, reg_mux2 );





reg_imm : register_gen_en
    generic map (
            n_bit  => 32 )
port map (
DIN  => imm2,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => imm_mux2);

reg_wra : register_gen_en
    generic map (
            n_bit  => 32 )
port map (

DIN  => IRout,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => ADD_WR_DEC);


reg_2 : register_gen_en
    generic map (
            n_bit  => 32 )
port map (
DIN  => ADD_WR_DEC,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => ADD_WR_EX);


reg_3 : register_gen_en
    generic map (
            n_bit  => 32 )
port map (
DIN  => ADD_WR_EX,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => IRout_delay);


--latchimm: latch --latch immediate to save the value of the immediate2
--generic map(n_bit =>32)
--port map(imm2, RegIMM_LATCH_EN, reset, imm_mux2 );

----------------------------------EXECUTE----------------------------------------------

------------assignments--------------
not_comp_sig <= not(comp_sig);
------------processes----------------

--process to compare the branch register to 0
process(reg_mux1, clk) 
begin

    if(reg_mux1= 0 ) then
       comp_sig <= "1"; 
   else
       comp_sig <= "0";
   end if;
       
end process;

------------interface----------------


   --stage three control signals
--alias MUXA_SEL :bit is controls(9);
--alias MUXB_SEL :bit is controls(8);
--alias ALU_OUTREG_EN :bit is controls(7);
--alias EQ_COND :bit is controls(6);

--bypass of Regb for store

reg_1 : register_gen_en
    generic map (
            n_bit  => 32 )
port map (
DIN  => reg_mux2,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => regb_bypass);



--ALU part--
mux1: MUX21_GENERIC   --mux to choose the first operand of the ALU
generic map (n_bit => 32)
port map (NPC_out_sig, reg_mux1, MUXA_SEL, ALUin1); --if control is 0 the output is regin1, else it's imm1

mux2: MUX21_GENERIC   --mux to choose the second operand of the ALU
generic map (n_bit => 32)  
port map (imm_mux2, regin2, MUXB_SEL, ALUin2);  --immediate when controls() is 1


ArithmeticUnit: ALU
generic map (n_bit => 32)
port map (ALU_opCode, ALUin1, ALUin2, ALUout);


--ACHTUNG ATTENZIONE, this register is different from others because it has enable and it is behavioral
reg_alu_o : register_gen_en 
    generic map (
            n_bit  => 32 )
port map (
DIN  => ALUout,
ENABLE  => ALU_OUTREG_EN,
RESET  => reset,
CLK  => clk,
DOUT  => reg_alu_out );

--old implementation
--reg_alu_o: register_gen --register of the ALU output
--generic map(n_bit => 32)
--port map(ALUout, clk, reset, reg_alu_out);

--BRANCH part--
mux_branch: MUX21_GENERIC  --mux to choose bez if controls(?) 1, bnez if controls(?) is 0
generic map (n_bit => 1) 
port map (comp_sig, not_comp_sig, EQ_COND, branch_out_sig);

lat1: latch --latch to let pass branch selection signal
generic map(n_bit =>1)
port map(branch_out_sig, JUMP_EN, reset, pc_mux_sig);


----------------------------------MEMORY----------------------------------------------

----------assignments-------------

----------processes---------------

----------interface---------------
  -- stage four control signals
--alias DRAM_WE :bit is controls(4);
--alias LMD_LATCH_EN :bit is controls(3);
--alias PC_LATCH_EN :bit is controls(2);

DataRam: DRAM
generic map(DRAM_DEPTH => 4*32, 
	    DATA_SIZE => 8)
port map(reset, DRAM_WE, reg_alu_out, regb_bypass, DRAMout);

--LMD: register_gen  --LMD register
--generic map(n_bit => 32)
--port map(DRAMout, clk, reset, LMDout);



LMD : register_gen_en
    generic map (
            n_bit  => 32 )
port map (
DIN  => DRAMout,
ENABLE  => LMD_LATCH_EN,
RESET  => reset,
CLK  => clk,
DOUT  => LMDout);


ALU_output_mem : register_gen_en
    generic map (
            n_bit  => 32 )
port map (
DIN  => reg_alu_out,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => reg_alu_mem);


mux_pc: MUX21_GENERIC  --mux to choose whether to take NPC or aluoutput as PC, 0 NPC, 1 ALUoutput
generic map (n_bit => 32) 
port map (reg_alu_mem, NPC_out_sig, pc_mux_sig(0), MUX_BRANCHES_sig);


---------------------------------WRITE BACK-------------------------------------------

  -- stage five control signals
--alias WB_MUX_SEL :bit is controls(1);
--alias RF_WE :bit is controls(0);

----------assignments-------------

----------processes---------------

----------interface---------------

mux3: MUX21_GENERIC
generic map (n_bit => 32)  --mux to choose the second operand of the ALU
port map (reg_alu_mem, LMDout, WB_MUX_SEL, reg_file_in);


          mux_wb: MUX21_GENERIC --mux to choose the where to write in case of Itype or Rtype
generic map (n_bit => 5)
port map (IRout_delay(15 downto 11), IRout_delay(20 downto 16), rt_vs_it, ADD_WR_SIG_mux); --if control is 0 (itype) 1 for Rtype


NOR5_0 : NOR5
	generic map (
		 n_bit  => 6 )
	port map (
	        	A => IRout_delay(31 downto 26),
		S => rt_vs_it );



end structure;
