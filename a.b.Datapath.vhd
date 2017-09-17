library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use work.myTypes.all;
use work.constants.all;

entity datapath is
  generic (
    n_bit: integer := 32;
	CW_SIZE            :     integer := CW_SIZE);  -- Control Word Size
  port (
	clk: in std_logic;
	reset: in std_logic;

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
	PC_out : out std_logic_vector(IR_SIZE-1 downto 0);

    -- dram signals bypassing

    DRAM_RE_byp            : out std_logic;  -- Data RAM read enable
    DRAM_WE_byp            : out std_logic;  -- Data RAM Write Enable
    DRAM_ADD_byp             : out std_logic_vector(n_bit-1 downto 0);
    DRAM_DIN_byp             : out std_logic_vector(n_bit-1 downto 0);

    DRAM_Dout_byp             : in std_logic_vector(n_bit-1 downto 0)

);
end datapath;


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


component FD is
	Port (	D:	In	std_logic;
		CK:	In	std_logic;
		RESET:	In	std_logic;
		Q:	Out	std_logic);
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
signal ADDPC_out_sig, real_PC_out_sig, NPC_out_sig, NPC_out_delayed, NPC_out_delayed2, ADDPC_jal_sig: std_logic_vector(n_bit-1 downto 0);
signal IRout: std_logic_vector(n_bit-1 downto 0);
signal MUX_BRANCHES_sig, PC_OUT_sig, PC_OUT_sig2: std_logic_vector(n_bit-1 downto 0);
signal pc_mux_sig_delayed : std_logic;

--used in decode
signal reg_file_in, regin1, reg_mux1, regin2, reg_mux2, imm2, imm_mux2: std_logic_vector(n_bit-1 downto 0);
signal ADD_WR_SIG,ADD_WR_DEC,ADD_WR_EX, ADD_WR_fetch : std_logic_vector(4 downto 0);
signal ADD_WR_SIG_mux : std_logic_vector(4 downto 0);
signal imm2_sig,imm_j, imm_b, imm_brorj : std_logic_vector(n_bit-1 downto 0);
signal j_imm_cont : std_logic;
signal usls_co : std_logic;
signal jump_PC, offset_j, offset_j_sig : std_logic_vector(n_bit-1 downto 0);
signal s_ADD_A, s_ADD_B : pipe_pos_type;
signal valid_out : std_logic_vector(4 downto 0);
signal validate_out : std_logic_vector(4 downto 0);
signal real_register1, real_register2 : std_logic_vector(n_bit-1 downto 0);

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

------------------------------ DRAM BYPASS------------------------------- 

DRAM_RE_byp         <=  dram_re;
DRAM_WE_byp         <=  DRAM_WE;
DRAM_ADD_byp        <=  reg_alu_out;
DRAM_DIN_byp        <=  regb_bypass;

DRAMout      <=  DRAM_Dout_byp;

--DataRam: DRAM
--generic map(DRAM_DEPTH => 4*32, 
		--DATA_SIZE => 8)
--port map(reset, DRAM_WE, dram_re, not_clk, reg_alu_out, regb_bypass, DRAMout);


--------------------------------------FETCH-----------------------------------------------

---------assignments-------------

--increase program counter
ADDPC_out_sig <= PC_OUT_sig + 4;



--NPC_0 : register_gen_en --next program counter register
    --generic map (
            --n_bit  => 32 )
--port map (
--DIN  => PC_OUT_sig,
--ENABLE  => '1',         --NPC_LATCH_EN,
--RESET  => reset,
--CLK  => clk,
--DOUT  => PC_OUT_sig2 );


--get output of PC
PC_out <= PC_OUT_sig;


--this nor is used because the destination register is coded in different positions depending on the type of instruction
--if the ALU_OPCODE is 0, it means that the instruction is r-type, so the signal rt_vs_it is 1, otherwise it's 0
rt_vs_it <= nor_reduce(IRout(31 downto 26));
---------processes---------------

---------interface---------------


--------------------DESTINATION REGISTER ADDRES CALCULATION--------------------

mux_wb: MUX21_GENERIC --mux to choose the where to write in case of Itype or Rtype
generic map (n_bit => 5)
port map (IRout(15 downto 11), IRout(20 downto 16), rt_vs_it, ADD_WR_fetch); --if control is 0 (itype), 1 for Rtype




NPC : register_gen_en --next program counter register
    generic map (
            n_bit  => 32 )
port map (
DIN  => ADDPC_out_sig,
ENABLE  => '1',         --NPC_LATCH_EN,
RESET  => reset,
CLK  => clk,
DOUT  => NPC_out_sig );


instr_latch : register_gen_en --instruction register 
    generic map (
            n_bit  => 32 )
port map (
DIN  => IRAMout,
ENABLE  => '1', --IR_LATCH_EN,
RESET  => reset,
CLK  => clk,
DOUT  =>  IRout);






-------------------------------------DECODE-------------------------------------------------
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
             Regout     => validate_out,
             ADD_A       => s_ADD_A,
             ADD_B       => s_ADD_B
         );



    process (s_ADD_A, regin1, reg_alu_out, reg_alu_mem, ALUout)
    begin
        case s_ADD_A is
            when RF      =>  real_register1 <= regin1;
            when EXEC    =>  real_register1 <= ALUout;
            when MEM     =>  real_register1 <= reg_alu_out; 
            when WB      =>  real_register1 <= reg_alu_mem; 
        end case;
        
    end process;

    process (s_ADD_B, regin2, reg_alu_out, reg_alu_mem, ALUout)
    begin
        case s_ADD_B is
            when RF      =>  real_register2 <= regin2;
            when EXEC    =>  real_register2 <= ALUout;
            when MEM     =>  real_register2 <= reg_alu_out; 
            when WB     =>   real_register2 <= reg_alu_mem; 
        end case;
        
    end process;


------------------BRANCH AND JUMP LOGIC-----------------------------

jump_PC <= NPC_out_sig + imm2_sig; --used for jump

jump_condition <= JUMP_EN or branch_out_sig(0); 

pc_mux_sig(0) <= jump_condition and JUMP_BRANCH;



not_comp_sig <= not(comp_sig); --used for the branch



ADDPC_jal_sig <= ADDPC_out_sig + 4; --used only for the instruction JAL

process (jump_PC, real_register1, r_vs_imm_j) --used to choose between the normal jump operation (j, jal) and the register jump operation (jr, jalr)
begin
    case r_vs_imm_j is
        when '0' => offset_j_sig <= jump_PC;
        when '1' => offset_j_sig <= real_register1;
        when others => offset_j_sig <= (others => '0');
    end case;
    
end process;


FD_J : FD
	port map (
	        	D => pc_mux_sig(0),
		CK => clk,
		RESET => reset,
		Q => pc_mux_sig_delayed);



register_decode_jump : register_gen_en --register to keep the value from the jump computation result, in order to separate the jump logic from the fetch logic
    generic map (
            n_bit  => 32 )
port map (
DIN  => offset_j_sig,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => offset_j);




mux_pc: MUX21_GENERIC  --mux to choose whether to take NPC or aluoutput as PC, 0 NPC, 1 ALUoutput
generic map (n_bit => 32) 
port map (offset_j, NPC_out_sig, pc_mux_sig_delayed, MUX_BRANCHES_sig);

PC_latch : latch  --latch to move the MUX_BRANCHES_sig into the PC_OUT_sig
	generic map (
	        n_bit => 32 )
	port map (
	        	D => MUX_BRANCHES_sig,
		EN => '1',
		RESET => reset,
		Q => PC_OUT_sig);

--BRANCH part--
mux_branch: MUX21_GENERIC  --mux to choose bez if EQ_COND is 1, bnez if EQ_COND is 0
generic map (n_bit => 1) 
port map (comp_sig, not_comp_sig, EQ_COND, branch_out_sig);


--process to compare the branch register to 0
process(real_register1) 
begin

    if(real_register1= 0 ) then
       comp_sig <= "1"; 
   else
       comp_sig <= "0";
   end if;
       
end process;

----------------------------------------------------------------------------------------------------

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



----------processes---------------


----------interface---------------

--choose the type of immediate

mux_imm_brorj : MUX21_GENERIC --first mux to choose between jump and branch 
generic map (n_bit => 32)
port map (imm_j, imm_b, MUXJ_SEL, imm_brorj); --if control is 0 the output is imm_b, else it's imm_j

mux_imm_j: MUX21_GENERIC --second mux to choose between jump/branch and immediate
generic map (n_bit => 32)
port map (imm_brorj, imm2, MUXBRORJ_SEL, imm2_sig); --if control is 0 the output is imm2, else it's imm_brorj


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


reg_A : register_gen_en --register to store the value of the register 1 we want
    generic map (
            n_bit  => 32 )
port map (
DIN  => real_register1,
ENABLE  => RegA_LATCH_EN,
RESET  => reset,
CLK  => clk,
DOUT  => reg_mux1);

reg_B : register_gen_en --register to store the value of the register 2 we want
    generic map (
            n_bit  => 32 )
port map (
DIN  => real_register2,
ENABLE  => RegB_LATCH_EN,
RESET  => reset,
CLK  => clk,
DOUT  => reg_mux2);


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

----------------------------------EXECUTE----------------------------------------------

------------assignments--------------

ALUin1 <= reg_mux1;

------------processes----------------
--process to perform the different kinds of store operations
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

------------interface----------------


reg_jal_exec : register_gen_en   --register used for the instruction jal, to save the return address
    generic map (
            n_bit  => 32 )
port map (
DIN  => ADDPC_jal_sig,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => RET_ADD);


reg_1 : register_gen_en  --register to store (delay) the value coming from the store operation
    generic map (
            n_bit  => 32 )
port map (
DIN  => store_data,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => regb_bypass);

reg_wra2 : register_gen_en  --register to store (delay) the instruction
    generic map (
            n_bit  => 5 )
port map (
DIN  => ADD_WR_DEC,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => ADD_WR_EX);



mux2: MUX21_GENERIC   --mux to choose the second operand of the ALU
generic map (n_bit => 32)  
port map (imm_mux2, reg_mux2, MUXB_SEL, ALUin2);  --immediate when controls() is 1 (during decode stage)


ArithmeticUnit: ALU  --ALU
generic map (n_bit => 32)
port map (ALU_opCode, ALUin1, ALUin2, ALUout);


reg_alu_o : register_gen_en  --register to store the result of the ALU
    generic map (
            n_bit  => 32 )
port map (
DIN  => ALUout,
ENABLE  => ALU_OUTREG_EN,
RESET  => reset,
CLK  => clk,
DOUT  => reg_alu_out );


----------------------------------MEMORY----------------------------------------------

----------assignments-------------

not_clk <=not(clk);

----------processes---------------

----------interface---------------



reg_3 : register_gen_en   --register to store (and delay) the instruction
    generic map (
            n_bit  => 5 )
port map (
DIN  => ADD_WR_EX,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => ADD_WR_SIG_mux);


LMD : register_gen_en  --register to store the output of the DRAM
    generic map (
            n_bit  => 32 )
port map (
DIN  => DRAMout,
ENABLE  => LMD_LATCH_EN,
RESET  => reset,
CLK  => clk,
DOUT  => LMDout);


ALU_output_mem : register_gen_en  --register to store (delay) the result of the ALU
    generic map (
            n_bit  => 32 )
port map (
DIN  => reg_alu_out,
ENABLE  => '1',
RESET  => reset,
CLK  => clk,
DOUT  => reg_alu_mem);




---------------------------------WRITE BACK-------------------------------------------


----------assignments-------------

----------processes---------------

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

----------interface---------------



mux3: MUX21_GENERIC --mux to chose between the DRAM output and the ALU output (depending on store and load operation)
generic map (n_bit => 32)
port map (reg_alu_mem, load_data, WB_MUX_SEL, reg_file_in);







end structure;
