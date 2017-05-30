library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute is
	port(
		I_CLK : in  std_logic;
		I_A   : in  std_logic_vector(31 downto 0);
		I_B   : in  std_logic_vector(31 downto 0);
		I_CS  : in  std_logic_vector(31 downto 0);
		Q_CS  : out std_logic_vector(31 downto 0);
		Q_C   : out std_logic_vector(31 downto 0)
	);
end entity execute;

architecture RTL of execute is
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

	component alu is
		port(
			I_CLK : in  std_logic;
			I_A   : in  std_logic_vector(31 downto 0);
			I_B   : in  std_logic_vector(31 downto 0);
			I_FC  : in  std_logic_vector(4 downto 0);
			Q_CC  : out std_logic_vector(2 downto 0); -- V N Z
			Q_O   : out std_logic_vector(31 downto 0)
		);
	end component alu;

	signal L_A : std_logic_vector(31 downto 0) := X"00000000";
	signal L_B : std_logic_vector(31 downto 0) := X"00000000";

	signal L_TYPE : std_logic_vector(31 downto 0) := X"00000000";

	signal L_CS : std_logic_vector(31 downto 0) := X"00000000";
	signal L_CC : std_logic_vector(2 downto 0)  := "000";
	signal L_O  : std_logic_vector(31 downto 0) := X"00000000";
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

	a : reg
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_A,
			I_W   => I_CLK,
			Q_D   => L_A
		);

	b : reg
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_B,
			I_W   => I_CLK,
			Q_D   => L_B
		);

	al : alu
		port map(
			I_CLK => I_CLK,
			I_A   => L_A,
			I_B   => L_B,
			I_FC  => L_CS(19 downto 15),
			Q_CC  => L_CC,
			Q_O   => L_O
		);

	Q_CS <= L_CS;
	Q_C  <= L_O;
end architecture RTL;
