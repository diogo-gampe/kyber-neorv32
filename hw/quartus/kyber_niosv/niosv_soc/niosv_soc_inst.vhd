	component niosv_soc is
		port (
			clock_bridge_1_in_clk_clk     : in std_logic := 'X'; -- clk
			reset_bridge_0_in_reset_reset : in std_logic := 'X'  -- reset
		);
	end component niosv_soc;

	u0 : component niosv_soc
		port map (
			clock_bridge_1_in_clk_clk     => CONNECTED_TO_clock_bridge_1_in_clk_clk,     --   clock_bridge_1_in_clk.clk
			reset_bridge_0_in_reset_reset => CONNECTED_TO_reset_bridge_0_in_reset_reset  -- reset_bridge_0_in_reset.reset
		);

