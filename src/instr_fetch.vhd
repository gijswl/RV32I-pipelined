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
		Q_INSTR : out std_logic_vector(31 downto 0)
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

	signal L_PC   : std_logic_vector(31 downto 0) := X"00000004";
	signal L_PC_4 : std_logic_vector(31 downto 0) := X"00000000";

	signal L_WPC : std_logic := '0';
begin
	pc : reg
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => L_PC_4,
			I_W   => L_WPC,
			Q_D   => L_PC
		);

	instr_cache : icache
		port map(
			I_CLK   => I_CLK,
			I_ADR   => L_PC,
			Q_INSTR => Q_INSTR
		);

	L_WPC  <= not I_STALL;
	L_PC_4 <= L_PC + "100";
end architecture RTL;
