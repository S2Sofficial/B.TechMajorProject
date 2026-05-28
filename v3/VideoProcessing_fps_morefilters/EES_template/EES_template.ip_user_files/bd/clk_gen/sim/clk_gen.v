//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
//Date        : Wed Apr 22 12:31:14 2026
//Host        : KAALU running 64-bit major release  (build 9200)
//Command     : generate_target clk_gen.bd
//Design      : clk_gen
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* HW_HANDOFF = "clk_gen.hwdef" *) (* core_generation_info = "clk_gen,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=clk_gen,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}" *) 
module clk_gen
   (clk_100,
    clk_25,
    clk_in1,
    locked,
    reset);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 CLK.CLK_100 CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME CLK.CLK_100, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output clk_100;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 CLK.CLK_25 CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME CLK.CLK_25, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 25000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output clk_25;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 CLK.CLK_IN1 CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME CLK.CLK_IN1, CLK_DOMAIN clk_gen_clk_in1, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input clk_in1;
  output locked;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 RST.RESET RST" *) (* x_interface_parameter = "XIL_INTERFACENAME RST.RESET, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) input reset;

  wire clk_100;
  wire clk_25;
  wire clk_in1;
  wire locked;
  wire reset;

  clk_gen_clk_wiz_0_0 clk_wiz_0
       (.clk_100(clk_100),
        .clk_25(clk_25),
        .clk_in1(clk_in1),
        .locked(locked),
        .reset(reset));
endmodule
