library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity writeback is
	port(
		I_CLK   : in  std_logic;
		I_R     : in  std_logic_vector(31 downto 0);
		I_INSTR : in  std_logic_vector(31 downto 0);
		Q_RD    : out std_logic_vector(31 downto 0);
		Q_RW    : out std_logic;
		Q_RA    : out std_logic_vector(4 downto 0)
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

	component itype_decoder is
		port(
			I_INSTR  : in  std_logic_vector(6 downto 0);
			Q_TYPE   : out std_logic_vector(31 downto 0);
			Q_FORMAT : out std_logic_vector(5 downto 0)
		);
	end component itype_decoder;

	signal L_INSTR : std_logic_vector(31 downto 0) := X"00000000";
	signal L_R     : std_logic_vector(31 downto 0) := X"00000000";

	signal L_TYPE : std_logic_vector(31 downto 0) := X"00000000";
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

	type_decoder : itype_decoder
		port map(
			I_INSTR => L_INSTR(6 downto 0),
			Q_TYPE  => L_TYPE
		);

	Q_RW <= L_TYPE(4) or L_TYPE(5) or L_TYPE(12) or L_TYPE(13);
	Q_RD <= L_R;
	Q_RA <= L_INSTR(11 downto 7);
end architecture RTL;
