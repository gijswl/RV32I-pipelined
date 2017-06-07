library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute is
	port(
		I_CLK  : in  std_logic;
		I_KILL : in  std_logic;
		I_FW_A : in  std_logic_vector(1 downto 0);
		I_FW_B : in  std_logic_vector(1 downto 0);
		I_A    : in  std_logic_vector(31 downto 0);
		I_B    : in  std_logic_vector(31 downto 0);
		I_FW_M : in  std_logic_vector(31 downto 0);
		I_CS   : in  std_logic_vector(31 downto 0);
		Q_CS   : out std_logic_vector(31 downto 0);
		Q_C    : out std_logic_vector(31 downto 0);
		Q_BT   : out std_logic
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

	signal L_WIR : std_logic;

	signal L_IA : std_logic_vector(31 downto 0) := X"00000000";
	signal L_IB : std_logic_vector(31 downto 0) := X"00000000";
	signal L_A  : std_logic_vector(31 downto 0) := X"00000000";
	signal L_B  : std_logic_vector(31 downto 0) := X"00000000";

	signal B_BT   : std_logic := '0';

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
			I_D   => L_IA,
			I_W   => I_CLK,
			Q_D   => L_A
		);

	b : reg
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => L_IB,
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

	L_IA <= I_A when I_FW_A = "00"
		else L_O when I_FW_A = "01"
		else I_FW_M when I_FW_A = "10"
		else "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	L_IB <= I_B when I_FW_B = "00"
		else L_O when I_FW_A = "01"
		else I_FW_M when I_FW_A = "10"
		else "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

	B_BT <= '1' when L_CS(24) = '1' and (
		(L_CS(27 downto 25) = "000" and L_CC(0) = '1') or (L_CS(27 downto 25) = "001" and L_CC(0) = '0') or ((L_CS(27 downto 25) = "101" or L_CS(28 downto 25) = "111") and (L_CC(1) = '0' and L_CC(2) = '0')) or ((L_CS(27 downto 25) = "100" or L_CS(28 downto 25) = "110") and (L_CC(1) = '1' and L_CC(2) = '1'))
	) else '0';

	Q_CS <= L_CS;
	Q_C  <= L_O;
	Q_BT <= B_BT;
end architecture RTL;
