library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture RTL of testbench is
	component cpu_fpga is
		port(
			I_CLK : in std_logic
		);
	end component cpu_fpga;

	signal L_CLK_100 : std_logic := '0';
begin
	fpga : cpu_fpga
		port map(
			I_CLK => L_CLK_100
		);

	process
	begin
		clock_loop : loop
			L_CLK_100 <= transport '1';
			wait for 5 ns;

			L_CLK_100 <= transport '0';
			wait for 5 ns;
		end loop clock_loop;
	end process;
end architecture RTL;
