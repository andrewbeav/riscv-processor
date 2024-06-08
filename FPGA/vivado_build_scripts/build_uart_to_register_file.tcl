package require fileutil

proc compile {top pjt_name sources {part "xc7a100t-csg324-3"} } {
    puts "Closing any designs that are currently open..."
    puts ""
    close_project -quiet
    puts "Continuing..."

    # Create design for specific part
    link_design -part $part

    puts "reading vhdl files..."
    foreach file $sources {
        puts "  Reading $file..."
        read_vhdl $file
    }

    puts "Synthesizing design..."
    synth_design -top $top -flatten_hierarchy full 

    puts "Reading in XDC constraint file..."
    read_xdc {../constraints/constraints.xdc}

    # You will get DRC errors without the next two lineswhen you
    # generate a bitstream.
    set_property CFGBVS VCCO [current_design]
    set_property CONFIG_VOLTAGE 3.3 [current_design]

    # If you don't need an .xdc for pinouts (just generating designs for analysis),
    # you can include the next line to avoid errors about unconstrained pins.
    #set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]

    puts "Placing design..."
    place_design

    puts "Routing design..."
    route_design

    puts "Writing checkpoint"
    write_checkpoint -force {../checkpoints/$top.dcp}

    puts "Writing bitstream"
    write_bitstream -force -bin_file "../bin/$pjt_name.bit"

    puts "Finished"
}

proc program_ram {pjt_name {device "xc7a100t_0"}} {
    puts "Establishing connection to hardware..."
    open_hw_manager
    connect_hw_server -allow_non_jtag
    open_hw_target
    open_hw_target
    current_hw_device [get_hw_devices $device]
    refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $device] 0] 

    puts "Connected to hardware. Programming..."
    set_property PROBES.FILE {} [get_hw_devices $device]
    set_property FULL_PROBES.FILE {} [get_hw_devices $device]
    set_property PROGRAM.FILE "../bin/$pjt_name.bit" [get_hw_devices $device]
    program_hw_devices [get_hw_devices $device]
    refresh_hw_device [lindex [get_hw_devices $device] 0]
    puts "Should be Programmed"
}

proc compile_uart_to_register_file {} {
    set vhdl_sources { \
        {../hw_tests/register_file_hw_test.vhd} \
        {../src/uart/src/uart_pkg.vhd} \
        {../src/uart/src/uart_rx.vhd} \
        {../src/uart/src/uart_tx.vhd} \
        {../src/register_file/register_file.vhd} \
    }
    compile register_file_hw_test uart_to_register_file $vhdl_sources
}

proc program_uart_to_register_file_to_artix7 {} {
    program_ram uart_to_register_file
}