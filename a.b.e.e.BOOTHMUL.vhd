library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use WORK.constants.all; -- libreria WORK user-defined
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity BOOTHMUL is
	generic (n_bit: integer:= numBit);

	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
                B:      In      std_logic_vector(n_bit-1 downto 0);
		P:	Out	std_logic_vector(n_bit-1+n_bit downto 0));
end BOOTHMUL;


architecture structural of BOOTHMUL is


component P4ADD  
    generic (n_block:	integer := 4; 
             n_bit :	integer := 32);

    Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
           B:	In	std_logic_vector(n_bit-1 downto 0);
           Ci:	In	std_logic;
           S:	Out	std_logic_vector(n_bit-1 downto 0);
           Co:	Out	std_logic);
end component; 


component MUX81_GENERIC 
	generic (n_bit: integer:= numBit
                 );
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
                C:	In	std_logic_vector(n_bit-1 downto 0);
		D:	In	std_logic_vector(n_bit-1 downto 0);
		E:	In	std_logic_vector(n_bit-1 downto 0);
                F:	In	std_logic_vector(n_bit-1 downto 0);
	        G:	In	std_logic_vector(n_bit-1 downto 0);
	        H:	In	std_logic_vector(n_bit-1 downto 0);
		S:	In	std_logic_vector(2 downto 0);
		Y:	Out	std_logic_vector(n_bit-1 downto 0));
end component;

component encoder 

	Port (	A:	In	std_logic_vector(2 downto 0);

		Y:	Out	std_logic_vector(2 downto 0));
end component;

 type Signalvector is array (n_bit-1 downto 0) of std_logic_vector (2*n_bit -1 downto 0);
 type Signalvector2 is array (n_bit/2-1 downto 0) of std_logic_vector (2 downto 0);
signal c_sig: signalvector2;
signal B_sig: Signalvector2;
signal out1, out2 : Signalvector; --like in the RCA
signal A_shifted, neg_A_shifted: Signalvector;
signal first_enc: std_logic_vector (2 downto 0);
begin
process(A_shifted, A)
		begin
	  A_shifted(0)(n_bit-1 downto 0)<= A;
	  A_shifted(0)(n_bit*2-1 downto n_bit)<= (others => A(n_bit-1));
          neg_A_shifted(0) <= -A_shifted(0);



	shift: for i in 1 to n_bit-1 loop
    	  A_shifted(i)(n_bit-1+i downto 0) <= A_shifted(i-1)(n_bit-2+i downto 0) & '0' ; --shift by 1
		  A_shifted(i)(n_bit*2  -1 downto n_bit+i) <= (others => A(n_bit-1));
                     neg_A_shifted(i) <= -A_shifted(i);
	end loop shift;
	
end process;
process(B, first_enc )
		begin
	first_enc <= (others => '0');
    first_enc (2 downto 1) <= B(1 downto 0);
	B_sig(0) <= first_enc;
	control: for i in 0 to n_bit/2-2 loop
		B_sig(i+1)<= B(i*2+3 downto i*2+1);
		end loop control;
end process;	

    gen: for i in 0 to n_bit/2-1   generate 
	begin 
    ENC2 : encoder  
	  Port Map (B_sig(i), c_sig(i));
	  end generate;
	

    M: MUX81_GENERIC
      generic map (n_bit*2)  
	  Port Map ((others => '0'), A_shifted(0) , neg_A_shifted(0), A_shifted(1), neg_A_shifted(1),(others => '0'),(others => '0'),(others => '0'), c_sig(0), out1(0));
	  

	 gen1: for i in 0 to n_bit/2-2   generate
    M2: MUX81_GENERIC
      generic map (2*n_bit) 
	  Port Map ((others => '0'), A_shifted(i*2+2) , neg_A_shifted(i*2+2), A_shifted(i*2+3), neg_A_shifted(i*2+3),(others => '0'),(others => '0'),(others => '0'), c_sig(i+1), out2(i));	
    S: P4ADD
      generic map (n_bit/4, 2*n_bit) 
	  Port Map (out1(i), out2(i) , '0', out1(i+1), open);  
  end generate;

P<= out1(n_bit/2-1);   

end structural;



