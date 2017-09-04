library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
--use ieee.numeric_std.all;
--use work.all;

entity ALU is
    generic (
                n_bit: integer := 32);
    port (
             control: in aluOp:= LLS;
             input1: in std_logic_vector(n_bit-1 downto 0):= x"00000011";
             input2: in std_logic_vector(n_bit-1 downto 0):= x"00000011";
             output: out std_logic_vector(n_bit-1 downto 0));

end ALU;

architecture structural of ALU is

    component general_logic_block is
        generic(
                   n_bit: integer :=32);
        port(
                control_signal: in std_logic_vector(3 downto 0);
                r1: in std_logic_vector(n_bit-1 downto 0);
                r2: in std_logic_vector(n_bit-1 downto 0);
                out1: out std_logic_vector(n_bit-1 downto 0));
    end component;

    component comparator is
        generic(
                   n_bit: integer := 32);
        port(
                A: in std_logic_vector(n_bit-1 downto 0);
                B: in std_logic_vector(n_bit-1 downto 0);
                AaboveB: out std_logic;
                Aabove_equalB: out std_logic;
                AequalB: out std_logic;
                Anot_equalB: out std_logic;
                AbelowB: out std_logic;
                Abelow_equalB: out std_logic);

    end component;

    component P4ADD is 
        generic (n_block:	integer := 4; 
                 n_bit :	integer := 32);

        Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
               B:	In	std_logic_vector(n_bit-1 downto 0);
               Ci:	In	std_logic;
               S:	Out	std_logic_vector(n_bit-1 downto 0);
               Co:	Out	std_logic);
    end component; 

    component ALU_MUX is
        generic (n_bit: integer:= 32);
        Port (	ADD:	In	std_logic_vector(n_bit-1 downto 0);
               SH:	In	std_logic_vector(n_bit-1 downto 0);
               GENLOG:	In	std_logic_vector(n_bit-1 downto 0);
               COMP:	In	std_logic_vector(n_bit-1 downto 0);
			   MUL: In std_logic_vector(n_bit-1 downto 0);
               OpCode:	In	aluOp;
               RESULT:	Out	std_logic_vector(n_bit-1 downto 0));
    end component;

    component shifter is
        generic ( n_bit : integer := 32);
        port (input : in std_logic_vector(n_bit-1 downto 0);
              shifter : in std_logic_vector(4 downto 0); 
              control_sig : in aluOp ;
              shifted : out std_logic_vector(n_bit-1 downto 0)
          );
    end component;
	
	component BOOTHMUL is
	generic (n_bit: integer:= 16);

	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
                B:      In      std_logic_vector(n_bit-1 downto 0);
		P:	Out	std_logic_vector(n_bit-1+n_bit downto 0));
	end component;

    signal control_signal_gen_log: std_logic_vector(3 downto 0);
    signal res_add, res_genlog, res_comp, res_sh, res_mul: std_logic_vector(n_bit-1 downto 0);
    signal AaB, AaeB, AeB, AneB, AbB, AbeB: std_logic;
    signal ci, cout: std_logic;
    signal input2_s: std_logic_vector(n_bit-1 downto 0);
begin

    ALU1: comparator
    generic map(n_bit => 32)
    port map(input1, input2, AaB, AaeB, AeB, AneB, AbB, AbeB);

    res_comp(n_bit-1 downto 1) <= (others => '0');

    ALU2: general_logic_block
    generic map(n_bit => 32)
    port map(control_signal_gen_log, input1, input2, res_genlog);

             ALU3: P4ADD
             generic map(n_block => 4, n_bit => 32)
    port map(input1, input2_s, ci, res_add, cout); --use a signal because it changes depending on the operation

             ALU4: shifter
             generic map(n_bit => 32)
    port map(input1, input2(4 downto 0), control, res_sh);
	
	ALU5: BOOTHMUL
	generic map(n_bit =>16)
	port map(input1(15 downto 0), input2(15 downto 0), res_mul);

             SELECTED: ALU_MUX
             generic map(n_bit => 32)
    port map(res_add, res_sh, res_genlog, res_comp, res_mul, control, output);

--first process, to choose what is the output of the comparator, so if we want A>B, A<B, A=B etc.
--combinational
--input: control
--output: res_comp(0)
--NOTEQ, GREQ, LOEQ
             first: process(control,AneB,AaeB,AbeB,control_signal_gen_log,input2,input1) 
             begin
                 case control is
					 when EQU => res_comp(0) <= AeB;
                     when NOTEQ => res_comp(0) <= AneB;
                     when GREQ => res_comp(0) <= AaeB;
                     when LOEQ => res_comp(0) <= AbeB;
					 when LO => res_comp(0)<= AbB;
					 when GR => res_comp(0)<= AaB;
                     when ANDS => control_signal_gen_log <= "1000";
                     when ORS => control_signal_gen_log <= "1110";
                     when XORS => control_signal_gen_log <= "0110";
                     when ADDS => ci <= '0'; input2_s <= input2;
                 when SUBS => ci <= '1';
                 input2_s <= not(input2);
             when others => res_comp(0) <= '0';
             control_signal_gen_log <= (others => '0');
             ci <= '0';
             input2_s <= (others => '0');
         end case;

end process first;


--MODIFIED: the three processes into the first one



--second process, to choose what is the control signal of the general logic bloc, in order to perform different operations like AND, OR etc;
--combinational
--input control
--output: control_signal_gen_log
--ANDS, ORS, XORS
--second: process(control)
--begin
--    case control is 
--        when ANDS => control_signal_gen_log <= "1000";
--        when ORS => control_signal_gen_log <= "1110";
--        when XORS => control_signal_gen_log <= "0110";
--        when others => control_signal_gen_log <= (others => '0');
--    end case;
--end process second;
--
----third process, to choose what is the operation to perform at the adder, i.e. addition or subtraction
----combinational
----input: control
----output: ci, input2_s
---- ADDS,SUBS
--third: process(control)
--begin
--    case control is
--        when ADDS => ci <= '0';
--        input2_s <= input2;
--    when SUBS => ci <= '1';
--    input2_s <= not(input2);
--when others => ci <= '0';
--input2_s <= (others => '0');
--end case;
--end process third;

end structural;
