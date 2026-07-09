# Camera Pipeline Project - Version 1 (NO SWITCH)

## Overview
Version 1 is a Vivado-based OV7670 camera-to-VGA design for the Basys 3 board. It does not use switches for control; the top module handles reset, camera setup, frame capture, framebuffer storage, and VGA output automatically.

## Main Features
- OV7670 initialization over I2C
- 100 MHz and 25 MHz clock generation
- Camera frame capture from `pclk`, `vsync`, `href`, and 8-bit data
- Framebuffer storage in BRAM via `vram`
- VGA output at 640x480 timing
- Status LEDs for camera and sync signals
- Boot-time reset delay before camera configuration starts

## Top Module Summary
The design is centered around `OV7670_top.v` and connects these blocks:
- `ov7670_init` for camera setup
- `ov7670_capture` for pixel capture and write control
- `vram` for frame storage and display reads
- `vga` for RGB and sync generation
- `clk_gen_wrapper` for clock generation

## Files in `v1`
- `CameraPipelineProject_v_NoSwitch.tcl` - Vivado project restore script
- `OV7670_top.bit` - Prebuilt bitstream for programming the board

## Build and Run
1. Open Vivado 2025.1 or a compatible version.
2. Source `CameraPipelineProject_v_NoSwitch.tcl` in the Tcl console.
3. Run synthesis and implementation if you want to regenerate the bitstream.
4. Program the board using `OV7670_top.bit` if you just want to test the existing build.

## Notes
This project is made by Swaroop Kumar Yadav 
