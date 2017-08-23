library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use WORK.constants.all; -- libreria WORK user-defined
use work.myTypes.all;

entity ALU_MUX is
	generic (n_bit: integer:= 32);
	Port (	ADD:	In	std_logic_vector(n_bit-1 downto 0);
		SH:	In	std_logic_vector(n_bit-1 downto 0);
		GENLOG:	In	std_logic_vector(n_bit-1 downto 0);
		COMP:	In	std_logic_vector(n_bit-1 downto 0);
		OpCode:	In	aluOp;
		RESULT:	Out	std_logic_vector(n_bit-1 downto 0));
end ALU_MUX;

architecture behavior of ALU_MUX is

begin
process(OpCode, ADD, SH, GENLOG, COMP)
begin

case OpCode is
	when NOP => RESULT <= (others => '0');
	when ADDS => RESULT <= ADD;
	when LLS => RESULT <= SH;
	when LRS => RESULT <= SH;
	when SHARX => RESULT <= SH;
	when SHAR => RESULT <= SH;
	when SUBS => RESULT <= ADD;
	when ANDS => RESULT <= GENLOG;
	when ORS => RESULT <= GENLOG;
	when XORS => RESULT <= GENLOG;
	when NOTEQ => RESULT <= COMP;
	when LOEQ => RESULT <= COMP;
	when GREQ => RESULT <= COMP;
	when others => RESULT <= (others => '0');
end case;

end process;

end behavior;
	
