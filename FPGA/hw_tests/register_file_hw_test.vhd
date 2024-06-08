library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package register_file_hw_test_pkg is
    ------------------------------------------------------------------
    -- constants for register file manipulation --
    ------------------------------------------------------------------
    -- To write, user will:
        -- Send op_code in first byte
        -- Send address in second byte
        -- Send data to write in next 4 bytes
        -- FPGA will send uart_ack after write is complete
    constant write_op_code : std_logic_vector (7 downto 0) := x"01";
    constant uart_ack      : std_logic_vector (7 downto 0) := x"6B";

    -- To read, user will:
        -- Send op_code in first byte
        -- Send address in second byte
        -- FPGA will send data in next 4 bytes
        -- user sends uart_ack
    constant read_op_code  : std_logic_vector (7 downto 0) := x"02";
    
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.register_file_hw_test_pkg.all;

entity register_file_hw_test is
    port (
        clk   : in std_logic;

        rx : in std_logic;
        tx : out std_logic;

        leds : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of register_file_hw_test is

    -- register file signals
    signal write_enable : boolean := false;
    signal wr_data, rd1_data, rd2_data : std_logic_vector(31 downto 0) := (others => '0');
    signal wr_address, rd1_address, rd2_address : natural range 0 to 31 := 0;
    signal data_written : boolean := false;

    -- uart signals
    signal n_request_tx, n_request_tx_write_op, n_request_tx_read_op : std_logic := '1';
    signal tx_data_in, rx_data_out : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_data_in_read_op, tx_data_in_write_op : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_data_ready : std_logic;
    signal tx_sent : boolean;

    ------------------------------------------------------------------
    -- signals for register file manipulation --
    ------------------------------------------------------------------
    -- To write, user will:
        -- Send op_code in first byte
        -- Send address in second byte
        -- Send data to write in next 4 bytes
        -- FPGA will send uart_ack after write is complete
    type write_op_state_t is (IDLE, GET_ADDRESS, GET_DATA, WRITE_DATA, ACKNOWLEDGE);
    signal write_op_state : write_op_state_t := IDLE;
    signal read_data_byte_counter : natural range 0 to 4 := 0;
    signal write_data_buffer : std_logic_vector(31 downto 0) := (others => '0');

    -- To read, user will:
        -- Send op_code in first byte
        -- Send address in second byte
        -- FPGA will send data in next 4 bytes
        -- user sends uart_ack
    type read_op_state_t is (IDLE, GET_ADDRESS, READ_DATA, SEND_DATA, WAIT_FOR_ACK);
    signal read_op_state : read_op_state_t := IDLE;
    signal send_data_byte_counter : natural range 0 to 4 := 0;

    signal previous_rx_data_ready : boolean := false;
    signal previous_tx_sent : boolean := false;

    signal previous_rx_data_ready_write_op : boolean := false;

    signal write_ack_tx_requested : boolean := false;

    procedure pack_data_buffer (
        signal data_buffer : inout std_logic_vector(31 downto 0);
        idx : in natural range 0 to 3;
        byte : in std_logic_vector(7 downto 0)
    ) is
    begin
        case idx is
            when 0 => data_buffer(7 downto 0) <= byte;
            when 1 => data_buffer(15 downto 8) <= byte;
            when 2 => data_buffer(23 downto 16) <= byte;
            when 3 => data_buffer(31 downto 24) <= byte;
            when others => -- do nothing
        end case;
    end procedure;

begin

    display_rd1_data_on_leds : block
    begin
        leds <= rd1_data(15 downto 0);
    end block;

    read_op_fsm: process (clk)
    begin
        if rising_edge(clk) then
            case read_op_state is
                when IDLE =>
                    if rx_data_ready = '1' and rx_data_out = read_op_code then
                        read_op_state <= GET_ADDRESS;
                    end if;
                when GET_ADDRESS =>
                    if rx_data_ready = '1' and not previous_rx_data_ready then
                        rd1_address <= to_integer(unsigned(rx_data_out(4 downto 0)));
                        read_op_state <= READ_DATA;
                    end if;
                when READ_DATA =>
                    -- need to wait one clock cycle for valid read. If more are required include counter
                    read_op_state <= SEND_DATA;
                when SEND_DATA =>
                    if (tx_sent and not previous_tx_sent) or send_data_byte_counter = 0 then
                        if send_data_byte_counter >= 4 then
                            read_op_state <= WAIT_FOR_ACK;
                            send_data_byte_counter <= 0;
                        else
                            -- with send_data_byte_counter select
                            --     tx_data_in_read_op <= rd1_data(7 downto 0) when 0,
                            --         rd1_data(15 downto 8) when 1,
                            --         rd1_data(23 downto 16) when 2,
                            --         rd1_data(31 downto 24) when others; -- 3

                            case send_data_byte_counter is
                                when 0 => tx_data_in_read_op <= rd1_data(7 downto 0);
                                when 1 => tx_data_in_read_op <= rd1_data(15 downto 8);
                                when 2 => tx_data_in_read_op <= rd1_data(23 downto 16);
                                when others => tx_data_in_read_op <= rd1_data(31 downto 24);
                            end case;

                            n_request_tx_read_op <= '0';
                            send_data_byte_counter <= send_data_byte_counter + 1;
                        end if;
                    else
                        n_request_tx_read_op <= '1';
                    end if;
                when WAIT_FOR_ACK =>
                    if rx_data_ready = '1' and rx_data_out = uart_ack then
                        tx_data_in_read_op <= (others => '0');
                        read_op_state <= IDLE;
                    end if;
                when others => -- do nothing
            end case;

            previous_rx_data_ready <= rx_data_ready = '1';
            previous_tx_sent <= tx_sent;
        end if;
    end process;

    write_op_fsm: process (clk)
    begin
        if rising_edge(clk) then
            case write_op_state is
                when IDLE =>
                    if rx_data_ready = '1' and rx_data_out = write_op_code then
                        write_op_state <= GET_ADDRESS;
                    end if;
                when GET_ADDRESS =>
                    if rx_data_ready = '1' and not previous_rx_data_ready_write_op then
                        wr_address <= to_integer(unsigned(rx_data_out));
                        write_op_state <= GET_DATA;
                    end if;
                when GET_DATA =>
                    if rx_data_ready = '1' and not previous_rx_data_ready_write_op then
                        pack_data_buffer(write_data_buffer, read_data_byte_counter, rx_data_out);
                        if read_data_byte_counter >= 3 then
                            read_data_byte_counter <= 0;
                            write_op_state <= WRITE_DATA;
                        else
                            read_data_byte_counter <= read_data_byte_counter + 1;
                        end if;
                    end if;
                when WRITE_DATA =>
                    write_enable <= true;
                    wr_data <= write_data_buffer;
                    if data_written then
                        write_enable <= false;
                        write_op_state <= ACKNOWLEDGE;
                    end if;
                when ACKNOWLEDGE =>
                    if not write_ack_tx_requested then
                        n_request_tx_write_op <= '0';
                        tx_data_in_write_op <= uart_ack;
                        write_ack_tx_requested <= true;
                    else
                        n_request_tx_write_op <= '1';
                    end if;
                    
                    if tx_sent then
                        write_ack_tx_requested <= false;
                        tx_data_in_write_op <= (others => '0');
                        write_op_state <= IDLE;
                    end if;

                when others => -- do nothing
            end case;
            
            previous_rx_data_ready_write_op <= rx_data_ready = '1';
        end if;
    end process;

    register_file_inst: entity work.register_file
    port map(
        clk => clk,
        en => true,
        write_enable => write_enable,
        rd1_data => rd1_data,
        rd2_data => rd2_data,
        rd1_address => rd1_address,
        rd2_address => rd2_address,
        wr_address => wr_address,
        wr_data => wr_data,
        data_written =>  data_written
    );

    n_request_tx <= n_request_tx_read_op and n_request_tx_write_op;
    tx_data_in <= tx_data_in_read_op or tx_data_in_write_op;
    uart_tx_inst: entity work.uart_tx
    generic map (
        baud => 500000
    )
    port map(
        clk => clk,
        reset => '0',
        tx_data_in => tx_data_in,
        n_request_tx => n_request_tx,
        tx_sent => tx_sent,
        tx => tx
    );

    uart_rx_inst: entity work.uart_rx
    generic map (
        baud => 500000
    )
    port map(
        clk => clk,
        reset => '0',
        rx => rx,
        rx_data_out => rx_data_out,
        rx_data_ready => rx_data_ready
    );

end architecture;