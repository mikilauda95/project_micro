library ieee;
use ieee.std_logic_1164.all;
use work.log.all;
use work.all;

package myTypes is

    type aluOp is (
    NOP, ADDS, LLS, LRS, SUBS, ANDS, ORS, XORS, NOTEQ, GREQ, GR, LO, LOEQ, SHAR, SHARX, EQU, MULS
    );
    type pipe_pos_type is (
    RF, EXEC, MEM, WB);

end myTypes;

package constants is


    constant numbit : integer := 32;
    constant n_bit : integer := 32;
    constant n : integer := 32;
    constant logn : integer := 5;
    constant CW_SIZE : integer := 24;
    constant DATA_SIZE : integer := 32;
    constant ADDR_SIZE : integer := 32;
    constant IR_SIZE : integer := 32;
    constant OP_CODE_SIZE : integer := 6;
    constant FUNC_SIZE: integer := 11;
    constant MICROCODE_MEM_SIZE: integer:=64;
    constant RAM_DEPTH: integer:= 4*256;

end constants;
