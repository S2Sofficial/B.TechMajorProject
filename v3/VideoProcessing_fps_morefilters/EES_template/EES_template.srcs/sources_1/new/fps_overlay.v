// ============================================================
//  fps_overlay.v
//
//  Renders a real-time 2-digit FPS counter onto the live VGA
//  RGB pixel stream using a hardcoded 5×7 pixel bitmap font,
//  scaled 2× for readability.
//
//  SIGNAL FLOW - this module is inserted in the RGB path only:
//
//    BRAM dout  ──►  fps_overlay  ──►  vga_r / vga_g / vga_b
//                        ▲
//                    fps_counter (fps)
//                    VGA hpos / vpos
//
//  TIMING IMPACT: zero.
//  HSYNC, VSYNC, and PCLK are never touched.
//  The entire logic is combinational (one extra mux level).
//
//  FONT:
//    5 columns × 7 rows per digit
//    Scale factor 2 → each digit = 10 × 14 screen pixels
//    Two digits with 2-pixel gap = 22 × 14 total text region
//    1-pixel dark padding box surrounds the text for readability
//
//  PARAMETERS:
//    H_ACTIVE / V_ACTIVE   - active video resolution
//    DISP_X / DISP_Y       - top-left corner of text region
//    FG_R/G/B              - digit foreground colour (default white)
//    BG_R/G/B              - background box colour   (default near-black)
//
//  RGB bit widths: R=5, G=6, B=5 (RGB565 / standard VGA DAC packing)
// ============================================================
module fps_overlay #(
    parameter H_ACTIVE = 640,
    parameter V_ACTIVE = 480,

    // Top-left of the 2-digit text block (inside active video region).
    // Default: top-right corner with a 6-pixel board margin.
    //   Text block = 22 wide, 14 tall.
    //   640 - 6(margin) - 22(text) - 2(pad) = 610
    parameter DISP_X   = 610,
    parameter DISP_Y   = 8,

    // Digit colour (white)
    parameter FG_R = 5'b11111,
    parameter FG_G = 6'b111111,
    parameter FG_B = 5'b11111,

    // Background box colour (near-black - clearly readable over any scene)
    parameter BG_R = 5'b00001,
    parameter BG_G = 6'b000010,
    parameter BG_B = 5'b00001
)(
    input  wire [9:0] hpos,     // active horizontal pixel (0 = first active pixel)
    input  wire [9:0] vpos,     // active vertical   line  (0 = first active line)

    input  wire [4:0] cam_r,    // camera RGB from BRAM read port
    input  wire [5:0] cam_g,
    input  wire [4:0] cam_b,

    input  wire [7:0] fps,      // current FPS from fps_counter

    output reg  [4:0] out_r,    // output pixel (overlay or camera passthrough)
    output reg  [5:0] out_g,
    output reg  [4:0] out_b
);

    // ----------------------------------------------------------
    //  Geometry (derived from parameters - do not edit)
    // ----------------------------------------------------------
    localparam SCALE   = 2;                    // pixel scale factor
    localparam CHAR_W  = 5 * SCALE;           // 10  px per digit on screen
    localparam CHAR_H  = 7 * SCALE;           // 14  px per digit on screen
    localparam GAP     = 2;                    // horizontal gap between digits
    localparam PAD     = 1;                    // dark background padding (px)

    localparam TEXT_W  = CHAR_W * 2 + GAP;   // 22 px total text width
    localparam TEXT_H  = CHAR_H;             // 14 px total text height

    // Background box coordinates (slightly larger than text)
    localparam BOX_X0  = DISP_X - PAD;       // 609
    localparam BOX_Y0  = DISP_Y - PAD;       // 7
    localparam BOX_X1  = DISP_X + TEXT_W + PAD; // 633
    localparam BOX_Y1  = DISP_Y + TEXT_H + PAD; // 23

    // ----------------------------------------------------------
    //  Digit extraction  (cap at 99 - OV7670 never exceeds 30)
    // ----------------------------------------------------------
    wire [6:0] fps_cap  = (fps > 8'd99) ? 7'd99 : fps[6:0];
    wire [3:0] tens     = fps_cap / 10;
    wire [3:0] units    = fps_cap % 10;

    // ----------------------------------------------------------
    //  5×7 font lookup function
    //
    //  Each glyph is packed as a 35-bit constant:
    //    bits [34:30] = row 0 (top),  bits [4:0] = row 6 (bottom)
    //    within each 5-bit row: bit[4] = leftmost pixel (col 0)
    //
    //  get_font_pixel(digit, col, row) → 1 if pixel is lit
    // ----------------------------------------------------------
    function automatic get_font_pixel;
        input [3:0] digit;
        input [2:0] col;    // 0..4  (left to right)
        input [2:0] row;    // 0..6  (top  to bottom)
        reg [34:0]  glyph;
        reg [4:0]   rowbits;
        begin
            case (digit)
                //                {row0,   row1,   row2,   row3,   row4,   row5,   row6}
                4'd0: glyph = {5'b01110,5'b10001,5'b10001,5'b10001,5'b10001,5'b10001,5'b01110};
                4'd1: glyph = {5'b00100,5'b01100,5'b00100,5'b00100,5'b00100,5'b00100,5'b01110};
                4'd2: glyph = {5'b01110,5'b10001,5'b00001,5'b00110,5'b01000,5'b10000,5'b11111};
                4'd3: glyph = {5'b01110,5'b10001,5'b00001,5'b00110,5'b00001,5'b10001,5'b01110};
                4'd4: glyph = {5'b00010,5'b00110,5'b01010,5'b10010,5'b11111,5'b00010,5'b00010};
                4'd5: glyph = {5'b11111,5'b10000,5'b11110,5'b00001,5'b00001,5'b10001,5'b01110};
                4'd6: glyph = {5'b01110,5'b10000,5'b10000,5'b11110,5'b10001,5'b10001,5'b01110};
                4'd7: glyph = {5'b11111,5'b00001,5'b00010,5'b00100,5'b01000,5'b01000,5'b01000};
                4'd8: glyph = {5'b01110,5'b10001,5'b10001,5'b01110,5'b10001,5'b10001,5'b01110};
                4'd9: glyph = {5'b01110,5'b10001,5'b10001,5'b01111,5'b00001,5'b10001,5'b01110};
                default: glyph = 35'd0;
            endcase
            //  Extract the row: glyph[34-row*5 -: 5]
            rowbits = glyph[34 - ({2'b0,row} * 5) -: 5];
            //  Extract the column bit: bit[4] = col 0 (leftmost)
            get_font_pixel = rowbits[3'd4 - col];
        end
    endfunction

    // ----------------------------------------------------------
    //  Pixel-space offsets (unsigned, only valid inside region)
    // ----------------------------------------------------------
    wire [9:0] off_x = hpos - DISP_X[9:0];   // offset from text left edge
    wire [9:0] off_y = vpos - DISP_Y[9:0];   // offset from text top  edge

    // Which digit column and font row are we in?  (divide offset by SCALE=2)
    // Use bit-shift (>>1) for exact power-of-2 division, no divider needed.
    wire [2:0] font_row = off_y[3:1];          // off_y / 2,  range 0..6

    // Digit 0 (tens):  horizontal range [0, CHAR_W)   = [0,9]
    wire [2:0] font_col_d0 = off_x[3:1];       // off_x / 2

    // Digit 1 (units): horizontal range [CHAR_W+GAP, 2*CHAR_W+GAP) = [12,21]
    wire [9:0] off_x_d1    = off_x - (CHAR_W + GAP);
    wire [2:0] font_col_d1 = off_x_d1[3:1];    // off_x_d1 / 2

    // ----------------------------------------------------------
    //  Region membership (combinational comparators)
    // ----------------------------------------------------------
    // Background box (1-pixel padded around text)
    wire in_box = (hpos >= BOX_X0[9:0]) && (hpos < BOX_X1[9:0]) &&
                  (vpos >= BOX_Y0[9:0]) && (vpos < BOX_Y1[9:0]);

    // Text region
    wire in_text_v = (vpos >= DISP_Y[9:0]) && (vpos < (DISP_Y + TEXT_H));
    wire in_digit0 = in_text_v &&
                     (hpos >= DISP_X[9:0]) &&
                     (hpos <  DISP_X + CHAR_W);
    wire in_digit1 = in_text_v &&
                     (hpos >= DISP_X + CHAR_W + GAP) &&
                     (hpos <  DISP_X + CHAR_W + GAP + CHAR_W);

    // Font pixel lookup (only evaluated when in the respective digit region)
    wire font_px_d0 = get_font_pixel(tens,  font_col_d0, font_row);
    wire font_px_d1 = get_font_pixel(units, font_col_d1, font_row);
    wire pixel_lit  = (in_digit0 & font_px_d0) | (in_digit1 & font_px_d1);

    // ----------------------------------------------------------
    //  Output mux:
    //    1. Lit font pixel → white foreground
    //    2. Inside dark box, no lit pixel → background
    //    3. Outside box → camera passthrough (zero latency)
    // ----------------------------------------------------------
    always @(*) begin
        if (pixel_lit) begin
            out_r = FG_R;
            out_g = FG_G;
            out_b = FG_B;
        end else if (in_box) begin
            out_r = BG_R;
            out_g = BG_G;
            out_b = BG_B;
        end else begin
            out_r = cam_r;
            out_g = cam_g;
            out_b = cam_b;
        end
    end

endmodule