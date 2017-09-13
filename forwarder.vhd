library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.myTypes.all;
use work.constants.all;

entity forwarder is
    generic (
                n_bit: integer := 5;
                ADDbit: integer := 3);  -- Control Word Size

    port (
             clk: in std_logic;
             reset: in std_logic;
             RegA      : in std_logic_vector(n_bit-1 downto 0);  
             RegB      : in std_logic_vector(n_bit-1 downto 0);  
             Regout    : in std_logic_vector(n_bit-1 downto 0);  
             ADD_A      : out pipe_pos_type;
             ADD_B      : out pipe_pos_type
         );
end entity ;

architecture behavioural of forwarder is

    type forward_conn is array (2 downto 0) of std_logic_vector((n_bit-1) downto 0);
    signal connections : forward_conn;
    signal intermediateA : forward_conn;
    signal intermediateB : forward_conn;
    signal precodeA : std_logic_vector(2 downto 0);
    signal precodeB : std_logic_vector(2 downto 0);

    component register_gen_en IS

        generic(n_bit : integer := 32);
        PORT(
                DIN : IN STD_LOGIC_VECTOR(n_bit-1 DOWNTO 0); -- input.
                ENABLE : IN STD_LOGIC; -- load/enable.
                RESET : IN STD_LOGIC; -- async. clear.
                CLK : IN STD_LOGIC; -- clock.
                DOUT : OUT STD_LOGIC_vector(n_bit-1 DOWNTO 0)
            );
    end component;


    component NOR5 is
        generic (
                    n_bit :	integer := 5); 
        Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
               S:	Out	std_logic);
    end component; 


begin

    registers_declaration: for i in 0 to 2 generate 
        first_register: if(i=0) generate
            register_gen_en_0 : register_gen_en
            generic map (
                            n_bit  => n_bit )
            port map (
                         DIN  => Regout,
                         ENABLE  => '1',
                         RESET  => reset,
                         CLK  => clk,
                         DOUT  =>connections(0));
        end generate first_register;

        other_register: if(i>0) generate 

            register_gen_en_1 : register_gen_en
            generic map (
                            n_bit  => n_bit )
            port map (
                         DIN  => connections(i-1),
                         ENABLE  => '1',
                         RESET  => reset,
                         CLK  => clk,
                         DOUT  =>connections(i));
        end generate other_register;
    end generate registers_declaration;


    xoring: for i in 0 to 2 generate
        intermediateA(i)<= REGA xor connections(i);
        intermediateB(i)<= REGB xor connections(i);
    end generate;

    noringA: for i in 0 to 2 generate

        NOR5_A : NOR5
        generic map (
                        n_bit  => 5 )
        port map (
                     A => intermediateA(i),
                     S => precodeA(i));

    end generate;

    noringB: for i in 0 to 2 generate

        NOR5_B : NOR5
        generic map (
                        n_bit  => 5 )
        port map (
                     A => intermediateB(i),
                     S => precodeB(i) );

    end generate;

    DECODER_A:process (precodeA)
    begin
        if (REGA="00000") then
            ADD_A <=    RF;
        else
            case precodeA  is
                when "001" => ADD_A <=      EXEC;
                when "011" => ADD_A <=      EXEC;
                when "111" => ADD_A <=      EXEC;
                when "101" => ADD_A <=      EXEC;
                when "010" => ADD_A <=      MEM; 
                when "110" => ADD_A <=      MEM; 
                when "100" => ADD_A <=      WB; 
                when others => ADD_A <=    RF;
            end case;
        end if;
    end process;


    DECODER_B:process (precodeA)
    begin
        if (REGB="00000") then
            ADD_B <=    RF;
        else 
            case precodeB  is
                when "001" => ADD_B <=      EXEC;
                when "011" => ADD_B <=      EXEC;
                when "111" => ADD_B <=      EXEC;
                when "101" => ADD_B <=      EXEC;
                when "010" => ADD_B <=      MEM; 
                when "110" => ADD_B <=      MEM; 
                when "100" => ADD_B <=      WB; 
                when others => ADD_B <=    RF;
            end case;
        end if;
    end process;

--precodeA(i) <= intermediateA(i)(0) nor intermediateA(i)(1) nor intermediateA(i)(2) nor intermediateA(i)(3) nor intermediateA(i)(4);
--precodeB(i) <= intermediateB(i)(0) nor intermediateB(i)(1) nor intermediateB(i)(2) nor intermediateB(i)(3) nor intermediateB(i)(4);


--process (REGA,REGB)

--begin
--for i in 0 to 2 loop
--if(REGA=connections(i)) then
--ADD_A <=std_logic_vector(to_unsigned(i, ADDbit));  
--else 
--ADD_A <= "111";
--end if;
--if(REGB=connections(i)) then
--ADD_B <=std_logic_vector(to_unsigned(i, ADDbit));  
--else 
--ADD_B <= "111";
--end if;
--end loop;
--end process;
end behavioural;
