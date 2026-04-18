# Clock signal (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
    set_property IOSTANDARD LVCMOS33 [get_ports clk]
    create_clock -add -name clk -period 10.00 -waveform {0 5} [get_ports clk]

# USB-UART Interface
set_property PACKAGE_PIN B18 [get_ports RsRx]
    set_property IOSTANDARD LVCMOS33 [get_ports RsRx]
set_property PACKAGE_PIN A18 [get_ports RsTx]
    set_property IOSTANDARD LVCMOS33 [get_ports RsTx]
