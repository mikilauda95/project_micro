library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.log.all;

--function log2_unsigned ( x : natural ) return natural is
--variable temp : natural := x ;
--variable N : natural := 0 ;
--begin
--	while temp > 1 loop
--		temp := temp / 2 ;
--		N := N + 1 ;
--	end loop ;
--	return N ;
--end function log2_unsigned ;

entity sparse_tree is
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
end sparse_tree;

architecture structural of sparse_tree is


    --type tree_conn is array (log_n_bit-1 downto 0) of std_logic_vector((2*n_bit) downto 1);
    constant log_n_bit : natural := log2_unsigned(n_bit);
    constant log_n_block : natural := log2_unsigned(n_block);
    type tree_conn is array (log_n_bit downto 0) of std_logic_vector((2*n_bit) downto 1);
    signal connections : tree_conn;



    component PG 
        port (
                 a: in std_logic;
                 b: in std_logic;
                 p: out std_logic;
                 g: out std_logic
             );
    end component;

    component PG_0 
        port (
                 a: in std_logic;
                 b: in std_logic;
                 c: in std_logic;
                 g: out std_logic;
                 p: out std_logic

             );
    end component;

    component PG_gen 
        port (
                 p1: in std_logic;
                 g1: in std_logic;
                 p2: in std_logic;
                 g2: in std_logic;

                 g: out std_logic;
                 p: out std_logic


             );
    end component;

    component G_gen 
        port (
                 p1: in std_logic;
                 g1: in std_logic;
                 g2: in std_logic;
                 g: out std_logic

             );
    end component;



begin

    BOH: for row in 0 to log_n_bit generate
        FIRST_PART: if row <= log_n_block generate
            FIRST_ROW: if row = 0 generate
                LOOP_COLUMNS: for column in 1 to n_bit generate
                    FIRST_ELEM: if column = 1 generate
                        PG_0_0 : PG_0
                        port map (
                                     a => input_1(column),
                                     b => input_2(column),
                                     c => cin,
                                     g => connections(row)(column),
                                     p => connections(row)(column+n_bit) -- p are stored in the upper part,
                                 );

                    end generate FIRST_ELEM;

                    OTHER_FIRSTS: if column /= 1 generate 
                        PG_0 : PG
                        port map (
                                     a => input_1(column), 
                                     b => input_2(column),
                                     p => connections(row)(column+n_bit), -- p are stored in the upper part,
                                     g => connections(row)(column) --g are stored in the lower part of the signal array
                                 );

                    end generate OTHER_FIRSTS;		
                end generate LOOP_COLUMNS;
            end generate FIRST_ROW;
            FIRST_GENERIC:if row /= 0 generate --first row with generic G and P
                LOOP_COLUMNS_2: for column in 1 to (n_bit/(2**(row))) generate
                    FIRST_G_GEN: if column = 1 generate


                        G_gen_0 : G_gen
                        port map (
                                     p1 => connections(row-1)(column*2**(row) + n_bit),
                                     g1 => connections(row-1)(column*2**(row)),
                                     g2 => connections(row-1)(column*2**(row) - 2**(row-1) ),
                                     g => connections(row)(column*2**(row))
                                 );

                    end generate FIRST_G_GEN;

                    OTHERS_PG: if column /= 1 generate


                        PG_gen_0 : PG_gen
                        port map (
                                     p1 => connections(row-1)(column*2**(row) + n_bit),
                                     g1 => connections(row-1)(column*2**(row)),
                                     p2 => connections(row-1)(column*2**(row) - 2**(row-1) + n_bit),
                                     g2 => connections(row-1)(column*2**(row) - 2**(row-1) ),
                                     g => connections(row)(column*2**(row)),
                                     p => connections(row)(column*2**(row)+n_bit)
                                 );

                    end generate OTHERS_PG;
                end generate LOOP_COLUMNS_2;
            end generate FIRST_GENERIC;
        end generate FIRST_PART;

        SECOND_PART: if row > log_n_block generate 
            loop_column_2_2: for column_2 in 1 to (n_bit/(n_block*2**(row-(log_n_block)))) generate

                LOOP_DUMMY: for dummy_block in 1 to 2**((row-(log_n_block))-1) generate
                    --instantiate dummy signal
                    connections(row)(((column_2-1)*2**(row-(log_n_block))+(dummy_block))*n_block + n_bit) <= connections(row-1)(((column_2-1)*2**(row-(log_n_block))+(dummy_block))*n_block + n_bit);--connect p
                    connections(row)(((column_2-1)*2**(row-(log_n_block))+(dummy_block))*n_block) <= connections(row-1)((((column_2-1)*2**(row-(log_n_block)))+(dummy_block))*n_block);--connect g
                                                                                                                                                         --dummy_p : dummy
                                                                                                                                                         --port map (
                                                                                                                                                         --		 a => connections(row)((column_2-1)*2*n_block+(dummy_block) + n_bit),

                --		 o => connections(row + 1)((column_2-1)*2*n_block+(dummy_block) + n_bit));

                --dummy_g : dummy
                --port map (
                --		 a => connections(row)((column_2-1)*2*n_block+(dummy_block)),

                --		 o => connections(row + 1)((column_2-1)*2*n_block+(dummy_block))
                --	 );
                end generate LOOP_DUMMY;

                SEC_PART_COMP: for comp_block in 1 to 2**(row-(log_n_block)-1) generate
                    SEC_PART_G: if column_2=1 generate


                        G_gen_1 : G_gen
                        port map (
                                     p1 => connections(row-1)(((column_2-1)*2**(row-(log_n_block))+2**(row-1-log_n_block)+comp_block)*n_block+n_bit),
                                     g1 => connections(row-1)(((column_2-1)*2**(row-(log_n_block))+2**(row-1-log_n_block)+comp_block)*n_block),
                                     g2 => connections(row-1)(((column_2-1)*2**(row-(log_n_block))+2**(row-1-log_n_block))*n_block),
                                     g => connections(row)(((column_2-1)*2**(row-(log_n_block))+2**(row-1-log_n_block)+comp_block)*n_block)
                                 );

                    end generate SEC_PART_G;
                    SEC_PART_PG: if column_2/=1 generate


                        PG_gen_1 : PG_gen
                        port map (
                                     p1 => connections(row-1)(((column_2-1)*2**(row-(log_n_block))+2**(row-1-log_n_block)+comp_block)*n_block+n_bit),
                                     g1 => connections(row-1)(((column_2-1)*2**(row-(log_n_block))+2**(row-1-log_n_block)+comp_block)*n_block),
                                     p2 => connections(row-1)(((column_2-1)*2**(row-(log_n_block))+2**(row-1-log_n_block))*n_block+n_bit),
                                     g2 => connections(row-1)(((column_2-1)*2**(row-(log_n_block))+2**(row-1-log_n_block))*n_block),
                                     g => connections(row)(((column_2-1)*2**(row-(log_n_block))+2**(row-1-log_n_block)+comp_block)*n_block),
                                     p => connections(row)(((column_2-1)*2**(row-(log_n_block))+2**(row-1-log_n_block)+comp_block)*n_block+n_bit)
                                 );

                    end generate SEC_PART_PG;
                end generate SEC_PART_COMP;
            end generate loop_column_2_2;
        end generate SECOND_PART;
    end generate BOH;

    FINAL_CONN: for column in 1 to n_bit/n_block generate
        output(column) <= connections(log_n_bit)(column*n_block);
    end generate;	
    --due generate: 1 per gli elementi che sono sempre 4 (condizionato a seconda se min o mag di 2^(j-1)
    --		2 per dei dummy sig (sempre 4)


    end;
