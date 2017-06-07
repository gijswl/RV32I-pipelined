library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity memory is
	port(
		I_CLK : in  std_logic;
		I_C   : in  std_logic_vector(31 downto 0);
		I_PC  : in  std_logic_vector(31 downto 0);
		I_CS  : in  std_logic_vector(31 downto 0);
		Q_CS  : out std_logic_vector(31 downto 0);
		Q_R   : out std_logic_vector(31 downto 0);
		Q_PC  : out std_logic_vector(31 downto 0)
	);
end entity memory;

architecture RTL of memory is
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
	signal L_C  : std_logic_vector(31 downto 0) := X"00000000";
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

	pc : reg
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_PC,
			I_W   => I_CLK,
			Q_D   => Q_PC
		);

	c : reg
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_C,
			I_W   => I_CLK,
			Q_D   => L_C
		);

	-- TODO this needs to change when adding reads from memory
	Q_R  <= L_C when L_CS(23) = '0' else X"00000000";
	Q_CS <= L_CS;
end architecture RTL;
