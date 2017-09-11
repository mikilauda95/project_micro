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
    NPC_LATCH_EN       : in std_logic;  -- Next program counter Latch ENABLE
                     
    -- ID Control Signalsin
    RegA_LATCH_EN      : in std_logic;  -- Register A Latch Enable
    RegB_LATCH_EN      : in std_logic;  -- Register B Latch Enable
    RegIMM_LATCH_EN    : in std_logic;  -- Immediate Register Latch Enable
    MUXJ_SEL 		   : in std_logic;  -- Choose between class immediate and 26 bit jump immediate
	MUXBRORJ_SEL 	   : in std_logic;  -- choose between normal op and jump or branch operation
    R_VS_IMM_J         : in std_logic;  -- control signal to select the register of the immediate for the calculation of npc
    JUMP_EN            : in std_logic;  -- JUMP Enable Signal for PC input MUX
    JUMP_BRANCH        : in std_logic;
    PC_LATCH_EN        : in std_logic;  -- Program Counte Latch Enable
    JAL_SIG            : in std_logic;  -- SIGNAL FOR WRITING RETURN ADDRESS
    EQ_COND            : in std_logic;  -- Branch if (not) Equal to Zero
    will_modify        : in std_logic;  -- signal that tells whether a register is modified or not;

    -- EX Control Signalsin
    MUXB_SEL           : in std_logic;  -- MUX-B Sel
    ALU_OUTREG_EN      : in std_logic;  -- ALU Output Register Enable
    STORE_MUX          : in std_logic_vector(1 downto 0);  -- SIGNALS TO CONTROL THE DATA SIZE FOR STORES

    -- ALU Operation Codein
    ALU_OPCODE         : in aluOp; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);
    
    -- MEM Control Signalin
    dram_re            : in std_logic;  -- data ram write enable
    DRAM_WE            : in std_logic;  -- Data RAM Write Enable
    LMD_LATCH_EN       : in std_logic;  -- LMD Register Latch Enable

    -- WB Control signalsin
    LOAD_MUX          : in std_logic_vector(2 downto 0);  -- SIGNALS TO CONTROL THE DATA SIZE FOR STORES
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
           OUT2: 		OUT std_logic_vector(n_bit-1 downto 0);
           RET_ADD:      IN std_logic_vector(n_bit-1 downto 0);
           JAL_SIG:      IN std_logic);
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
             R_enable  : in  std_logic;
             clock : in std_logic;
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



component forwarder is
    generic (
                n_bit: integer := 5;
                ADDbit: integer := 2);  -- Control Word Size

    port (
             clk: in std_logic;
             reset: in std_logic;
             RegA      : in std_logic_vector(n_bit-1 downto 0);  
             RegB      : in std_logic_vector(n_bit-1 downto 0);  
             Regout    : in std_logic_vector(n_bit-1 downto 0);  
             ADD_A      : out pipe_pos_type;
             ADD_B      : out pipe_pos_type
         );
end component ;



--signals declarations

--used in fetch
signal ADDPC_out_sig, NPC_out_sig, NPC_out_delayed, NPC_out_delayed2, ADDPC_jal_sig: std_logic_vector(n_bit-1 downto 0);
signal IRout: std_logic_vector(n_bit-1 downto 0);
signal MUX_BRANCHES_sig, PC_OUT_sig: std_logic_vector(n_bit-1 downto 0);

--used in decode
signal reg_file_in, regin1, reg_mux1, regin2, reg_mux2, imm2, imm_mux2: std_logic_vector(n_bit-1 downto 0);
signal ADD_WR_SIG,ADD_WR_DEC,ADD_WR_EX, ADD_WR_fetch : std_logic_vector(4 downto 0);
signal ADD_WR_SIG_mux : std_logic_vector(4 downto 0);
signal imm2_sig,imm_j, imm_b, imm_brorj : std_logic_vector(n_bit-1 downto 0);
signal j_imm_cont : std_logic;
signal usls_co : std_logic;
signal jump_PC, offset_j : std_logic_vector(n_bit-1 downto 0);
signal s_ADD_A, s_ADD_B : pipe_pos_type;
signal valid_out : std_logic_vector(4 downto 0);
signal validate_out : std_logic_vector(4 downto 0);
signal real_aluin1, real_aluin2 : std_logic_vector(n_bit-1 downto 0);

--used in execute
signal reg_alu_out, ALUout, ALUin1, ALUin2: std_logic_vector(n_bit-1 downto 0);
signal pc_mux_sig: std_logic_vector(0 downto 0);
signal not_comp_sig, comp_sig  : std_logic_vector(0 downto 0);
signal branch_out_sig,branch_out_delayed : std_logic_vector(0 downto 0);
signal sign_ext_delay : std_logic_vector(n_bit -1  downto 0);
signal regb_bypass, RET_ADD, store_data : std_logic_vector(n_bit-1 downto 0);

--used in memory
signal DRAMout, LMDout,reg_alu_mem : std_logic_vector(n_bit-1 downto 0);
signal jump_condition, not_clk : std_logic;

--used in wb
signal rt_vs_it : std_logic;
signal load_data : std_logic_vector(n_bit-1 downto 0);

begin


--------------------------------------FETCH-----------------------------------------------

---------assignments-------------

--increase program counter
ADDPC_out_sig <= PC_OUT_sig + 4;

--get output of PC
PC_out <= PC_OUT_sig;


---------processes---------------

---------interface---------------


--------------------DESTINATION REGISTER ADDRES CALCULATION--------------------

--this nor is used because the destination register is coded in different positions depending on the type of instruction
--if the ALU_OPCODE is 0, it means that the instruction is r-type, so the signal rt_vs_it is 1, otherwise it's 0
NOR5_0 : NOR5
	generic map (
		 n_bit  => 6 )
	port map (
	        	A => IRout(31 downto 26),
		S => rt_vs_it );
		
mux_wb: MUX21_GENERIC --mux to choose the where to write in case of Itype or Rtype
generic map (n_bit => 5)
port map (IRout(15 downto 11), IRout(20 downto 16), rt_vs_it, ADD_WR_fetch); --if control is 0 (itype), 1 for Rtype




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

--immediate needed for the i-type operation
imm2(15 downto 0) <= IRout(15 downto 0);
imm2(31 downto 16) <= (others => IRout(15));

--immediate needed for the j-type operation
imm_j(25 downto 0) <= IRout(25 downto 0);
imm_j(31 downto 26) <= (others =>IRout(25));

--immediate needed for conditional branches
imm_b(15 downto 0) <= IRout(15 downto 0);
imm_b(31 downto 16) <= (others =>IRout(15));

--immediate needed for the i-type operation
--imm2(15 downto 0) <= IRout(15 downto 0);
--imm2(31 downto 16) <= (others => IRout(15));

--immediate needed for the j-type operation
--imm_j(23 downto 0) <= IRout(25 downto 2);
--imm_j(31 downto 24) <= (others =>IRout(25));

--immediate needed for conditional branches
--imm_b(13 downto 0) <= IRout(15 downto 2);
--imm_b(31 downto 14) <= (others =>IRout(15));




--reg_alu_1 : register_gen_en
    --generic map (
            --n_bit  => 1 )
--port map (
--DIN  => branch_out_sig,
--ENABLE  => '1',
--RESET  => reset,
--CLK  => clk,
--DOUT  => branch_out_delayed );



----------processes---------------

----------interface---------------

--------------------FORWARDING LOGIC--------------------
valid_out <= (others => will_modify);
validate_out <= ADD_WR_fetch and valid_out; 
            

forwarder_0 : forwarder
    generic map (
                n_bit => 5,
                ADDbit => 2 )
    port map (
             clk => clk,
             reset => reset,
             RegA       => IRout(25 downto 21),
             RegB       => IRout(20 downto 16),
             Regout     => ADD_WR_fetch,
             ADD_A       => s_ADD_A,
             ADD_B       => s_ADD_B
         );



    process (s_ADD_A, aluin1, reg_alu_out, reg_alu_mem)
    begin
        case s_ADD_A is
            when RF      =>  real_aluin1 <= aluin1;
            when EXEC    =>  real_aluin1 <= reg_alu_out;
            when MEM     =>  real_aluin1 <= reg_alu_mem; 
        end case;
        
    end process;

    process (s_ADD_B, reg_mux2, reg_alu_out, reg_alu_mem)
    begin
        case s_ADD_B is
            when RF   =>  aluin2 <= reg_mux2;
            when EXEC =>  aluin2 <= reg_alu_out;
            when MEM  =>  aluin2 <= reg_alu_mem; 
        end case;
        
    end process;





--choose the type of immediate

mux_imm_brorj : MUX21_GENERIC --first mux to choose between jump and branch 
generic map (n_bit => 32)
port map (imm_j, imm_b, MUXJ_SEL, imm_brorj); --if control is 0 the output is imm_b, else it's imm_j

mux_imm_j: MUX21_GENERIC --second mux to choose between jump/branch and immediate
generic map (n_bit => 32)
port map (imm_brorj, imm2, MUXBRORJ_SEL, imm2_sig); --if control is 0 the output is imm2, else it's imm_brorj

--BRANCH AND JUMP LOGIC

jump_PC <= NPC_out_delayed + imm2_sig;

process (jump_PC, regin1, r_vs_imm_j)
begin
    case r_vs_imm_j is
        when '0' => offset_j <= jump_PC;
        when '1' => offset_j <= regin1;
        when others => offset_j <= (others => '0');
    end case;
    
end process;


--PC_calculation : P4ADD
--generic map (
                --n_block => 4,
                --n_bit  => 32 )
--port map (
             --A => NPC_out_delayed,
             --B => imm2_sig,
             --Ci => '0',
             --S => jump_PC,
             --Co => usls_co );


mux_pc: MUX21_GENERIC  --mux to choose whether to take NPC or aluoutput as PC, 0 NPC, 1 ALUoutput
generic map (n_bit => 32) 
port map (offset_j, NPC_out_sig, pc_mux_sig(0), MUX_BRANCHES_sig);

jump_condition <= JUMP_EN or branch_out_sig(0);
pc_mux_sig(0) <= jump_condition and JUMP_BRANCH;

--BRANCH part--
mux_branch: MUX21_GENERIC  --mux to choose bez if EQ_COND is 1, bnez if EQ_COND is 0
generic map (n_bit => 1) 
port map (comp_sig, not_comp_sig, EQ_COND, branch_out_sig);


not_comp_sig <= not(comp_sig);

ADDPC_jal_sig <= NPC_out_delayed + 4; --used only for the instruction JAL

--process to compare the branch register to 0
process(regin1) 
begin

    if(regin1= 0 ) then
       comp_sig <= "1"; 
   else
       comp_sig <= "0";
   end if;
       
end process;

----------------------------------------------------------------------------------------------------

reg_imm : register_gen_en  --register to store the value of the immediate we want
    generic map (
            n_bit  => 32 )
port map (
DIN  => imm2_sig,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => imm_mux2);


--working with register file

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
           OUT2 => regin2, 
           RET_ADD => RET_ADD,
           JAL_SIG => JAL_SIG);


reg_A : register_gen_en --register to store the value of the immediate we want
    generic map (
            n_bit  => 32 )
port map (
DIN  => regin1,
ENABLE  => RegA_LATCH_EN,
RESET  => reset,
CLK  => clk,
DOUT  => reg_mux1);

reg_B : register_gen_en --register to store the value of the immediate we want
    generic map (
            n_bit  => 32 )
port map (
DIN  => regin2,
ENABLE  => RegB_LATCH_EN,
RESET  => reset,
CLK  => clk,
DOUT  => reg_mux2);




--latchA: latch --latch A to save the value from the rf
--generic map(n_bit =>32)
--port map(regin1, RegA_LATCH_EN, reset, reg_mux1 );

--latchB: latch --latch B to save the value from the rf
--generic map(n_bit =>32)
--port map(regin2, RegB_LATCH_EN, reset, reg_mux2 );




--jump and branch section

reg_wra : register_gen_en --register to store (delay) the instruction
    generic map (
            n_bit  => 5 )
port map (

DIN  => ADD_WR_fetch,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => ADD_WR_DEC);


reg_delay_npc : register_gen_en --register to store (and delay) the next program counter
    generic map (
            n_bit  => 32 )
port map (
DIN  => NPC_out_sig,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => NPC_out_delayed);






--latchimm: latch --latch immediate to save the value of the immediate2
--generic map(n_bit =>32)
--port map(imm2, RegIMM_LATCH_EN, reset, imm_mux2 );

----------------------------------EXECUTE----------------------------------------------

------------assignments--------------
------------processes----------------


------------interface----------------


   --stage three control signals
--alias MUXA_SEL :bit is controls(9);
--alias MUXB_SEL :bit is controls(8);
--alias ALU_OUTREG_EN :bit is controls(7);
--alias EQ_COND :bit is controls(6);

--bypass of Regb for store



reg_jal_exec : register_gen_en 
    generic map (
            n_bit  => 32 )
port map (
DIN  => ADDPC_jal_sig,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => RET_ADD);


--process to compare the branch register to 0
process(reg_mux2, STORE_MUX) 
begin

    if(STORE_MUX="00" ) then 
        store_data<=reg_mux2; 
    elsif(STORE_MUX="01") then
        store_data(7 downto 0) <= reg_mux2(7 downto 0);
        store_data(31 downto 8) <= (others =>reg_mux2(7));
    elsif(STORE_MUX="10") then
        store_data(15 downto 0) <= reg_mux2(15 downto 0);
        store_data(31 downto 16) <= (others =>reg_mux2(15));
    end if;
       
end process;

imm_b(15 downto 0) <= IRout(15 downto 0);
imm_b(31 downto 16) <= (others =>IRout(15));


reg_1 : register_gen_en
    generic map (
            n_bit  => 32 )
port map (
DIN  => store_data,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => regb_bypass);


-- jump and branch section

reg_wra2 : register_gen_en  --register to store (delay) the instruction
    generic map (
            n_bit  => 5 )
port map (
DIN  => ADD_WR_DEC,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => ADD_WR_EX);

--reg_delay_npc2 : register_gen_en  ----register to store (and delay) the next program counter
    --generic map (
            --n_bit  => 32 )
--port map (
--DIN  => NPC_out_delayed,
--ENABLE  => '1',
--RESET  => reset,
--CLK  => clk,
--DOUT  => NPC_out_delayed2);

--ALU part--
--mux1: MUX21_GENERIC   mux to choose the first operand of the ALU
--generic map (n_bit => 32)
--port map (NPC_out_delayed2, reg_mux1, MUXA_SEL, ALUin1); if control is 0 the output is regin1, else it's imm1

ALUin1 <= reg_mux1;

mux2: MUX21_GENERIC   --mux to choose the second operand of the ALU
generic map (n_bit => 32)  
port map (imm_mux2, aluin2, MUXB_SEL, real_aluin2);  --immediate when controls() is 1 (during decode stage)


ArithmeticUnit: ALU
generic map (n_bit => 32)
port map (ALU_opCode, real_aluin1, real_aluin2, ALUout);


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




--lat1: latch --latch to let pass branch selection signal
--generic map(n_bit =>1)
--port map(branch_out_sig, JUMP_EN, reset, pc_mux_sig);


----------------------------------MEMORY----------------------------------------------

----------assignments-------------

----------processes---------------

----------interface---------------
  -- stage four control signals
--alias DRAM_WE :bit is controls(4);
--alias LMD_LATCH_EN :bit is controls(3);
--alias PC_LATCH_EN :bit is controls(2);

not_clk <=not(clk);
DataRam: DRAM
generic map(DRAM_DEPTH => 4*32, 
	    DATA_SIZE => 8)
port map(reset, DRAM_WE, dram_re, not_clk, reg_alu_out, regb_bypass, DRAMout);

--LMD: register_gen  --LMD register
--generic map(n_bit => 32)
--port map(DRAMout, clk, reset, LMDout);

reg_3 : register_gen_en   --register to store (and delay) the instruction
    generic map (
            n_bit  => 5 )
port map (
DIN  => ADD_WR_EX,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => ADD_WR_SIG_mux);


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




---------------------------------WRITE BACK-------------------------------------------

-- stage five control signals
--alias WB_MUX_SEL :bit is controls(1);
--alias RF_WE :bit is controls(0);

----------assignments-------------

----------processes---------------

----------interface---------------


--process to compare the branch register to 0
process(LMDout, LOAD_MUX) 
begin

    if(LOAD_MUX="000" ) then 
        load_data<=LMDout; 
    elsif(LOAD_MUX="001") then
        load_data(7 downto 0) <= LMDout(7 downto 0);
        load_data(31 downto 8) <= (others =>LMDout(7));
    elsif(LOAD_MUX="010") then
        load_data(7 downto 0) <= LMDout(7 downto 0);
        load_data(31 downto 8) <= (others =>'0');
    elsif(LOAD_MUX="011") then
        load_data(15 downto 0) <= LMDout(15 downto 0);
        load_data(31 downto 16) <= (others =>LMDout(15));
    elsif(LOAD_MUX="100") then
        load_data(15 downto 0) <= LMDout(15 downto 0);
        load_data(31 downto 16) <= (others =>'0');
    end if;
       
end process;



mux3: MUX21_GENERIC
generic map (n_bit => 32)  --mux to choose the second operand of the ALU
port map (reg_alu_mem, load_data, WB_MUX_SEL, reg_file_in);







end structure;
