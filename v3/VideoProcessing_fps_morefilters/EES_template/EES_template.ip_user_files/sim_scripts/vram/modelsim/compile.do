vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/blk_mem_gen_v8_4_11
vlib modelsim_lib/msim/xil_defaultlib

vmap xpm modelsim_lib/msim/xpm
vmap blk_mem_gen_v8_4_11 modelsim_lib/msim/blk_mem_gen_v8_4_11
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" \
"N:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"N:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vlog -work blk_mem_gen_v8_4_11  -incr -mfcu  "+incdir+../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" \
"../../../../EES_template.srcs/sources_1/bd/vram/ipshared/a32c/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" \
"../../../bd/vram/ip/vram_blk_mem_gen_0_0/sim/vram_blk_mem_gen_0_0.v" \
"../../../bd/vram/sim/vram.v" \

vlog -work xil_defaultlib \
"glbl.v"

