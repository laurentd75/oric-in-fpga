--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:02:15 22/08/2013
-- Design Name:
-- Module Name:
-- Project Name:  OricinFPGA
-- Target Device:
-- Tool versions:
-- Description:
-- 
-- VHDL Test Bench Created by ISE for module: ORIC
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library std;
	use std.textio.all;
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_textio.all;

entity simul_test is
end simul_test;
 
architecture behavior of simul_test is 

   --Inputs
   signal I_RESET    : std_logic := '0';
   signal PS2CLK1    : std_logic := '0';
   signal PS2DAT1    : std_logic := '0';
   signal CLK_50     : std_logic := '0';

	--BiDirs
--   signal AD         : std_logic_vector(17 downto 0);
--   signal D          : std_logic_vector( 7 downto 0);
--
 	--Outputs
--   signal OE_SRAMn   : std_logic;
--   signal WE_SRAMn   : std_logic;
--   signal CE_SRAMn   : std_logic;
--   signal UB_SRAMn   : std_logic;
--   signal LB_SRAMn   : std_logic;
--   signal RW         : std_logic;
	signal TMDS_P		: std_logic_vector(3 downto 0);
	signal TMDS_N		: std_logic_vector(3 downto 0);
--   signal O_VIDEO_R  : std_logic_vector(3 downto 0);
--   signal O_VIDEO_G  : std_logic_vector(3 downto 0);
--   signal O_VIDEO_B  : std_logic_vector(3 downto 0);
--   signal O_HSYNC    : std_logic;
--   signal O_VSYNC    : std_logic;
   signal VIDEO_SYNC : std_logic;
   signal AUDIO_OUT  : std_logic;

   -- Clock period definitions
   constant PS2CLK1_period : time := 40 us;
   constant CLK_50_period  : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: entity work.ORIC PORT MAP (
		I_RESET    => I_RESET,
		PS2CLK1    => PS2CLK1,
		PS2DAT1    => PS2DAT1,
		AUDIO_OUT  => AUDIO_OUT,
		TMDS_P     => TMDS_P,
		TMDS_N     => TMDS_N,
		K7_TAPEIN  => '0',
		K7_TAPEOUT => open,
--		O_VIDEO_R  => O_VIDEO_R,
--		O_VIDEO_G  => O_VIDEO_G,
--		O_VIDEO_B  => O_VIDEO_B,
--		VIDEO_SYNC => VIDEO_SYNC,
--		O_HSYNC    => O_HSYNC,
--		O_VSYNC    => O_VSYNC,
		CLK_50     => CLK_50
	);
		  
--	-- SRAM
--	ramv : entity work.sram
--	port map
--	(
--		A     => AD(15 downto 0),
--		nOE	=> OE_SRAMn,
--		nWE	=> WE_SRAMn,
--		nCE1	=> CE_SRAMn,
--		nUB1	=> '1',
--		nLB1	=> '0',
--		D     => D
--	);
	
	CLK_50_process :process
	begin
		CLK_50 <= '0';
		wait for CLK_50_period/2;
		CLK_50 <= '1';
		wait for CLK_50_period/2;
	end process;

	tb_RESET : process
	begin
		I_RESET <= '1';
		wait for CLK_50_period*16;
		I_RESET <= '0';		     
		wait;
	end process;
	
	-- Stimulus process
	tb_keyboard : process
		file file_in 		: text open read_mode is "../scenario.txt";
		variable line_in	: line;
		variable cmd		: character;
		variable delay		: time;
		variable char		: std_logic_vector(7 downto 0);
		variable ps2tx		: std_logic_vector(10 downto 0);
	begin

		loop                                   
			readline(file_in, line_in);           
			read(line_in, cmd);

			case cmd is

				-- Wait
				when 'W' =>
					read(line_in, delay);
					PS2CLK1 <= '1';
					PS2DAT1 <= '1';
					wait for delay;

				-- Key
				when 'K' =>
					hread(line_in, char);
					ps2tx := "10" & char & "0"; -- stop_bit + parity + byte + start_bit

					for i in 0 to 10 loop
						PS2DAT1 <= ps2tx(i);	-- LSB to MSB
						PS2CLK1 <= '0';
						wait for PS2CLK1_period;
						PS2CLK1 <= '1';
						wait for PS2CLK1_period;
					end loop;

				-- End
				when 'E' =>
					PS2CLK1 <= '1';
					PS2DAT1 <= 'Z';
					wait;

				when others => null;

			end case;
		end loop;

	end process;

end;
