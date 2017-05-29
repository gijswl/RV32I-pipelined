library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_decode is
	port(
		I_CLK   : in  std_logic;
		I_RW    : in  std_logic;
		I_RA    : in  std_logic_vector(4 downto 0);
		I_RD    : in  std_logic_vector(31 downto 0);
		I_INSTR : in  std_logic_vector(31 downto 0);
		Q_INSTR : out std_logic_vector(31 downto 0);
		Q_A     : out std_logic_vector(31 downto 0);
		Q_B     : out std_logic_vector(31 downto 0)
	);
end entity instr_decode;

architecture RTL of instr_decode is
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

	component registerfile is
		port(
			I_CLK : in  std_logic;
			I_WE  : in  std_logic;
			I_RS1 : in  std_logic_vector(4 downto 0);
			I_RS2 : in  std_logic_vector(4 downto 0);
			I_WA  : in  std_logic_vector(4 downto 0);
			I_WD  : in  std_logic_vector(31 downto 0);
			Q_RD1 : out std_logic_vector(31 downto 0);
			Q_RD2 : out std_logic_vector(31 downto 0)
		);
	end component registerfile;

	component itype_decoder is
		port(
			I_INSTR  : in  std_logic_vector(6 downto 0);
			Q_TYPE   : out std_logic_vector(31 downto 0);
			Q_FORMAT : out std_logic_vector(5 downto 0)
		);
	end component itype_decoder;

	signal L_INSTR  : std_logic_vector(31 downto 0) := X"00000000";
	signal L_TYPE   : std_logic_vector(31 downto 0) := X"00000000";
	signal L_FORMAT : std_logic_vector(5 downto 0)  := "000000";
	signal L_RD1    : std_logic_vector(31 downto 0) := X"00000000";
	signal L_RD2    : std_logic_vector(31 downto 0) := X"00000000";
	signal L_IMM    : std_logic_vector(31 downto 0) := X"00000000";
	signal L_IMMSEL : std_logic                     := '0';
	signal L_OPSEL  : std_logic                     := '0';
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

	rf : registerfile
		port map(
			I_CLK => I_CLK,
			I_WE  => I_RW,
			I_RS1 => L_INSTR(19 downto 15),
			I_RS2 => L_INSTR(24 downto 20),
			I_WA  => I_RA,
			I_WD  => I_RD,
			Q_RD1 => L_RD1,
			Q_RD2 => L_RD2
		);

	type_decoder : itype_decoder
		port map(
			I_INSTR  => L_INSTR(6 downto 0),
			Q_TYPE   => L_TYPE,
			Q_FORMAT => L_FORMAT
		);

	with L_FORMAT select L_IMM <=
		((20 downto 0 => L_INSTR(31)) & L_INSTR(30 downto 25) & L_INSTR(24 downto 21) & L_INSTR(20)) when "000010",
		((20 downto 0 => L_INSTR(31)) & L_INSTR(30 downto 25) & L_INSTR(11 downto 8) & L_INSTR(7)) when "000100", --
		((19 downto 0 => L_INSTR(31)) & L_INSTR(7) & L_INSTR(30 downto 25) & L_INSTR(11 downto 8) & '0') when "001000", --
		(L_INSTR(31) & L_INSTR(30 downto 20) & L_INSTR(19 downto 12) & (11 downto 0 => '0')) when "010000", --
		((11 downto 0 => L_INSTR(31)) & L_INSTR(19 downto 12) & L_INSTR(20) & L_INSTR(31 downto 25) & L_INSTR(24 downto 21)) when "100000",
		X"00000000" when others;

	L_OPSEL  <= L_TYPE(4) or L_TYPE(5) or L_TYPE(13);
	L_IMMSEL <= L_OPSEL;

	Q_A     <= L_RD1;
	Q_B     <= L_IMM when L_IMMSEL = '1' and L_OPSEL = '1'
		else L_RD2 when L_OPSEL = '0'
		else X"00000000";
	Q_INSTR <= L_INSTR;
end architecture RTL;