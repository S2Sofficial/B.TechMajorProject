// ============================================================
//  fps_counter.v
//
//  Counts OV7670 VSYNC rising edges over a 1-second window
//  derived from sys_clk.  Output `fps` is latched once per
//  second so the display value is always stable.
//
//  Timing impact on video path: NONE.
//  This module sits completely off the pixel datapath.
//
//  Parameters:
//    SYS_CLK_HZ - your system clock frequency in Hz
//                 (50_000_000 for 50 MHz, 100_000_000 for 100 MHz, etc.)
// ============================================================
module fps_counter #(
    parameter SYS_CLK_HZ = 50_000_000
)(
    input  wire       clk,
    input  wire       rst_n,

    // Connect to OV7670 VSYNC (active-high frame sync from camera)
    // This counts actual camera FPS, not VGA refresh rate.
    input  wire       ov_vsync,

    // Stable FPS value, updated once per second.
    // Range: 0-255 (OV7670 maxes at ~30 fps so 8 bits is plenty)
    output reg  [7:0] fps
);

    // ----------------------------------------------------------
    //  1-second tick generator
    //  One tick pulse = exactly 1 second of sys_clk cycles
    // ----------------------------------------------------------
    localparam TICK_MAX = SYS_CLK_HZ - 1;
    localparam TICK_W   = $clog2(SYS_CLK_HZ);

    reg [TICK_W-1:0] tick_cnt;
    reg              second_tick;   // single-cycle pulse every 1 s

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_cnt    <= 0;
            second_tick <= 0;
        end else begin
            second_tick <= 0;
            if (tick_cnt == TICK_MAX[TICK_W-1:0]) begin
                tick_cnt    <= 0;
                second_tick <= 1;
            end else begin
                tick_cnt <= tick_cnt + 1'b1;
            end
        end
    end

    // ----------------------------------------------------------
    //  VSYNC rising-edge detector (2-FF synchroniser + edge detect)
    //  Even if ov_vsync is already synchronous to clk, the 2-FF
    //  chain costs nothing and prevents issues if it isn't.
    // ----------------------------------------------------------
    reg [1:0] vsync_sr;
    wire      vsync_rise = vsync_sr[0] & ~vsync_sr[1];  // rising edge

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) vsync_sr <= 2'b00;
        else        vsync_sr <= {vsync_sr[0], ov_vsync};
    end

    // ----------------------------------------------------------
    //  Frame counter - accumulate within the 1-second window
    // ----------------------------------------------------------
    reg [7:0] frame_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            frame_cnt <= 8'd0;
            fps       <= 8'd0;
        end else begin
            if (second_tick) begin
                fps       <= frame_cnt;   // latch stable reading
                frame_cnt <= 8'd0;        // reset accumulator
            end else if (vsync_rise) begin
                // Saturate at 255 to avoid wrap-around on abnormal input
                if (frame_cnt != 8'hFF)
                    frame_cnt <= frame_cnt + 1'b1;
            end
        end
    end

endmodule