-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
-- Date        : Tue Apr 28 12:58:43 2026
-- Host        : KAALU running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               n:/Swaroop_Ka_kachra/OV7670_to_VGA_FPGA-master/OV7670_to_VGA_FPGA-master/OV7670_to_VGA_BRAM/EES_template.srcs/sources_1/bd/clk_gen/ip/clk_gen_clk_wiz_0_0/clk_gen_clk_wiz_0_0_stub.vhdl
-- Design      : clk_gen_clk_wiz_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_gen_clk_wiz_0_0 is
  Port ( 
    clk_100 : out STD_LOGIC;
    clk_25 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of clk_gen_clk_wiz_0_0 : entity is "clk_gen_clk_wiz_0_0,clk_wiz_v6_0_16_0_0,{component_name=clk_gen_clk_wiz_0_0,use_phase_alignment=true,use_min_o_jitter=false,use_max_i_jitter=false,use_dyn_phase_shift=false,use_inclk_switchover=false,use_dyn_reconfig=false,enable_axi=0,feedback_source=FDBK_AUTO,PRIMITIVE=MMCM,num_out_clk=2,clkin1_period=10.000,clkin2_period=10.000,use_power_down=false,use_reset=true,use_locked=true,use_inclk_stopped=false,feedback_type=SINGLE,CLOCK_MGR_TYPE=NA,manual_override=false}";
end clk_gen_clk_wiz_0_0;

architecture stub of clk_gen_clk_wiz_0_0 is
  attribute syn_black_box : boolean;
  attribute black_box_pad_pin : string;
  attribute syn_black_box of stub : architecture is true;
  attribute black_box_pad_pin of stub : architecture is "clk_100,clk_25,reset,locked,clk_in1";
begin
end;
