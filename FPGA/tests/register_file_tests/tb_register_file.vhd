library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.register_file_pkg.all;

entity tb_register_file is
    generic (runner_cfg : string);
end entity;

architecture tb of tb_register_file is

    constant clk_period : time := 10 ns;
    signal simulation_is_finished : boolean := false;

    signal simulator_clk : std_logic := '0';
    signal simulation_counter : integer := 0 ;

    --------------------------------------------------
    -- Simulation Signals
    --------------------------------------------------
    signal en, write_enable : boolean := false;
    constant tb_data_init_value : std_logic_vector(data_width_bits-1 downto 0) := (others => '0');
    signal rd1_data, rd2_data, wr_data : std_logic_vector(data_width_bits-1 downto 0) := tb_data_init_value;
    signal rd1_address, rd2_address, wr_address : natural range 0 to register_file_size-1 := 0;

    -- simulation flow signals
    signal start_initialized_test : boolean := false;
    signal do_write_test : boolean := false;
    constant max_write_data : unsigned(register_file_size-1 downto 0) := to_unsigned(100000, register_file_size);
    signal test_write_data : unsigned(register_file_size-1 downto 0):= (others => '0') ;
    type write_test_state_t is (WRITE_DATA, WAIT_FOR_WRITE_VALID, READ_DATA, CHECK_READ);
    signal write_test_state : write_test_state_t := WRITE_DATA;
        

begin

    main : process
    begin
        set_stop_level(failure);

        test_runner_setup(runner, runner_cfg);
        wait until simulation_is_finished;
        test_runner_cleanup(runner); -- Simulation ends here
    end process;

    simulator_clk <= not simulator_clk after clk_period / 2;

    process (simulator_clk)
    begin
        if rising_edge(simulator_clk) then
            simulation_counter <= simulation_counter + 1;

            case simulation_counter is

                when 5 =>
                    check(
                        rd1_data = tb_data_init_value,
                        "rd1_data read before enable"
                    );
                    check(
                        rd2_data = tb_data_init_value,
                        "rd2_data read before enable"
                    );

                when 10 => en <= true;
                when 11 =>
                    start_initialized_test <= true;
                    rd1_address <= 1;
                    rd2_address <= 1;

                -- when 20 => simulation_is_finished <= true;

                when others =>

            end case;

            if start_initialized_test then
                if rd1_address >= register_file_size-1 then
                    start_initialized_test <= false;
                    do_write_test <= true;
                    -- simulation_is_finished <= true;
                    rd1_address <= 0;
                    rd2_address <= 0;
                else
                    rd1_address <= rd1_address + 1;
                    rd2_address <= rd2_address + 1;

                    check(
                        rd1_data = register_init_value,
                        "rd1_data at address " & integer'image(rd1_address) & " not initialized"
                    );
                    check(
                        rd2_data = register_init_value,
                        "rd2_data at address " & integer'image(rd2_address) & " not initialized"
                    );
                end if;
            end if;

            if do_write_test then
                case write_test_state is
                    when WRITE_DATA =>
                    if test_write_data >= max_write_data then -- are we at last data for this address?
                        if wr_address >= register_file_size-1 then -- end of test
                            rd1_address <= 0;
                            rd2_address <= 0;
                            wr_address  <= 0;
                            simulation_is_finished <= true;
                        else -- start test over at next address
                            rd1_address <= rd1_address + 1;
                            rd2_address <= rd2_address + 1;
                            wr_address  <= wr_address + 1;
                            test_write_data <= (others => '0') ;
                        end if;
                    else -- stay at same address for reads and writes, increment data
                        test_write_data <= test_write_data + 1;
                        write_enable <= true;
                        wr_data <= std_logic_vector(test_write_data);
                        write_test_state <= WAIT_FOR_WRITE_VALID;
                    end if;
                        
                    when WAIT_FOR_WRITE_VALID => -- wait 1 clock cycle for data write operation
                        write_enable <= false;
                        write_test_state <= READ_DATA;
                    when READ_DATA => -- wait for rd_data to take affect
                        write_test_state <= CHECK_READ;
                    when others => -- CHECK_READ
                        check(
                            rd1_data = wr_data,
                            "rd1_data not valid after write at address " & integer'image(rd1_address) &
                                " : Expected = " & natural'image(to_integer(unsigned(wr_data))) & 
                                ", Actual = " & natural'image(to_integer(unsigned(rd1_data)))
                        );
                        check(
                            rd2_data = wr_data,
                            "rd2_data not valid after write at address " & integer'image(rd2_address) &
                                " : Expected = " & natural'image(to_integer(unsigned(wr_data))) & 
                                ", Actual = " & natural'image(to_integer(unsigned(rd2_data)))
                        );
                        write_test_state <= WRITE_DATA;
                end case;
            end if;



        end if;
    end process;

    u_register_file_inst: entity work.register_file
     port map(
        clk => simulator_clk,
        en => en,
        write_enable => write_enable,
        rd1_data => rd1_data,
        rd2_data => rd2_data,
        rd1_address => rd1_address,
        rd2_address => rd2_address,
        wr_address => wr_address,
        wr_data => wr_data
    );

end architecture;