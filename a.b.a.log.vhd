library ieee;
use ieee.std_logic_1164.all;

package log is

	function log2_unsigned ( x : natural ) return natural;

end log;

package body log is

	function log2_unsigned ( x : natural ) return natural is
	variable temp : natural := x ;
	variable N : natural := 0 ;
	begin
		while temp > 1 loop
			temp := temp / 2 ;
			N := N + 1 ;
		end loop ;
		return N ;
	end log2_unsigned ;

end log;


