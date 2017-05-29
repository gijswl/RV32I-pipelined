library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute is
	port(
		I_CLK   : in  std_logic;
		I_A     : in  std_logic_vector(31 downto 0);
		I_B     : in  std_logic_vector(31 downto 0);
		I_INSTR : in  std_logic_vector(31 downto 0);
		Q_INSTR : out std_logic_vector(31 downto 0);
		Q_C     : out std_logic_vector(31 downto 0)
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

	component itype_decoder is
		port(
			I_INSTR  : in  std_logic_vector(6 downto 0);
			Q_TYPE   : out std_logic_vector(31 downto 0);
			Q_FORMAT : out std_logic_vector(5 downto 0)
		);
	end component itype_decoder;

	signal L_A : std_logic_vector(31 downto 0) := X"00000000";
	signal L_B : std_logic_vector(31 downto 0) := X"00000000";

	signal L_TYPE : std_logic_vector(31 downto 0) := X"00000000";

	signal L_INSTR : std_logic_vector(31 downto 0) := X"00000000";
	signal L_FC    : std_logic_vector(4 downto 0)  := "00000";
	signal L_CC    : std_logic_vector(2 downto 0)  := "000";
	signal L_O     : std_logic_vector(31 downto 0) := X"00000000";

	signal L_FUNC : std_logic_vector(3 downto 0) := "0000";

	signal A_INSTR_FUNC : std_logic_vector(4 downto 0) := "00000";
	signal A_ALU_FUNC   : std_logic_vector(4 downto 0) := "00000";
begin
	ir : reg
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => I_INSTR,
			I_W   => I_CLK,
			Q_D   => L_INSTR
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
			I_FC  => L_FC,
			Q_CC  => L_CC,
			Q_O   => L_O
		);

	type_decoder : itype_decoder
		port map(
			I_INSTR => L_INSTR(6 downto 0),
			Q_TYPE  => L_TYPE
		);

	L_FUNC <= L_INSTR(30) & L_INSTR(14 downto 12);
	with L_FUNC select A_ALU_FUNC <=
		"00010" when "0000",
		"00011" when "1000",
		"10000" when "0001",
		"00111" when "0010",
		"00111" when "1010",
		"01000" when "0011",
		"01000" when "1011",
		"00110" when "0100",
		"10001" when "0101",
		"10010" when "1101",
		"00101" when "0110",
		"00100" when "0111",
		"00000" when others;
		
	with L_TYPE select A_INSTR_FUNC <=
		"00001" when "00000000000000000000000000100000",
		"00010" when "00000000000000000010000000000000",
		"00000" when others;

	L_FC <= A_ALU_FUNC when L_TYPE(4) = '1' or L_TYPE(5) = '1' else A_INSTR_FUNC;

	Q_INSTR <= L_INSTR;
	Q_C     <= L_O;
end architecture RTL;
