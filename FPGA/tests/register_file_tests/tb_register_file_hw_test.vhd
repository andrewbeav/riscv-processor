library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.register_file_hw_test_pkg.all;

entity tb_register_file_hw_test is
    generic (runner_cfg : string);
end entity;

architecture tb of tb_register_file_hw_test is

    constant clk_period : time := 10 ns;
    signal simulation_ended : boolean := false;

    signal simulator_clk : std_logic := '0';
    signal simulation_counter : integer := 0 ;

    --------------------------------------------------
    -- Simulation Signals
    --------------------------------------------------
    signal rx_to_test, tx_from_test : std_logic := '1';

    constant data_to_write : std_logic_vector(31 downto 0) := x"EBAD69F3";

    signal read_data : std_logic_vector(31 downto 0) := (others => '0');

begin

    main : process
    begin
        set_stop_level(failure);

        test_runner_setup(runner, runner_cfg);
        wait until simulation_ended;
        test_runner_cleanup(runner); -- Simulation ends here
    end process;

    simulator_clk <= not simulator_clk after clk_period / 2;

    process (simulator_clk)
    begin
        if rising_edge(simulator_clk) then
            simulation_counter <= simulation_counter + 1;

            case simulation_counter is
                when 0 => tx_from_test <= '0';
                when 200 => tx_from_test <= write_op_code(0);
                when 400 => tx_from_test <= write_op_code(1);
                when 600 => tx_from_test <= write_op_code(2);
                when 800 => tx_from_test <= write_op_code(3);
                when 1000 => tx_from_test <= write_op_code(4);
                when 1200 => tx_from_test <= write_op_code(5);
                when 1400 => tx_from_test <= write_op_code(6);
                when 1600 => tx_from_test <= write_op_code(7);
                when 1800 => tx_from_test <= '1';

                when 2000 => tx_from_test <= '0';
                when 2200 => tx_from_test <= '1';
                when 2400 => tx_from_test <= '1';
                when 2600 => tx_from_test <= '0';
                when 2800 => tx_from_test <= '0';
                when 3000 => tx_from_test <= '1';
                when 3200 => tx_from_test <= '0';
                when 3400 => tx_from_test <= '0';
                when 3600 => tx_from_test <= '0';
                when 3800 => tx_from_test <= '1';

                when 4000 => tx_from_test <= '0';
                when 4200 => tx_from_test <= data_to_write(0);
                when 4400 => tx_from_test <= data_to_write(1);
                when 4600 => tx_from_test <= data_to_write(2);
                when 4800 => tx_from_test <= data_to_write(3);
                when 5000 => tx_from_test <= data_to_write(4);
                when 5200 => tx_from_test <= data_to_write(5);
                when 5400 => tx_from_test <= data_to_write(6);
                when 5600 => tx_from_test <= data_to_write(7);
                when 5800 => tx_from_test <= '1';

                when 6000 => tx_from_test <= '0';
                when 6200 => tx_from_test <= data_to_write(8);
                when 6400 => tx_from_test <= data_to_write(9);
                when 6600 => tx_from_test <= data_to_write(10);
                when 6800 => tx_from_test <= data_to_write(11);
                when 7000 => tx_from_test <= data_to_write(12);
                when 7200 => tx_from_test <= data_to_write(13);
                when 7400 => tx_from_test <= data_to_write(14);
                when 7600 => tx_from_test <= data_to_write(15);
                when 7800 => tx_from_test <= '1';

                when 8000 => tx_from_test <= '0';
                when 8200 => tx_from_test <= data_to_write(16);
                when 8400 => tx_from_test <= data_to_write(17);
                when 8600 => tx_from_test <= data_to_write(18);
                when 8800 => tx_from_test <= data_to_write(19);
                when 9000 => tx_from_test <= data_to_write(20);
                when 9200 => tx_from_test <= data_to_write(21);
                when 9400 => tx_from_test <= data_to_write(22);
                when 9600 => tx_from_test <= data_to_write(23);
                when 9800 => tx_from_test <= '1';

                when 10000 => tx_from_test <= '0';
                when 10200 => tx_from_test <= data_to_write(24);
                when 10400 => tx_from_test <= data_to_write(25);
                when 10600 => tx_from_test <= data_to_write(26);
                when 10800 => tx_from_test <= data_to_write(27);
                when 11000 => tx_from_test <= data_to_write(28);
                when 11200 => tx_from_test <= data_to_write(29);
                when 11400 => tx_from_test <= data_to_write(30);
                when 11600 => tx_from_test <= data_to_write(31);
                when 11800 => tx_from_test <= '1';

                when 12000 => tx_from_test <= '0';
                when 12000 + 200 => tx_from_test <= read_op_code(0);
                when 12000 + 400 => tx_from_test <= read_op_code(1);
                when 12000 + 600 => tx_from_test <= read_op_code(2);
                when 12000 + 800 => tx_from_test <= read_op_code(3);
                when 12000 + 1000 => tx_from_test <= read_op_code(4);
                when 12000 + 1200 => tx_from_test <= read_op_code(5);
                when 12000 + 1400 => tx_from_test <= read_op_code(6);
                when 12000 + 1600 => tx_from_test <= read_op_code(7);
                when 12000 + 1800 => tx_from_test <= '1';

                when 12000 + 2000 => tx_from_test <= '0';
                when 12000 + 2200 => tx_from_test <= '1';
                when 12000 + 2400 => tx_from_test <= '1';
                when 12000 + 2600 => tx_from_test <= '0';
                when 12000 + 2800 => tx_from_test <= '0';
                when 12000 + 3000 => tx_from_test <= '1';
                when 12000 + 3200 => tx_from_test <= '0';
                when 12000 + 3400 => tx_from_test <= '0';
                when 12000 + 3600 => tx_from_test <= '0';
                when 12000 + 3800 => tx_from_test <= '1';

                when 16000 => --receive start bit
                when 16000 + 200 => read_data(0) <= rx_to_test;
                when 16000 + 400 => read_data(1) <= rx_to_test;
                when 16000 + 600 => read_data(2) <= rx_to_test;
                when 16000 + 800 => read_data(3) <= rx_to_test;
                when 16000 + 1000 => read_data(4) <= rx_to_test;
                when 16000 + 1200 => read_data(5) <= rx_to_test;
                when 16000 + 1400 => read_data(6) <= rx_to_test;
                when 16000 + 1600 => read_data(7) <= rx_to_test;
                when 16000 + 1800 => -- receive stop bit

                when 18000 => --receive start bit
                when 18000 + 200 => read_data(8) <= rx_to_test;
                when 18000 + 400 => read_data(9) <= rx_to_test;
                when 18000 + 600 => read_data(10) <= rx_to_test;
                when 18000 + 800 => read_data(11) <= rx_to_test;
                when 18000 + 1000 => read_data(12) <= rx_to_test;
                when 18000 + 1200 => read_data(13) <= rx_to_test;
                when 18000 + 1400 => read_data(14) <= rx_to_test;
                when 18000 + 1600 => read_data(15) <= rx_to_test;
                when 18000 + 1800 => -- receive stop bit

                when 20000 => --receive start bit
                when 20000 + 200 => read_data(16) <= rx_to_test;
                when 20000 + 400 => read_data(17) <= rx_to_test;
                when 20000 + 600 => read_data(18) <= rx_to_test;
                when 20000 + 800 => read_data(19) <= rx_to_test;
                when 20000 + 1000 => read_data(20) <= rx_to_test;
                when 20000 + 1200 => read_data(21) <= rx_to_test;
                when 20000 + 1400 => read_data(22) <= rx_to_test;
                when 20000 + 1600 => read_data(23) <= rx_to_test;
                when 20000 + 1800 => -- receive stop bit

                when 22000 => --receive start bit
                when 22000 + 200 => read_data(24) <= rx_to_test;
                when 22000 + 400 => read_data(25) <= rx_to_test;
                when 22000 + 600 => read_data(26) <= rx_to_test;
                when 22000 + 800 => read_data(27) <= rx_to_test;
                when 22000 + 1000 => read_data(28) <= rx_to_test;
                when 22000 + 1200 => read_data(29) <= rx_to_test;
                when 22000 + 1400 => read_data(30) <= rx_to_test;
                when 22000 + 1600 => read_data(31) <= rx_to_test;
                when 22000 + 1800 => -- receive stop bit

                when 24000 => tx_from_test <= '0';
                when 24000 + 200 => tx_from_test <= uart_ack(0);
                when 24000 + 400 => tx_from_test <= uart_ack(1);
                when 24000 + 600 => tx_from_test <= uart_ack(2);
                when 24000 + 800 => tx_from_test <= uart_ack(3);
                when 24000 + 1000 => tx_from_test <= uart_ack(4);
                when 24000 + 1200 => tx_from_test <= uart_ack(5);
                when 24000 + 1400 => tx_from_test <= uart_ack(6);
                when 24000 + 1600 => tx_from_test <= uart_ack(7);
                when 24000 + 1800 => tx_from_test <= '1';

                when 28000 => check(data_to_write = read_data, "data does not match");
            
                when 30000 => simulation_ended <= true;
                when others => -- do nothing
            end case;
        end if;
    end process;

    register_file_hw_test_inst: entity work.register_file_hw_test
    port map(
        clk => simulator_clk,
        rx => tx_from_test,
        tx => rx_to_test
    );

end architecture;