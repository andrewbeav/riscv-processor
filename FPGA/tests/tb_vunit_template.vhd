library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_template is
    generic (runner_cfg : string);
end entity;

architecture tb of tb_template is

    constant clk_period : time := 10 ns;
    constant simtime_in_clocks : integer := 10;

    signal simulator_clk : std_logic := '0';
    signal simulation_counter : integer range 0 to simtime_in_clocks := 0 ;

    --------------------------------------------------
    -- Simulation Signals
    --------------------------------------------------

begin

    main : process
    begin
        set_stop_level(failure);

        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clk_period;
        test_runner_cleanup(runner); -- Simulation ends here
    end process;

    simulator_clk <= not simulator_clk after clk_period / 2;

    process (simulator_clk)
    begin
        if rising_edge(simulator_clk) then
            simulation_counter <= simulation_counter + 1;
        end if;
    end process;

end architecture;