/*
 * Project     : Real-time Video Processing Pipeline using OV7670 Camera
 * Author      : Swaroop Kumar Yadav
 * Date        : 21-May-2026
 * Description : FPGA-based real-time video processing system using OV7670 camera
 *               on Basys 3 FPGA board, capturing video input and displaying the
 *               processed output and fps count on a VGA monitor.
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

    // Switch-controlled filter select
    // {sw2, sw1, sw0}
    input sw0,
    input sw1,
    input sw2
);

// ─── VGA Timing Parameters ──────────────────────────────────────
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

// ─── Filter Mode Selection ──────────────────────────────────────────────────
// 000 = Normal RGB
// 001 = Grayscale
// 010 = Red only
// 011 = Blue only
// 100 = Green only
// 101 = Invert / Negative
// 110 = Sepia
// 111 = Posterize
wire [2:0] mode = {sw2, sw1, sw0};

// ─── Extract raw RGB444 channels from BRAM pixel ────────────────────────────
wire [3:0] r = frame_pixel[11:8];
wire [3:0] g = frame_pixel[7:4];
wire [3:0] b = frame_pixel[3:0];

// ─── Shared Grayscale Luma ──────────────────────────────────────────────────
// Approximation: Y ≈ (2R + 5G + B) >> 3
// Weights sum to 8 → divide by 8 (right-shift 3). No multipliers, no overflow.
wire [6:0] luma_sum = {2'b0, r, 1'b0}   // 2R
                    + {1'b0, g, 2'b0}   // 4G
                    + {3'b0, g}         // +G  → 5G total
                    + {3'b0, b};        // +B

wire [3:0] gray4 = luma_sum[6:3];

// ─── Sepia Tone Filter ──────────────────────────────────────────────────────
// Warm vintage tone using luma with offsets.
// Saturation prevents overflow/underflow.
wire [3:0] sepia_r = (gray4 > 4'd12) ? 4'hF : gray4 + 4'd3;
wire [3:0] sepia_g = gray4;
wire [3:0] sepia_b = (gray4 < 4'd3)  ? 4'h0 : gray4 - 4'd3;

// ─── Posterize Filter ───────────────────────────────────────────────────────
// Replicate top 2 bits into lower 2 bits.
// Produces 4 levels/channel → 64 colours total.
wire [3:0] post_r = {r[3:2], r[3:2]};
wire [3:0] post_g = {g[3:2], g[3:2]};
wire [3:0] post_b = {b[3:2], b[3:2]};

// ─── Final Filter Output MUX ────────────────────────────────────────────────
reg [3:0] r_out;
reg [3:0] g_out;
reg [3:0] b_out;

always @(*) begin
    case (mode)

        // ── Normal RGB ─────────────────────────────────────────────────────
        3'b000: begin
            r_out = r;
            g_out = g;
            b_out = b;
        end

        // ── Grayscale ──────────────────────────────────────────────────────
        3'b001: begin
            r_out = gray4;
            g_out = gray4;
            b_out = gray4;
        end

        // ── Red Channel Only ───────────────────────────────────────────────
        3'b010: begin
            r_out = r;
            g_out = 4'h0;
            b_out = 4'h0;
        end

        // ── Blue Channel Only ──────────────────────────────────────────────
        3'b011: begin
            r_out = 4'h0;
            g_out = 4'h0;
            b_out = b;
        end

        // ── Green Channel Only ─────────────────────────────────────────────
        3'b100: begin
            r_out = 4'h0;
            g_out = g;
            b_out = 4'h0;
        end

        // ── Invert / Negative ──────────────────────────────────────────────
        3'b101: begin
            r_out = 4'hF - r;
            g_out = 4'hF - g;
            b_out = 4'hF - b;
        end

        // ── Sepia Tone ─────────────────────────────────────────────────────
        3'b110: begin
            r_out = sepia_r;
            g_out = sepia_g;
            b_out = sepia_b;
        end

        // ── Posterize ──────────────────────────────────────────────────────
        3'b111: begin
            r_out = post_r;
            g_out = post_g;
            b_out = post_b;
        end

    endcase
end

// ─── Timing ─────────────────────────────────────────
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

    // ── Pixel output ───────────────────────────────────────────────────────
    if (blank == 0) begin
        vga_red   <= r_out;
        vga_green <= g_out;
        vga_blue  <= b_out;
    end else begin
        vga_red   <= 4'b0;
        vga_green <= 4'b0;
        vga_blue  <= 4'b0;
    end

    // ── Address & blank generation ─────────────────────────────
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

    // ── Sync pulses ────────────────────────────────────────────
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