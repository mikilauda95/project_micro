library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.log.all;


entity P4ADD is 
    generic (n_block:	integer := 4; 
             n_bit :	integer := 32);

    Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
           B:	In	std_logic_vector(n_bit-1 downto 0);
           Ci:	In	std_logic;
           S:	Out	std_logic_vector(n_bit-1 downto 0);
           Co:	Out	std_logic);
end P4ADD; 

architecture structural of P4ADD is
    signal Cout_sig : std_logic_vector(n_bit/n_block downto 1);
    signal Cout_2_sig : std_logic_vector(n_bit/n_block - 1 downto 0);
    signal Co_fin_sig, dummy_cout : std_logic;

component sparse_tree 
    generic (
                n_bit: integer := 32;
                n_block: integer := 4
            );
    port (
             input_1: in std_logic_vector(n_bit downto 1);
             input_2: in std_logic_vector(n_bit downto 1);
             cin: in std_logic;
             output: out std_logic_vector((n_bit/n_block) downto 1)

         );
end component;


    component sum_generator 
        generic (n_block : 	integer := 4;
                 n_bit :	integer := 32);

                 Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
                        B:	In	std_logic_vector(n_bit-1 downto 0);
                        Ci:	In	std_logic_vector(n_bit/n_block-1 downto 0);
                        S:	Out	std_logic_vector(n_bit-1 downto 0);
                        Co:	Out	std_logic);
    end component; 

begin

    Cout_2_sig <= Cout_sig(n_bit/n_block-1 downto 1)&Ci;
    Co <= Cout_sig(n_bit/n_block);

    sparse_tree_0 : sparse_tree
    generic map (
                    n_bit => n_bit,
                    n_block => n_block
                )
    port map (
                 input_1 => A,
                 input_2 => B,
                 cin => Ci,
                 output => Cout_sig
             );

                 sum_generator_0 : sum_generator
                 generic map (n_block => n_block,
                              n_bit => n_bit
                          )
                 port map (A => A,
                           B => B,
                           Ci => Cout_2_sig,
                           S => S,
                           Co => Co_fin_sig );
                 end;
