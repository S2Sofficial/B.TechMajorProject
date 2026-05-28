//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
//Date        : Tue Apr 28 12:55:44 2026
//Host        : KAALU running 64-bit major release  (build 9200)
//Command     : generate_target clk_gen_wrapper.bd
//Design      : clk_gen_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module clk_gen_wrapper
   (clk_100,
    clk_25,
    clk_in1,
    locked,
    reset);
  output clk_100;
  output clk_25;
  input clk_in1;
  output locked;
  input reset;

  wire clk_100;
  wire clk_25;
  wire clk_in1;
  wire locked;
  wire reset;

  clk_gen clk_gen_i
       (.clk_100(clk_100),
        .clk_25(clk_25),
        .clk_in1(clk_in1),
        .locked(locked),
        .reset(reset));
endmodule
