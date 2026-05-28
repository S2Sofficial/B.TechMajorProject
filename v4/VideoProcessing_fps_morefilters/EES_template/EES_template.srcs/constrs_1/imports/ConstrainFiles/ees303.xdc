#
 # Project     : Real-time Video Processing Pipeline using OV7670 Camera
 # Author      : Swaroop Kumar Yadav
 # Date        : 21-May-2026
 # Description : FPGA-based real-time video processing system using OV7670 camera
 #               on Basys 3 FPGA board, capturing video input and displaying the
 #               processed output on a VGA monitor.
 #
#############################################
# CLOCK + RESET
#############################################
set_property PACKAGE_PIN W5 [get_ports sys_clk_pin]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk_pin]
create_clock -period 10.000 [get_ports sys_clk_pin]

set_property PACKAGE_PIN R2 [get_ports sys_rst_n_pin]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n_pin]

#############################################
# LED
#############################################
set_property PACKAGE_PIN U16 [get_ports {led_pin[0]}]
set_property PACKAGE_PIN E19 [get_ports {led_pin[1]}]
set_property PACKAGE_PIN U19 [get_ports {led_pin[2]}]
set_property PACKAGE_PIN V19 [get_ports {led_pin[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_pin[3]}]

#############################################
# OV7670 CAMERA (PMOD JB + JC)
#############################################

## DATA → JB
set_property PACKAGE_PIN A14 [get_ports {data_pin[0]}]
set_property PACKAGE_PIN A16 [get_ports {data_pin[1]}]
set_property PACKAGE_PIN B15 [get_ports {data_pin[2]}]
set_property PACKAGE_PIN B16 [get_ports {data_pin[3]}]
set_property PACKAGE_PIN A15 [get_ports {data_pin[4]}]
set_property PACKAGE_PIN A17 [get_ports {data_pin[5]}]
set_property PACKAGE_PIN C15 [get_ports {data_pin[6]}]
set_property PACKAGE_PIN C16 [get_ports {data_pin[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {data_pin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_pin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_pin[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_pin[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_pin[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_pin[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_pin[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_pin[7]}]

## SYNC + PCLK → JC
set_property PACKAGE_PIN M19 [get_ports pclk]
set_property PACKAGE_PIN L17 [get_ports href]
set_property PACKAGE_PIN P17 [get_ports vsync]

set_property IOSTANDARD LVCMOS33 [get_ports pclk]
set_property IOSTANDARD LVCMOS33 [get_ports href]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

## I2C → JC
set_property PACKAGE_PIN M18 [get_ports sioc]
set_property PACKAGE_PIN N17 [get_ports siod]

set_property IOSTANDARD LVCMOS33 [get_ports sioc]
set_property IOSTANDARD LVCMOS33 [get_ports siod]

## CONTROL → JC
set_property PACKAGE_PIN K17 [get_ports xclk]
set_property PACKAGE_PIN R18 [get_ports pwdn]
set_property PACKAGE_PIN P18 [get_ports reset_pin]

set_property IOSTANDARD LVCMOS33 [get_ports xclk]
set_property IOSTANDARD LVCMOS33 [get_ports pwdn]
set_property IOSTANDARD LVCMOS33 [get_ports reset_pin]

## CLOCK ROUTE FIX (pclk enters on a non-clock-capable pin)
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets pclk]

#############################################
# VGA
#############################################

## BLUE
set_property PACKAGE_PIN N18 [get_ports {B[0]}]
set_property PACKAGE_PIN L18 [get_ports {B[1]}]
set_property PACKAGE_PIN K18 [get_ports {B[2]}]
set_property PACKAGE_PIN J18 [get_ports {B[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {B[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[3]}]

## RED
set_property PACKAGE_PIN G19 [get_ports {R[0]}]
set_property PACKAGE_PIN H19 [get_ports {R[1]}]
set_property PACKAGE_PIN J19 [get_ports {R[2]}]
set_property PACKAGE_PIN N19 [get_ports {R[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {R[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {R[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {R[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {R[3]}]

## GREEN
set_property PACKAGE_PIN J17 [get_ports {G[0]}]
set_property PACKAGE_PIN H17 [get_ports {G[1]}]
set_property PACKAGE_PIN G17 [get_ports {G[2]}]
set_property PACKAGE_PIN D17 [get_ports {G[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {G[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {G[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {G[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {G[3]}]

## SYNC
set_property PACKAGE_PIN R19 [get_ports v_sync]
set_property PACKAGE_PIN P19 [get_ports h_sync]

set_property IOSTANDARD LVCMOS33 [get_ports v_sync]
set_property IOSTANDARD LVCMOS33 [get_ports h_sync]

#switches for filter control
# ─── Filter Mode Selection ──────────────────────────────────────────────────
# 000 = Normal RGB
# 001 = Grayscale
# 010 = Red only
# 011 = Blue only
# 100 = Green only
# 101 = Invert / Negative
# 110 = Sepia
# 111 = Posterize

set_property PACKAGE_PIN V17 [get_ports {sw0}]
set_property PACKAGE_PIN V16 [get_ports {sw1}]
set_property PACKAGE_PIN W16 [get_ports {sw2}]

set_property IOSTANDARD LVCMOS33 [get_ports {sw0}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw1}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw2}]
