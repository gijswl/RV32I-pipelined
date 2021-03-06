library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity instr_fetch is
	port(
		I_CLK   : in  std_logic;
		I_STALL : in  std_logic;
		I_KILL  : in  std_logic;
		I_PCSRC : in  std_logic_vector(1 downto 0);
		I_BR    : in  std_logic_vector(31 downto 0);
		I_JD    : in  std_logic_vector(31 downto 0);
		I_JI    : in  std_logic_vector(31 downto 0);
		Q_INSTR : out std_logic_vector(31 downto 0);
		Q_PC    : out std_logic_vector(31 downto 0)
	);
end entity instr_fetch;

architecture RTL of instr_fetch is
	component icache is
		port(
			I_CLK   : in  std_logic;
			I_ADR   : in  std_logic_vector(31 downto 0);
			Q_INSTR : out std_logic_vector(31 downto 0)
		);
	end component icache;

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

	signal L_PC     : std_logic_vector(31 downto 0) := X"00000000";
	signal L_PC_4   : std_logic_vector(31 downto 0) := X"00000000";
	signal L_NEXTPC : std_logic_vector(31 downto 0) := X"00000000";

	signal L_INSTR : std_logic_vector(31 downto 0) := X"00000000";

	signal L_WPC : std_logic := '0';
begin
	pc : reg
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => L_NEXTPC,
			I_W   => L_WPC,
			Q_D   => L_PC
		);

	instr_cache : icache
		port map(
			I_CLK   => I_CLK,
			I_ADR   => L_PC,
			Q_INSTR => L_INSTR
		);

	L_WPC    <= not I_STALL;
	L_PC_4   <= L_PC + "100";
	L_NEXTPC <= L_PC_4 when I_PCSRC = "00"
		else I_BR when I_PCSRC = "01"
		else I_JD when I_PCSRC = "10"
		else I_JI when I_PCSRC = "11"
	;

	Q_PC    <= L_PC;
	Q_INSTR <= L_INSTR when I_KILL = '0' else X"00000000";
end architecture RTL;
