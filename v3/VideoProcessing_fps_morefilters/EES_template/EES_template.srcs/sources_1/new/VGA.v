/*
 * Project     : Real-time Video Processing Pipeline using OV7670 Camera
 * Author      : Swaroop Kumar Yadav
 * Date        : 21-May-2026
 * Description : FPGA-based real-time video processing system using OV7670 camera
 *               on Basys 3 FPGA board, capturing video input and displaying the
 *               processed output on a VGA monitor.
 */
`timescale 1ns / 1ps

module vga(
    input clk25,
    output reg [3:0] vga_red,
    output reg [3:0] vga_green,
    output reg [3:0] vga_blue,
    output reg vga_hsync,
    output reg vga_vsync,
    output [16:0] frame_addr,
    input  [11:0] frame_pixel,
    input [7:0] fps_value,

    // Switch-controlled filters (independent, stackable)
    input sw0,   // Filter 1: Grayscale
    input sw1,   // Filter 2: Invert (negative)
    input sw2    // Filter 3: Channel Swap R<->B (false colour)
);

// ─── VGA Timing Parameters (UNCHANGED) ──────────────────────────────────────
parameter hRez        = 640;
parameter hStartSync  = 640 + 16;
parameter hEndSync    = 640 + 16 + 96;
parameter hMaxCount   = 800;

parameter vRez        = 480;
parameter vStartSync  = 480 + 10;
parameter vEndSync    = 480 + 10 + 2;
parameter vMaxCount   = 480 + 10 + 2 + 33;

parameter hsync_active = 0;
parameter vsync_active = 0;

reg [9:0]  hCounter;
reg [9:0]  vCounter;
reg [16:0] address;
reg        blank;

initial hCounter = 10'b0;
initial vCounter = 10'b0;
initial address  = 17'b0;
initial blank    = 1'b1;

assign frame_addr = address;

// ─── Extract raw RGB444 channels from BRAM pixel ─────────────────────────────
wire [3:0] r = frame_pixel[11:8];
wire [3:0] g = frame_pixel[7:4];
wire [3:0] b = frame_pixel[3:0];

// ─── Filter 1: Grayscale ──────────────────────────────────────────────────────
// Approximation: Y ≈ (2R + 5G + B) >> 3
// Weights sum to 8 → divide by 8 (right-shift 3). No multipliers, no overflow.
// Bit widths: {2'b0,r,1'b0} = 7 bits (2R), {1'b0,g,2'b0} = 7 bits (4G),
//             {3'b0,g} = 7 bits (G), {3'b0,b} = 7 bits (B).
// Max value: 2×15 + 5×15 + 15 = 120  → [6:3] gives 15 exactly. No overflow. ✓
wire [6:0] luma_sum = {2'b0, r, 1'b0}   // 2R
                    + {1'b0, g, 2'b0}   // 4G
                    + {3'b0, g}         // +G  → 5G total
                    + {3'b0, b};        // +B
wire [3:0] gray4 = luma_sum[6:3];      // divide by 8 → 4-bit result

// Apply grayscale (sw0): replace all channels with luma
wire [3:0] r_s0 = sw0 ? gray4 : r;
wire [3:0] g_s0 = sw0 ? gray4 : g;
wire [3:0] b_s0 = sw0 ? gray4 : b;

// ─── Filter 2: Invert / Negative (sw1) ───────────────────────────────────────
// Per-channel complement: channel_out = 0xF - channel_in
wire [3:0] r_s1 = sw1 ? (4'hF - r_s0) : r_s0;
wire [3:0] g_s1 = sw1 ? (4'hF - g_s0) : g_s0;
wire [3:0] b_s1 = sw1 ? (4'hF - b_s0) : b_s0;

// ─── Filter 3: Channel Swap R↔B  (sw2) ───────────────────────────────────────
// Swaps red and blue channels → produces a cool false-colour effect.
// Green is left untouched.
wire [3:0] r_out = sw2 ? b_s1 : r_s1;
wire [3:0] g_out = g_s1;               // green: unaffected by swap
wire [3:0] b_out = sw2 ? r_s1 : b_s1;

// ─── Timing (IDENTICAL to original) ──────────────────────────────────────────
always @(posedge clk25) begin

    // Horizontal / vertical counters
    if (hCounter == hMaxCount - 1) begin
        hCounter <= 10'b0;
        if (vCounter == vMaxCount - 1)
            vCounter <= 10'b0;
        else
            vCounter <= vCounter + 1;
    end else
        hCounter <= hCounter + 1;

    // ── Pixel output ────────────────────────────────────────────────────────
    // Default: original real-time colour from camera.
    // Filters stack: sw0 → sw1 → sw2 (each independent, any combo works).
    if (blank == 0) begin
        vga_red   <= r_out;
        vga_green <= g_out;
        vga_blue  <= b_out;
    end else begin
        vga_red   <= 4'b0;   // blanking → black (same as original)
        vga_green <= 4'b0;
        vga_blue  <= 4'b0;
    end

    // ── Address & blank generation (UNCHANGED) ───────────────────────────────
    if (vCounter >= 360 || vCounter < 120) begin
        address <= 17'b0;
        blank   <= 1'b1;
    end else begin
        if (hCounter < 480 && hCounter >= 160) begin
            blank   <= 1'b0;
            address <= address + 1;
        end else
            blank <= 1'b1;
    end

    // ── Sync pulses (UNCHANGED) ──────────────────────────────────────────────
    if (hCounter > hStartSync && hCounter <= hEndSync)
        vga_hsync <= hsync_active;
    else
        vga_hsync <= ~hsync_active;

    if (vCounter >= vStartSync && vCounter < vEndSync)
        vga_vsync <= vsync_active;
    else
        vga_vsync <= ~vsync_active;

end

endmodule