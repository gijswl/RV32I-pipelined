library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity cpu_core is
	port(
		I_CLK : in std_logic
	);
end entity cpu_core;

architecture RTL of cpu_core is
	component instr_fetch is
		port(
			I_CLK   : in  std_logic;
			I_STALL : in  std_logic;
			I_PCSRC : in  std_logic_vector(1 downto 0);
			I_BR    : in  std_logic_vector(31 downto 0);
			Q_INSTR : out std_logic_vector(31 downto 0);
			Q_PC    : out std_logic_vector(31 downto 0)
		);
	end component instr_fetch;

	component instr_decode is
		port(
			I_CLK   : in  std_logic;
			I_STALL : in  std_logic;
			I_KILL  : in  std_logic;
			I_RW    : in  std_logic;
			I_RA    : in  std_logic_vector(4 downto 0);
			I_RD    : in  std_logic_vector(31 downto 0);
			I_PC    : in  std_logic_vector(31 downto 0);
			I_INSTR : in  std_logic_vector(31 downto 0);
			Q_PC    : out std_logic_vector(31 downto 0);
			Q_CS    : out std_logic_vector(31 downto 0);
			Q_A     : out std_logic_vector(31 downto 0);
			Q_B     : out std_logic_vector(31 downto 0)
		);
	end component instr_decode;

	component execute is
		port(
			I_CLK  : in  std_logic;
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
	end component execute;

	component memory is
		port(
			I_CLK : in  std_logic;
			I_C   : in  std_logic_vector(31 downto 0);
			I_CS  : in  std_logic_vector(31 downto 0);
			Q_CS  : out std_logic_vector(31 downto 0);
			Q_R   : out std_logic_vector(31 downto 0)
		);
	end component memory;

	component writeback is
		port(
			I_CLK : in  std_logic;
			I_R   : in  std_logic_vector(31 downto 0);
			I_CS  : in  std_logic_vector(31 downto 0);
			Q_RD  : out std_logic_vector(31 downto 0);
			Q_RW  : out std_logic;
			Q_RA  : out std_logic_vector(4 downto 0)
		);
	end component writeback;

	signal L_INSTR_IF : std_logic_vector(31 downto 0) := X"00000000";
	signal ID_CS      : std_logic_vector(31 downto 0) := X"00000000";
	signal ID_CS_BUF  : std_logic_vector(31 downto 0) := X"00000000";
	signal EX_CS      : std_logic_vector(31 downto 0) := X"00000000";
	signal MA_CS      : std_logic_vector(31 downto 0) := X"00000000";

	signal IF_PC : std_logic_vector(31 downto 0) := X"00000000";
	signal ID_PC : std_logic_vector(31 downto 0) := X"00000000";

	signal L_A : std_logic_vector(31 downto 0) := X"00000000";
	signal L_B : std_logic_vector(31 downto 0) := X"00000000";
	signal L_C : std_logic_vector(31 downto 0) := X"00000000";

	signal L_R  : std_logic_vector(31 downto 0) := X"00000000";
	signal L_RD : std_logic_vector(31 downto 0) := X"00000000";
	signal L_RA : std_logic_vector(4 downto 0)  := "00000";
	signal L_RW : std_logic                     := '0';

	signal C_FW_A : std_logic_vector(1 downto 0) := "00";
	signal C_FW_B : std_logic_vector(1 downto 0) := "00";

	signal C_STALL : std_logic := '0';

	signal C_BT       : std_logic                     := '0';
	signal C_PCSRC    : std_logic_vector(1 downto 0)  := "00";
	signal C_BRTARGET : std_logic_vector(31 downto 0) := X"00000000";
begin
	process(I_CLK)
	begin
		if (rising_edge(I_CLK)) then
			ID_CS_BUF <= ID_CS;
		end if;
	end process;

	if_stage : instr_fetch
		port map(
			I_CLK   => I_CLK,
			I_STALL => C_STALL,
			I_PCSRC => C_PCSRC,
			I_BR    => C_BRTARGET,
			Q_INSTR => L_INSTR_IF,
			Q_PC    => ID_PC
		);

	id_stage : instr_decode
		port map(
			I_CLK   => I_CLK,
			I_STALL => C_STALL,
			I_KILL  => C_BT,
			I_RW    => L_RW,
			I_RA    => L_RA,
			I_RD    => L_RD,
			I_PC    => IF_PC,
			I_INSTR => L_INSTR_IF,
			Q_PC    => ID_PC,
			Q_CS    => ID_CS,
			Q_A     => L_A,
			Q_B     => L_B
		);

	ex_stage : execute
		port map(
			I_CLK  => I_CLK,
			I_FW_A => C_FW_A,
			I_FW_B => C_FW_B,
			I_A    => L_A,
			I_B    => L_B,
			I_FW_M => L_R,
			I_CS   => ID_CS,
			Q_CS   => EX_CS,
			Q_C    => L_C,
			Q_BT   => C_BT
		);

	ma_stage : memory
		port map(
			I_CLK => I_CLK,
			I_C   => L_C,
			I_CS  => EX_CS,
			Q_CS  => MA_CS,
			Q_R   => L_R
		);

	wb_stage : writeback
		port map(
			I_CLK => I_CLK,
			I_R   => L_R,
			I_CS  => MA_CS,
			Q_RD  => L_RD,
			Q_RW  => L_RW,
			Q_RA  => L_RA
		);

	-- TODO will probably need to stall again at some point
	C_STALL <= '0';                     -- '1' when (
	-- ((((ID_CS_BUF(4 downto 0) = EX_CS(14 downto 10)) and EX_CS(22) = '1') or ((ID_CS_BUF(4 downto 0) = MA_CS(14 downto 10)) and MA_CS(22) = '1')) and ID_CS_BUF(20) = '1') --
	-- or ((((ID_CS_BUF(9 downto 5) = EX_CS(14 downto 10)) and EX_CS(22) = '1') or ((ID_CS_BUF(9 downto 5) = MA_CS(14 downto 10)) and MA_CS(22) = '1')) and ID_CS_BUF(21) = '1') --
	-- ) else '0';

	C_FW_A <= "01" when (
			((ID_CS(4 downto 0) = EX_CS(14 downto 10)) and EX_CS(22) = '1' and ID_CS(20) = '1')
		)
		else "10" when (
			((ID_CS(4 downto 0) = MA_CS(14 downto 10)) and MA_CS(22) = '1' and ID_CS(20) = '1')
		)
		else "00";

	C_PCSRC <= "01" when C_BT = '1' else "00";
end architecture RTL;
