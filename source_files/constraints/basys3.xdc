# Clock signal (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name clk -period 10.00 -waveform {0 5} [get_ports clk]

# Switches (SW2, SW1, SW0)
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]                    
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]                    
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]                    
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]

# Centre Button (btnC)
set_property PACKAGE_PIN U18 [get_ports btnC]                        
set_property IOSTANDARD LVCMOS33 [get_ports btnC]

# USB-UART Interface
set_property PACKAGE_PIN B18 [get_ports RsRx]
set_property IOSTANDARD LVCMOS33 [get_ports RsRx]
set_property PACKAGE_PIN A18 [get_ports RsTx]
set_property IOSTANDARD LVCMOS33 [get_ports RsTx]
