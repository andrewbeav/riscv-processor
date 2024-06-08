from vunit import VUnit

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()

# Optionally add VUnit's builtin HDL utilities for checking, logging, communication...
# See http://vunit.github.io/hdl_libraries.html.
vu.add_vhdl_builtins()
# or
# vu.add_verilog_builtins()

register_file_testing = vu.add_library("register_file_testing")
register_file_testing.add_source_files("src/register_file/register_file.vhd")
register_file_testing.add_source_files("tests/register_file_tests/tb_register_file.vhd")
register_file_testing.add_source_files("src/uart/src/uart_pkg.vhd")
register_file_testing.add_source_files("src/uart/src/uart_rx.vhd")
register_file_testing.add_source_files("src/uart/src/uart_tx.vhd")
register_file_testing.add_source_files("hw_tests/register_file_hw_test.vhd")
register_file_testing.add_source_files("tests/register_file_tests/tb_register_file_hw_test.vhd")

# Run vunit function
vu.main()