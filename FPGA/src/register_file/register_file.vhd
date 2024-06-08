library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package register_file_pkg is
    constant data_width_bits : integer := 32;
    constant register_file_size : integer := 32;
    constant register_init_value : std_logic_vector(data_width_bits-1 downto 0) := (others => '1');
    type register_file_array is array (register_file_size-1 downto 0) of std_logic_vector(data_width_bits-1 downto 0);
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.register_file_pkg.all;

-- 32 x 32 register file, capable of 2 reads and 1 write per clock cycle
entity register_file is
    port (
        clk          : in std_logic;
        en           : in boolean;
        write_enable : in boolean;

        rd1_data, rd2_data : out std_logic_vector(data_width_bits-1 downto 0) := (others => '0');
        rd1_address, rd2_address, wr_address : in natural range 0 to register_file_size-1;
        wr_data : in std_logic_vector(data_width_bits-1 downto 0);

        data_written : out boolean := false
    );
end entity;

architecture rtl of register_file is
    -- initialize registers with all 1s
    signal registers : register_file_array := (others => (others => '1'));
begin
    process (clk)
    begin
        if rising_edge(clk) and en then
            -- write data if write_enable is active
            data_written <= false;
            if write_enable then
                registers(wr_address) <= wr_data;
                data_written <= true; -- pulse data_written high
            end if;

            -- reads
            rd1_data <= registers(rd1_address);
            rd2_data <= registers(rd2_address);

        end if;
    end process;
end architecture;