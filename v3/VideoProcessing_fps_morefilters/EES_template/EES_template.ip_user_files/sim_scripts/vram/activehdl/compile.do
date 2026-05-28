transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xpm
vlib activehdl/blk_mem_gen_v8_4_11
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap blk_mem_gen_v8_4_11 activehdl/blk_mem_gen_v8_4_11
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" -l xpm -l blk_mem_gen_v8_4_11 -l xil_defaultlib \
"N:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"N:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vlog -work blk_mem_gen_v8_4_11  -v2k5 "+incdir+../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" -l xpm -l blk_mem_gen_v8_4_11 -l xil_defaultlib \
"../../../../EES_template.srcs/sources_1/bd/vram/ipshared/a32c/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" -l xpm -l blk_mem_gen_v8_4_11 -l xil_defaultlib \
"../../../bd/vram/ip/vram_blk_mem_gen_0_0/sim/vram_blk_mem_gen_0_0.v" \
"../../../bd/vram/sim/vram.v" \

vlog -work xil_defaultlib \
"glbl.v"

