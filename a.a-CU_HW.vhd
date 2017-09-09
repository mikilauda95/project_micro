library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.mytypes.all;
use work.constants.all;
--use ieee.numeric_std.all;
--use work.all;

entity dlx_cu is
    generic (
                microcode_mem_size :     integer := microcode_mem_size;  -- microcode memory size
                func_size          :     integer := func_size;  -- func field size for r-type ops
                op_code_size       :     integer := op_code_size;  -- op code size
                                                                   -- alu_opc_size       :     integer := 6;  -- alu op code word size
                ir_size            :     integer := ir_size;  -- instruction register size    
                cw_size            :     integer := cw_size);  -- control word size
    port (
             clk                : in  std_logic;  -- clock
             rst                : in  std_logic;  -- reset:active-low
                                                  -- instruction register
             ir_in              : in  std_logic_vector(ir_size - 1 downto 0);

    -- if control signal
             ir_latch_en        : out std_logic;  -- instruction register latch enable
             npc_latch_en       : out std_logic;
    -- nextprogramcounter register latch enable
    -- id control signals
             rega_latch_en      : out std_logic;  -- register a latch enable
             regb_latch_en      : out std_logic;  -- register b latch enable
             regimm_latch_en    : out std_logic;  -- immediate register latch enable
             muxj_sel           : out std_logic;
            muxbrorj_sel        : out std_logic;

             muxa_sel           : out std_logic;  -- mux-a sel 

             jump_en            : out std_logic;  -- jump unconditioned identifier
             jump_branch        : out std_logic;  -- jump or branch operation identifier
             pc_latch_en        : out std_logic;  -- program counte latch enable
             jal_sig            : out std_logic;  --signal to write back return address

    -- ex control signals
             muxb_sel           : out std_logic;  -- mux-b sel
             alu_outreg_en      : out std_logic;  -- alu output register enable
             eq_cond            : out std_logic;  -- branch if (not) equal to zero
             store_mux          : out std_logic_vector(1 downto 0);  -- signals to control the data size for stores
             alu_opcode         : out aluop; -- choose between implicit or exlicit coding, like std_logic_vector(alu_opc_size -1 downto 0);

    -- mem control signals
             dram_re            : out std_logic;  -- data ram write enable
             dram_we            : out std_logic;  -- data ram write enable
             lmd_latch_en       : out std_logic;  -- lmd register latch enable

    -- wb control signals
             load_mux           : out std_logic_vector(2 downto 0);  -- signals to control the data size for loads
             wb_mux_sel         : out std_logic;  -- write back mux sel
             rf_we              : out std_logic);  -- register file write enable

end dlx_cu;

architecture dlx_cu_hw of dlx_cu is
    constant zero_stage_cwnum : integer :=0;
    constant first_stage_cwnum : integer :=0;
    constant second_stage_cwnum : integer :=0;

    constant third_stage_cwnum : integer :=0;
    constant offset_cu2 : integer := 2;
    constant offset_cu3 : integer := 12;
    constant offset_cu4 : integer := 17;
    constant offset_cu5 : integer := 20;
    type mem_array is array (0 to microcode_mem_size-1) of std_logic_vector(cw_size - 1 downto 0);
    signal cw_mem : mem_array := (
    "1111000000100100000000011", --0 r type
    "0000000000000000000000000", --1 	
	"1100111111101110000000000", --2 j (0x02) instruction encoding corresponds to the address to this rom
    "1100111111111110000000000", --3 jal 
    "1110101101101110000000000", --4 beqz 
    "1110101101101100000000000", --5 bnez
    "0000000000000000000000000", --6 bfpt (not implemented)
    "0000000000000000000000000", --7 bfpf (not implemented)
    "1110100000101100000000011", --8 add i
    "0010000000000000000000000", --9 addui (not implemented)
    "1110100000101100000000011", --10 sub i 
    "0010000000000000000000000", --11 subui (not implemented)
    "1110100000101100000000011", --12 and i 
    "1110100000101100000000011", --13 or i 
    "1110100000101100000000011", --14 xor i 
    "0010000000000000000000000", --15 lhi (not implemented)
    "0010000000000000000000000", --16 rfe (not implemented)
    "0000000000000000000000000", --17 trap (not implemented)
    "1110110011101110000000000", --18 jr
    "1110110011111110000000000", --19 jalr
    "1110100000101100000000011", --20 slli 
    "0010000000000000000000000", --21 nop
    "1110100000101100000000011", --22 srli 
    "1110100000101100000000011", --23 srai 
    "1110100000101100000000011", --24 seqi
    "1110100000101100000000011", --25 snei
    "1110100000101100000000011", --26 slti 
    "1110100000101100000000011", --27 sgti 
    "1110100000101100000000011", --28 slei
    "1110100000101100000000011", --29 sgei
    "0010000000000000000000000", --30
    "0010000000000000000000000", --31
    "1111100000101100010100101", --32 lb (not implemented)
    "1111100000101100010101101", --33 lh (not implemented)
    "0010000000000000000000000", --34
    "1111100000101100010100001", --35 lw
    "1111100000101100010101001", --36 lbu(not implemented)
    "1111100000101100010110001", --37 lhu(not implemented) 
    "0010000000000000000000000", --38 lf(not implemented)
    "0010000000000000000000000", --39 ld(not implemented)
    "1111100000101100101100000", --40 sb(not implemented)
    "1111100000101100101100000", --41 sh(not implemented)
    "0010000000000000000000000", --
    "1111100000101100101100000", --43 sw
    "0000000000000000000000000", --
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000",
    "0000000000000000000000000"); -- changed cw(cwsize-3 ) to 1 (latch for the first operand in register)


    signal ir_opcode: std_logic_vector(op_code_size -1 downto 0);  -- opcode part of ir
    signal ir_func : std_logic_vector(func_size-1 downto 0);   -- func part of ir when rtype
    signal cw   : std_logic_vector(cw_size - 1 downto 0); -- full control word read from cw_mem


  -- control word is shifted to the correct stage
    signal cw1 : std_logic_vector(cw_size -1 downto 0); -- first stage
    signal cw2 : std_logic_vector(cw_size - 1 - offset_cu2 downto 0); -- second stage
    signal cw3 : std_logic_vector(cw_size - 1 - offset_cu3 downto 0); -- third stage
    signal cw4 : std_logic_vector(cw_size - 1 - offset_cu4 downto 0); -- fourth stage
    signal cw5 : std_logic_vector(cw_size -1 - offset_cu5 downto 0); -- fifth stage

    signal aluopcode_i: aluop := nop; -- aluop defined in package
    signal aluopcode1: aluop := nop;
    signal aluopcode2: aluop := nop;
    signal aluopcode3: aluop := nop;



begin  -- dlx_cu_rtl

    ir_opcode<= ir_in(31 downto 26);
    ir_func(10 downto 0)  <= ir_in(func_size - 1 downto 0);


  -- stage one control signals
    ir_latch_en  <= cw1(cw_size - 1);
    npc_latch_en <= cw1(cw_size - 2);

  -- stage two control signals
    rega_latch_en   <= cw2(cw_size - 3);
    regb_latch_en   <= cw2(cw_size - 4);
    regimm_latch_en <= cw2(cw_size - 5);
    muxj_sel        <= cw2(cw_size-6);
    muxbrorj_sel    <= cw2(cw_size-7);
    muxa_sel      <= cw2(cw_size - 8);
    jump_en      <= cw2(cw_size - 9);
    jump_branch  <= cw2(cw_size - 10);
    pc_latch_en  <= cw2(cw_size - 11);
    jal_sig      <= cw2(cw_size - 12);

  -- stage three control signals
    muxb_sel      <= cw3(cw_size - 13);
    alu_outreg_en <= cw3(cw_size - 14);
    eq_cond       <= cw3(cw_size - 15);
    store_mux     <= cw3(cw_size - 16 downto cw_size-17);

  -- stage four control signals
    dram_re      <= cw4(cw_size - 18);
    dram_we      <= cw4(cw_size - 19);
    lmd_latch_en <= cw4(cw_size - 20);

  -- stage five control signals
    load_mux  <= cw5(cw_size - 21 downto cw_size-23);
    wb_mux_sel <= cw5(cw_size - 24);
    rf_we      <= cw5(cw_size - 25);


  -- process to pipeline control words
    cw_pipe: process (clk, rst)
    begin  -- process clk
        if rst = '1' then                   -- asynchronous reset (active low)
            cw <= (others => '0');
            cw1 <= (others => '0');
            cw2 <= (others => '0');
            cw3 <= (others => '0');
            cw4 <= (others => '0');
            cw5 <= (others => '0');
            aluopcode1 <= nop;
            aluopcode2 <= nop;
            aluopcode3 <= nop;
        elsif clk'event and clk = '1' then  -- rising clock edge
            cw <= cw_mem(conv_integer(ir_opcode));
            --cw1 <= cw;
            cw2 <= cw(cw_size - 1 - offset_cu2 downto 0);
            cw3 <= cw2(cw_size - 1 - offset_cu3 downto 0);
            cw4 <= cw3(cw_size - 1 - offset_cu4 downto 0);
            cw5 <= cw4(cw_size -1 - offset_cu5 downto 0);
		--ciao
            aluopcode1 <= aluopcode_i;
            aluopcode2 <= aluopcode1;
            aluopcode3 <= aluopcode2; 
        end if;
    end process cw_pipe;

    alu_opcode <= aluopcode3;

   -- purpose: generation of alu opcode
   -- type   : combinational
   -- inputs : ir_i
   -- outputs: aluopcode
    alu_op_code_p : process (ir_opcode, ir_func)
    begin  -- process alu_op_code_p
        case conv_integer(unsigned(ir_opcode)) is
        -- case of r type requires analysis of func
            when 0 =>
                case conv_integer(unsigned(ir_func)) is
                    when 4 => aluopcode_i <= lls; -- sll according to instruction set coding
                    when 6 => aluopcode_i <= lrs; -- srl
					when 7 => aluopcode_i <= sharx; -- sra
                    when 32 => aluopcode_i <= adds; -- add
					when 33 => aluopcode_i <= adds; -- addu
                    when 34 => aluopcode_i <= subs; -- sub
					when 35 => aluopcode_i <= subs; -- subu
                    when 36 => aluopcode_i <= ands; -- and
                    when 37 => aluopcode_i <= ors; -- or
                    when 38 => aluopcode_i <= xors; -- xor
					when 40 => aluopcode_i <= equ; --set if equal
                    when 41 => aluopcode_i <= noteq; -- set if not equal
                    when 45 => aluopcode_i <= greq; -- set of greater or equal
                    when 44 => aluopcode_i <= loeq; -- set if lower or equal 
					when 14 => aluopcode_i <= muls; --it's the multiplication 
					when 42 => aluopcode_i <= lo; --set if lower
					when 43 => aluopcode_i <= gr; --set if greater
                    when others => aluopcode_i <= nop;
                end case;
            when 2 => aluopcode_i <= adds; -- j
			when 18 => aluopcode_i <= adds; --jr
            when 3 => aluopcode_i <= adds; -- jal
			when 19 => aluopcode_i <= adds; -- jalr
            when 8 => aluopcode_i <= adds; -- addi
            when 12 => aluopcode_i <= ands; -- and
            when 4 => aluopcode_i <= adds; -- branch if equal zero
            when 5 => aluopcode_i <= adds; -- branch if not equal zero	
            when 13 => aluopcode_i <= ors; -- ori		
            when 29 => aluopcode_i <= greq; -- set of greater or equal immediate
            when 28 => aluopcode_i <= loeq; -- set if lower or equal immediate
            when 20 => aluopcode_i <= lls; -- sll immediate according to instruction set coding
            when 25 => aluopcode_i <= noteq; -- set if not equal immediate
            when 22 => aluopcode_i <= lrs; -- srl immediate
			when 24 => aluopcode_i <= equ; --set if equal 
			when 23 => aluopcode_i <= sharx; -- sra immediate
            when 10 => aluopcode_i <= subs; -- subi
            when 14 => aluopcode_i <= xors; -- xori
            when 35 => aluopcode_i <= adds; -- lw
            when 32 => aluopcode_i <= adds; -- lb
            when 33 => aluopcode_i <= adds; -- lh
            when 36 => aluopcode_i <= adds; -- lbu
            when 37 => aluopcode_i <= adds; -- lhu
            when 21 => aluopcode_i <= nop; -- nop
            when 43 => aluopcode_i <= adds; -- sw
            when 40 => aluopcode_i <= adds; -- sb
            when 41 => aluopcode_i <= adds; -- sh
			when 26 => aluopcode_i <= lo; --set if lower immediate
			when 27 => aluopcode_i <= gr; --set if greater immediate
            when others => aluopcode_i <= nop;
        end case;
    end process alu_op_code_p;


end dlx_cu_hw;
