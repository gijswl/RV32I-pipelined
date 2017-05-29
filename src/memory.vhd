library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
	port(
		I_CLK   : in  std_logic;
		I_C     : in  std_logic_vector(31 downto 0);
		I_INSTR : in  std_logic_vector(31 downto 0);
		Q_INSTR : out std_logic_vector(31 downto 0);
		Q_R     : out std_logic_vector(31 downto 0)
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

	component itype_decoder is
		port(
			I_INSTR  : in  std_logic_vector(6 downto 0);
			Q_TYPE   : out std_logic_vector(31 downto 0);
			Q_FORMAT : out std_logic_vector(5 downto 0)
		);
	end component itype_decoder;

	signal L_INSTR : std_logic_vector(31 downto 0) := X"00000000";
	signal L_C     : std_logic_vector(31 downto 0) := X"00000000";
	signal L_WBSEL : std_logic                     := '0';
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

	Q_R     <= L_C when L_WBSEL = '0' else X"00000000";
	Q_INSTR <= L_INSTR;
end architecture RTL;
