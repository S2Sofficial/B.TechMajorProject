/*
 * Project     : Real-time Video Processing Pipeline using OV7670 Camera
 * Author      : Swaroop Kumar Yadav
 * Date        : 21-May-2026
 * Description : FPGA-based real-time video processing system using OV7670 camera
 *               on Basys 3 FPGA board, capturing video input and displaying the
 *               processed output on a VGA monitor.
 *               FPS counter overlaid on top-right corner of display.
 */
`timescale 1ns / 1ps

module OV7670_top(
    input  sys_clk_pin,
    input  sys_rst_n_pin,
    input  sw0, sw1, sw2,        // switch for filter control

    output              sioc,    // I2C CLOCK
    inout               siod,    // I2C DATA

    input  pclk,
    input  vsync,
    input  href,
    input  [7:0] data_pin,

    output [3:0] led_pin,
    output xclk,
    output pwdn,
    output reset_pin,

    output h_sync, v_sync,
    output [3:0] R, G, B
);

    // -------------------------------------------------------------------------
    //  Clocks and internal reset
    // -------------------------------------------------------------------------
    wire clk_100, clk_25;

    reg [15:0] reset_cnt = 0;
    reg rst = 0;

    assign led_pin[1] = pclk;
    assign led_pin[2] = vsync;
    assign led_pin[3] = href;
    assign xclk       = clk_25;
    assign pwdn       = 0;
    assign reset_pin  = 1;

    // Count ~655 µs after power-on before releasing internal reset
    always @(posedge sys_clk_pin) begin
        if (!sys_rst_n_pin) begin
            reset_cnt <= 0;
            rst       <= 0;
        end else begin
            if (reset_cnt < 16'hFFFF) begin
                reset_cnt <= reset_cnt + 1'b1;
                rst       <= 0;
            end else begin
                rst <= 1;
            end
        end
    end

    // -------------------------------------------------------------------------
    //  Clock generator  -  100 MHz and 25 MHz from board oscillator
    // -------------------------------------------------------------------------
    clk_gen_wrapper u_clk_gen_wrapper (
        .clk_in1 (sys_clk_pin),
        .clk_100 (clk_100),
        .clk_25  (clk_25)
    );

    // -------------------------------------------------------------------------
    //  OV7670 init + SCCB configuration
    //  (handles I2C register writes internally)
    // -------------------------------------------------------------------------
    ov7670_init u_ov7670_init (
        .iCLK       (clk_100),
        .iRST_N     (rst),
        .I2C_SCLK   (sioc),
        .I2C_SDAT   (siod),
        .Config_Done(led_pin[0])
    );

    // -------------------------------------------------------------------------
    //  Frame-buffer BRAM  (dual-port, 17-bit addr, 12-bit pixel)
    //  Port A - camera write side (clk_25)
    //  Port B - VGA  read  side  (clk_25)
    // -------------------------------------------------------------------------
    wire        wr;
    wire [16:0] capture_addr;
    wire [15:0] capture_data;
    wire [16:0] frame_addr;
    wire [11:0] frame_pixel;

    vram_wrapper u_vram_wrapper (
        // Port A - write (capture)
        .BRAM_PORTA_clk  (clk_25),
        .BRAM_PORTA_addr (capture_addr),
        .BRAM_PORTA_din  ({capture_data[15:12],   // R[3:0]
                           capture_data[10:7],     // G[3:0]
                           capture_data[4:1]}),    // B[3:0]
        .BRAM_PORTA_en   (1'b1),
        .BRAM_PORTA_we   (wr),
        // Port B - read (VGA)
        .BRAM_PORTB_clk  (clk_25),
        .BRAM_PORTB_addr (frame_addr),
        .BRAM_PORTB_dout (frame_pixel),
        .BRAM_PORTB_en   (1'b1)
    );

    // -------------------------------------------------------------------------
    //  VGA sync generator + pixel output
    //
    //  Connected to intermediate RGB wires (vga_r_int etc.) instead of the
    //  top-level R/G/B pins so fps_overlay can intercept the pixel stream.
    //  h_sync and v_sync still go directly to the output pins unchanged.
    // -------------------------------------------------------------------------
    wire [3:0] vga_r_int, vga_g_int, vga_b_int;

    vga u_vga (
        .clk25       (clk_25),
        .vga_red     (vga_r_int),   // <- intermediate wire, not R directly
        .vga_green   (vga_g_int),
        .vga_blue    (vga_b_int),
        .vga_hsync   (h_sync),      // sync still goes straight to pin
        .vga_vsync   (v_sync),
        .frame_addr  (frame_addr),
        .frame_pixel (frame_pixel),
        .sw0         (sw0),
        .sw1         (sw1),
        .sw2         (sw2)
    );

    // -------------------------------------------------------------------------
    //  OV7670 pixel capture  (pclk domain)
    //  Packs two successive bytes into one RGB565 word and writes to BRAM.
    // -------------------------------------------------------------------------
    ov7670_capture u_ov7670_capture (
        .pclk  (pclk),
        .vsync (vsync),
        .href  (href),
        .d     (data_pin),
        .addr  (capture_addr),
        .dout  (capture_data),
        .wr    (wr)
    );

    // =========================================================================
    //  FPS COUNTER
    //
    //  Counts vsync rising edges from the camera over a 1-second window
    //  derived from clk_100.  Output fps[7:0] is stable (updates 1×/sec).
    //  rst acts as active-low reset here: 0 = in reset, 1 = running.
    // =========================================================================
    wire [7:0] fps;

    fps_counter #(
        .SYS_CLK_HZ (100_000_000)  // clk_100 = 100 MHz
    ) u_fps_counter (
        .clk      (clk_100),
        .rst_n    (rst),            // rst: 0 during power-on, 1 when ready
        .ov_vsync (vsync),          // camera frame sync
        .fps      (fps)
    );

    // =========================================================================
    //  SCREEN-POSITION TRACKER  (clk_25 domain)
    //
    //  Derives the active-region pixel coordinates (hpos, vpos) from the
    //  h_sync and v_sync signals that VGA is already generating.
    //  This avoids any modification to vga.v.
    //
    //  Standard 640x480 @ 60 Hz blanking intervals (25 MHz pixel clock):
    //    Horizontal: 96 sync + 48 back-porch = 144 clocks before active
    //    Vertical:    2 sync + 33 back-porch =  35 lines  before active
    //
    //  h_cnt_s counts clocks since the last HSYNC falling edge.
    //  v_cnt_s counts HSYNC falling edges since the last VSYNC falling edge.
    // =========================================================================
    localparam H_BP = 144;   // clocks from HSYNC fall to first active pixel
    localparam V_BP = 35;    // lines  from VSYNC fall to first active line

    reg [9:0] h_cnt_s = 0;
    reg [9:0] v_cnt_s = 0;
    reg       h_sync_d = 1, v_sync_d = 1;

    // Detect falling edges of the sync outputs (negative-polarity syncs)
    always @(posedge clk_25) begin
        h_sync_d <= h_sync;
        v_sync_d <= v_sync;
    end

    wire hsync_fall = h_sync_d & ~h_sync;  // HSYNC 1→0 = start of sync pulse
    wire vsync_fall = v_sync_d & ~v_sync;  // VSYNC 1→0 = start of new frame

    always @(posedge clk_25) begin
        if (vsync_fall) begin
            // New frame: reset both counters
            v_cnt_s <= 0;
            h_cnt_s <= 0;
        end else if (hsync_fall) begin
            // New line: increment line counter, reset pixel counter
            v_cnt_s <= v_cnt_s + 1'b1;
            h_cnt_s <= 0;
        end else begin
            h_cnt_s <= h_cnt_s + 1'b1;
        end
    end

    // Active-region flags and pixel coordinates
    wire h_act = (h_cnt_s >= H_BP) && (h_cnt_s < H_BP + 640);
    wire v_act = (v_cnt_s >= V_BP) && (v_cnt_s < V_BP + 480);

    wire [9:0] hpos = h_act ? (h_cnt_s - H_BP[9:0]) : 10'd0;
    wire [9:0] vpos = v_act ? (v_cnt_s - V_BP[9:0]) : 10'd0;

    // =========================================================================
    //  FPS OVERLAY
    //
    //  Intercepts vga_r/g/b_int and renders the 2-digit FPS number in the
    //  top-right corner (white digits on a near-black box).
    //
    //  Bit-width adaptation:
    //    VGA outputs 4-bit RGB (RGB444 from 12-bit frame_pixel).
    //    fps_overlay ports are RGB565 (5/6/5).
    //    Pad camera input  left:  4-bit → 5-bit by appending 0 (e.g. {r, 1'b0})
    //    Truncate overlay output: top 4 bits used for the 4-bit output pins.
    //
    //  HSYNC and VSYNC are never touched by this module.
    // =========================================================================
    wire [4:0] ovl_r;
    wire [5:0] ovl_g;
    wire [4:0] ovl_b;

    fps_overlay #(
        .H_ACTIVE (640),
        .V_ACTIVE (480),
        .DISP_X   (610),           // top-right: 640 - 6 margin - 24 box = 610
        .DISP_Y   (8),
        .FG_R     (5'b11111),      // white digits
        .FG_G     (6'b111111),
        .FG_B     (5'b11111),
        .BG_R     (5'b00001),      // near-black background box
        .BG_G     (6'b000010),
        .BG_B     (5'b00001)
    ) u_fps_overlay (
        .hpos  (hpos),
        .vpos  (vpos),
        // Pad 4-bit VGA channels to fps_overlay's 5/6/5 inputs
        .cam_r ({vga_r_int, 1'b0}),
        .cam_g ({vga_g_int, 2'b00}),
        .cam_b ({vga_b_int, 1'b0}),
        .fps   (fps),
        // 5/6/5-bit overlay result
        .out_r (ovl_r),
        .out_g (ovl_g),
        .out_b (ovl_b)
    );

    // =========================================================================
    //  FINAL RGB OUTPUT
    //
    //  During active video: drive the overlay-modified pixel (top 4 bits of
    //  the 5/6/5 result maps cleanly back to the 4-bit DAC pins).
    //  During blanking:     force all channels to zero (required for correct
    //                       VGA sync detection on the monitor side).
    // =========================================================================
    wire active = h_act & v_act;

    assign R = active ? ovl_r[4:1] : 4'b0000;
    assign G = active ? ovl_g[5:2] : 4'b0000;
    assign B = active ? ovl_b[4:1] : 4'b0000;

endmodule