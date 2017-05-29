library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cpu_fpga is
	port(
		I_CLK : in std_logic
	);
end entity cpu_fpga;

architecture RTL of cpu_fpga is
	component cpu_core is
		port(
			I_CLK : in std_logic
		);
	end component cpu_core;

	signal L_CLK     : std_logic                    := '0';
	signal L_CLK_CNT : std_logic_vector(2 downto 0) := "111";
begin
	cpu : cpu_core
		port map(
			I_CLK => L_CLK
		);

	clk_div : process(I_CLK)
	begin
		if (rising_edge(I_CLK)) then
			L_CLK_CNT <= L_CLK_CNT + "001";
			if (L_CLK_CNT = "001") then
				L_CLK_CNT <= "000";
				L_CLK     <= not L_CLK;
			end if;
		end if;
	end process;
end architecture RTL;
