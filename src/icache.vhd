library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity icache is
	port(
		I_CLK   : in  std_logic;
		I_ADR   : in  std_logic_vector(31 downto 0);
		Q_INSTR : out std_logic_vector(31 downto 0)
	);
end entity icache;

-- TODO this will temporarily serve as source for instructions
-- will have to load them from ram at some point
architecture RTL of icache is
	type mem_t is array (0 to 2048) of std_logic_vector(31 downto 0);
	signal mem : mem_t := (
		0      => "00000000010100010000000100010011", -- ADDI x2, x2, 5
		1      => "00000000010100001000000010010011", -- ADDI x1, x1, 5
		2      => "00000000010100010000000100010011", -- ADDI x2, x2, 5
		3      => "00000000010100001000000010010011", -- ADDI x1, x1, 5
		4      => "00000000010100010000000100010011", -- ADDI x2, x2, 5
		5      => "00000000010100001000000010010011", -- ADDI x1, x1, 5
		6      => "00000000010100010000000100010011", -- ADDI x2, x2, 5
		7      => "00000000010100001000000010010011", -- ADDI x1, x1, 5
		8      => "00000000010100010000000100010011", -- ADDI x2, x2, 5
		9      => "10101011110011011110001010110111", -- LUI
		others => (others => '0')
	);

	signal L_DATA : std_logic_vector(31 downto 0) := X"00000000";
	signal L_IADR : integer;
	signal L_F    : std_logic                     := '0'; -- FIXME this is to evade some weird bug causing L_IADR to be INT32_MIN the very first simulation tick
begin
	L_IADR <= to_integer(unsigned(SHL(I_ADR(31 downto 2), "10"))) / 4;

	process(I_CLK)
	begin
		if (L_F = '1') then
			L_DATA <= mem(L_IADR);
		else
			L_F <= '1';
		end if;
	end process;

	Q_INSTR <= L_DATA;
end architecture RTL;
