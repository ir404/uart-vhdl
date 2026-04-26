# Clock signal (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
    set_property IOSTANDARD LVCMOS33 [get_ports clk]
    create_clock -add -name clk -period 10.00 -waveform {0 5} [get_ports clk]

# USB-UART Interface
set_property PACKAGE_PIN A18 [get_ports RsTx]
    set_property IOSTANDARD LVCMOS33 [get_ports RsTx]

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

# 7-segment LED 
set_property PACKAGE_PIN W7 [get_ports {LEDs[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDs[0]}]
set_property PACKAGE_PIN W6 [get_ports {LEDs[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDs[1]}]
set_property PACKAGE_PIN U8 [get_ports {LEDs[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDs[2]}]
set_property PACKAGE_PIN V8 [get_ports {LEDs[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDs[3]}]
set_property PACKAGE_PIN U5 [get_ports {LEDs[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDs[4]}]
set_property PACKAGE_PIN V5 [get_ports {LEDs[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDs[5]}]
set_property PACKAGE_PIN U7 [get_ports {LEDs[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDs[6]}]
set_property PACKAGE_PIN V7 [get_ports {LEDs[7]}]							
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDs[7]}]

# The four 7-segment Anodes
set_property PACKAGE_PIN U2 [get_ports {digit_sel[0]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {digit_sel[0]}]
set_property PACKAGE_PIN U4 [get_ports {digit_sel[1]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {digit_sel[1]}]
set_property PACKAGE_PIN V4 [get_ports {digit_sel[2]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {digit_sel[2]}]
set_property PACKAGE_PIN W4 [get_ports {digit_sel[3]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {digit_sel[3]}]