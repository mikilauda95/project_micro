library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.myTypes.all;

entity shifter is
    generic ( n_bit : integer := 32);
    port (input : in std_logic_vector(n_bit-1 downto 0);
          shifter : in std_logic_vector(4 downto 0); 
          control_sig : in aluOp ;
          shifted : out std_logic_vector(n_bit-1 downto 0)
      );
end shifter;

architecture structural of shifter is

    --constant NBIT : integer := 32;
    constant n : integer := 8;

    subtype mask_array is std_logic_vector(n_bit+n-2 downto 0);
    type mask_type is array (((n_bit)/n)-1 downto 0) of mask_array ; 
    type mask_ref_type is array (n -1 downto 0) of std_logic_vector(n_bit - 1 downto 0);



    signal mask_final : mask_array; 
    signal mask_oper  : mask_type; 
    signal mask_sll   : mask_type; 
    signal mask_srl   : mask_type; 
    signal mask_sra   : mask_type; 
    signal mask_srax  : mask_type; 
    --signal mask_refined : std_logic_vector(31 downto 0);
    signal mask_refined_sll : mask_ref_type;
    signal mask_refined_srl : mask_ref_type;
    signal mask_refined_srax : mask_ref_type;
    signal mask_refined_sra : mask_ref_type;

    signal raw_sel : std_logic_vector(1 downto 0);
    signal ref_sel : std_logic_vector(2 downto 0);
 
begin
--
--    BOH: for row in 0 to log_n_bit generate
--        mask_i_generation: PG_0
--        port map (
--                     a => input_1(column),
--                     b => input_2(column),
--                     c => cin,
--                     g => connections(row)(column),
--                     p => connections(row)(column+n_bit) -- p are stored in the upper part,
--                 );
--
--    end generate ;

        LOOP_MASK: for i in 0 to n_bit/n - 1 generate
            
            mask_sll(i)((n_bit+n-2) downto n*(i+1)-1)  <=  input(n_bit-i*n-1 downto 0);     --UPPER PART
            mask_sll(i)((n*(i+1)-2) downto 0)        <= ( others => '0' );                --LOWER PART

            mask_srl(i)((n_bit+n-2) downto (n_bit+n-2-(n*(i+1)-2)))  <= ( others => '0' );
            mask_srl(i)((n_bit+n-2-(n*(i+1)-1)) downto 0)        <= input(n_bit-n*i-1 downto 0);

            mask_srax(i)((n_bit+n-2) downto (n_bit+n-2-(n*(i+1)-2)))  <= ( others => input(n_bit -1));
            mask_srax(i)((n_bit+n-2-(n*(i+1) -1)) downto 0)        <= input(n_bit-n*i-1 downto 0);

        end generate LOOP_MASK;

        LOOP_MASK_16:for i in 0 to n_bit/(2*n) - 1 generate

            mask_sra(i)(n_bit+n-2 downto (n_bit/2+n-1)) <= (others => input(n_bit/2-1));
            mask_sra(i)((n_bit/2+n-2) downto (n_bit/2+n-2-(n*(i+1)-2)))  <= ( others => input(n_bit/2 - 1) );
            mask_sra(i)((n_bit/2+n-2-(n*(i+1)-1)) downto 0)        <= input(n_bit/2-n*i-1 downto 0);

        end generate LOOP_MASK_16;

        process(control_sig,mask_sll,mask_srl,mask_srax,mask_sra)
        variable temp:mask_type;
    begin
            case control_sig is

                when lls => temp  := mask_sll;
                when lrs => temp  := mask_srl;
                when sharx => temp  := mask_srax;
                when shar => temp  := mask_sra;
		when others => temp := mask_sll;
            end case;
            mask_oper <= temp;  

        end process;    

        raw_sel <= shifter(4 downto 3);

        mask_selection : process(raw_sel, mask_oper)

        variable temp2:mask_array;
        begin
            case raw_sel is

                when "00" => temp2  := mask_oper(0);
                when "01" => temp2  := mask_oper(1);
                when "10" => temp2  := mask_oper(2);
                when "11" => temp2 := mask_oper(3);
                when others => temp2 := (others => '0');

            end case;
            mask_final <= temp2;  

        end process;

        mask_refinement:for i in 0 to n-1 generate
                mask_refined_sll(i)  <= mask_final(n_bit+n-2-i downto n-1-i);
                mask_refined_srl(i)  <= mask_final(n_bit-1+i downto i);
                mask_refined_srax(i) <= mask_final(n_bit-1+i downto i);
                mask_refined_sra(i)(n_bit/2-1 downto 0)  <= mask_final(n_bit/2-1+i downto i);
            end generate;
        ref_sel <= shifter(2 downto 0);
        shift_refine : process(control_sig,mask_refined_sll,mask_refined_srl, mask_refined_srax,mask_refined_sra)
        variable temp3:std_logic_vector(n_bit-1 downto 0);
        begin
            case control_sig is
                when lls => 
                    case ref_sel is
                        when "000" => temp3 := mask_refined_sll(0); 
                        when "001" => temp3 := mask_refined_sll(1); 
                        when "010" => temp3 := mask_refined_sll(2); 
                        when "011" => temp3 := mask_refined_sll(3); 
                        when "100" => temp3 := mask_refined_sll(4); 
                        when "101" => temp3 := mask_refined_sll(5); 
                        when "110" => temp3 := mask_refined_sll(6); 
                        when "111" => temp3 := mask_refined_sll(7); 
                        when others => temp3 := (others => '0');
                    end case;
                when lrs => 
                    case ref_sel is
                        when "000" => temp3 := mask_refined_srl(0); 
                        when "001" => temp3 := mask_refined_srl(1); 
                        when "010" => temp3 := mask_refined_srl(2); 
                        when "011" => temp3 := mask_refined_srl(3); 
                        when "100" => temp3 := mask_refined_srl(4); 
                        when "101" => temp3 := mask_refined_srl(5); 
                        when "110" => temp3 := mask_refined_srl(6); 
                        when "111" => temp3 := mask_refined_srl(7); 
                        when others => temp3 := (others => '0');
                    end case;
                when sharx => 
                    case ref_sel is
                        when "000" => temp3 := mask_refined_srax(0); 
                        when "001" => temp3 := mask_refined_srax(1); 
                        when "010" => temp3 := mask_refined_srax(2); 
                        when "011" => temp3 := mask_refined_srax(3); 
                        when "100" => temp3 := mask_refined_srax(4); 
                        when "101" => temp3 := mask_refined_srax(5); 
                        when "110" => temp3 := mask_refined_srax(6); 
                        when "111" => temp3 := mask_refined_srax(7); 
                        when others => temp3 := (others => '0');
                    end case;
                when shar => 
                    case ref_sel is
                        when "000" => temp3 := mask_refined_sra(0); 
                        when "001" => temp3 := mask_refined_sra(1); 
                        when "010" => temp3 := mask_refined_sra(2); 
                        when "011" => temp3 := mask_refined_sra(3); 
                        when "100" => temp3 := mask_refined_sra(4); 
                        when "101" => temp3 := mask_refined_sra(5); 
                        when "110" => temp3 := mask_refined_sra(6); 
                        when "111" => temp3 := mask_refined_sra(7); 
                        when others => temp3 := (others => '0');
                    end case;
		when others => temp3 := (others => '0');
            end case;

            shifted <= temp3;

        end process;

    end structural;
