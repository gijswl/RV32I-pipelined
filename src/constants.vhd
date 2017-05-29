library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package constants is
	constant XLEN : integer := 32;

	constant HI_Z_32 : std_logic_vector(31 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
end package constants;
