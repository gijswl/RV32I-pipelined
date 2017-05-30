library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity writeback is
	port(
		I_CLK : in  std_logic;
		I_R   : in  std_logic_vector(31 downto 0);
		I_CS  : in  std_logic_vector(31 downto 0);
		Q_RD  : out std_logic_vector(31 downto 0);
		Q_RW  : out std_logic;
		Q_RA  : out std_logic_vector(4 downto 0)
	);
end entity writeback;

architecture RTL of writeback is
	component reg is
		generic(
			val : std_logic_vector(31 downto 0)
		);
		port(
			I_CLK : in  std_logic;
			I_D   : in  std_logic_vector(31 downto 0);
			I_W   : in  std_logic;
			Q_D   : out std_logic_vector(31 downto 0)
		);
	end component reg;

	signal L_CS : std_logic_vector(31 downto 0) := X"00000000";
	signal L_R  : std_logic_vector(31 downto 0) := X"00000000";
begin
	ir : reg
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_CS,
			I_W   => I_CLK,
			Q_D   => L_CS
		);

	r : reg
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_R,
			I_W   => I_CLK,
			Q_D   => L_R
		);

	Q_RW <= L_CS(22);
	Q_RD <= L_R;
	Q_RA <= L_CS(14 downto 10);
end architecture RTL;
