/*
 * Project     : Real-time Video Processing Pipeline using OV7670 Camera
 * Author      : Swaroop Kumar Yadav
 * Date        : 21-May-2026
 * Description : FPGA-based real-time video processing system using OV7670 camera
 *               on Basys 3 FPGA board, capturing video input and displaying the
 *               processed output on a VGA monitor.
 */
`timescale 1ns / 1ps

module I2C_OV7670_RGB565_Config2(
    input       [7:0]  LUT_INDEX,
    output reg  [15:0] LUT_DATA
);

parameter Read_DATA  = 0; // Read data LUT base address
parameter SET_OV7670 = 2; // OV7670 config LUT base address

///////////////////// Config Data LUT //////////////////////////    
always @(*)
begin
    case(LUT_INDEX)

    // ================= Read Sensor ID =================
    // Read_DATA + 0 : LUT_DATA = {8'h0A, 8'h76}; // PID (Product ID high byte, read-only)
    // Read_DATA + 1 : LUT_DATA = {8'h0B, 8'h73}; // VER (Product ID low byte, read-only)

    Read_DATA + 0 : LUT_DATA = {8'h1C, 8'h7F}; // MIDH: Manufacturer ID high byte (read-only)
    Read_DATA + 1 : LUT_DATA = {8'h1D, 8'hA2}; // MIDL: Manufacturer ID low byte (read-only)

    // ================= OV7670 VGA RGB565 Configuration =================

    SET_OV7670 + 0  : LUT_DATA = 16'h1214; // COM7: Set VGA format + RGB output (00:YUV, 04:RGB). (Note: no reset bit here)
    SET_OV7670 + 1  : LUT_DATA = 16'h40D0; // COM15: RGB565 format, full output range (00-FF). YUV uses limited range.
    SET_OV7670 + 2  : LUT_DATA = 16'h3A04; // TSLB: Output sequence control (with COM13)
                                           // 00:YUYV, 01:YVYU, 10:UYVY, 11:VYUY
    SET_OV7670 + 3  : LUT_DATA = 16'h3DC8; // COM13: Gamma enable, UV adjustment, works with TSLB for output format
    SET_OV7670 + 4  : LUT_DATA = 16'h1E01; // MVFP: Image orientation control
                                           // Bit[5]=mirror (horizontal), Bit[4]=flip (vertical)
    SET_OV7670 + 5  : LUT_DATA = 16'h6B00; // PLL control / internal regulator settings (datasheet-dependent)
    SET_OV7670 + 6  : LUT_DATA = 16'h32B6; // HREF: Horizontal reference control (timing alignment)
    SET_OV7670 + 7  : LUT_DATA = 16'h1713; // HSTART: Horizontal frame start (high 8 bits)
    SET_OV7670 + 8  : LUT_DATA = 16'h1801; // HSTOP: Horizontal frame stop (high 8 bits)
    SET_OV7670 + 9  : LUT_DATA = 16'h1902; // VSTART: Vertical frame start (high 8 bits)
    SET_OV7670 + 10 : LUT_DATA = 16'h1A7A; // VSTOP: Vertical frame stop (high 8 bits)
    SET_OV7670 + 11 : LUT_DATA = 16'h030A; // VREF: Vertical frame control (lower bits of start/stop)
    SET_OV7670 + 12 : LUT_DATA = 16'h0C00; // COM3: Disable scaling (DCW off)
    SET_OV7670 + 13 : LUT_DATA = 16'h3E00; // COM14: PCLK scaling (00 = no division)
    SET_OV7670 + 14 : LUT_DATA = 16'h7000; // Scaling control X (normal mode)
    SET_OV7670 + 15 : LUT_DATA = 16'h7100; // Scaling control Y (normal mode)
    SET_OV7670 + 16 : LUT_DATA = 16'h7211; // Downsampling control (horizontal/vertical)
    SET_OV7670 + 17 : LUT_DATA = 16'h7300; // DSP clock divider (no division)
    SET_OV7670 + 18 : LUT_DATA = 16'hA202; // DSP control: frame timing delay
    SET_OV7670 + 19 : LUT_DATA = 16'h1180; // CLKRC: Use external clock source directly
    SET_OV7670 + 20 : LUT_DATA = 16'h7A20; // Gamma curve start
    SET_OV7670 + 21 : LUT_DATA = 16'h7B1C;
    SET_OV7670 + 22 : LUT_DATA = 16'h7C28;
    SET_OV7670 + 23 : LUT_DATA = 16'h7D3C;
    SET_OV7670 + 24 : LUT_DATA = 16'h7E55;
    SET_OV7670 + 25 : LUT_DATA = 16'h7F68;
    SET_OV7670 + 26 : LUT_DATA = 16'h8076;
    SET_OV7670 + 27 : LUT_DATA = 16'h8180;
    SET_OV7670 + 28 : LUT_DATA = 16'h8288;
    SET_OV7670 + 29 : LUT_DATA = 16'h838F;
    SET_OV7670 + 30 : LUT_DATA = 16'h8496;
    SET_OV7670 + 31 : LUT_DATA = 16'h85A3;
    SET_OV7670 + 32 : LUT_DATA = 16'h86AF;
    SET_OV7670 + 33 : LUT_DATA = 16'h87C4;
    SET_OV7670 + 34 : LUT_DATA = 16'h88D7;
    SET_OV7670 + 35 : LUT_DATA = 16'h89E8; // Gamma curve end

    SET_OV7670 + 36 : LUT_DATA = 16'h13FF; // COM8: Enable AGC, AWB, AEC (auto gain, white balance, exposure)
    SET_OV7670 + 37 : LUT_DATA = 16'h0000; // Gain control reset
    SET_OV7670 + 38 : LUT_DATA = 16'h1000; // Exposure control reset
    SET_OV7670 + 39 : LUT_DATA = 16'h0D00; // Reserved / system control
    SET_OV7670 + 40 : LUT_DATA = 16'h144E; // COM9: Gain ceiling
    SET_OV7670 + 41 : LUT_DATA = 16'hA505; // Banding filter / exposure settings
    SET_OV7670 + 42 : LUT_DATA = 16'hAB07; // Banding filter
    SET_OV7670 + 43 : LUT_DATA = 16'h2475; // AGC/AEC parameters
    SET_OV7670 + 44 : LUT_DATA = 16'h2563;
    SET_OV7670 + 45 : LUT_DATA = 16'h26A5;
    SET_OV7670 + 46 : LUT_DATA = 16'h9F78; // AWB control
    SET_OV7670 + 47 : LUT_DATA = 16'hA068;
    SET_OV7670 + 48 : LUT_DATA = 16'hA103;
    SET_OV7670 + 49 : LUT_DATA = 16'hA6DF;
    SET_OV7670 + 50 : LUT_DATA = 16'hA7DF;
    SET_OV7670 + 51 : LUT_DATA = 16'hA8F0;
    SET_OV7670 + 52 : LUT_DATA = 16'hA990;
    SET_OV7670 + 53 : LUT_DATA = 16'hAA94;

    SET_OV7670 + 55 : LUT_DATA = 16'h0E61; // COM5: system clock settings
    SET_OV7670 + 56 : LUT_DATA = 16'h0F4B; // COM6: system control
    SET_OV7670 + 57 : LUT_DATA = 16'h1602; // Reserved / internal control

    SET_OV7670 + 58 : LUT_DATA = 16'h2102; // ADC control
    SET_OV7670 + 59 : LUT_DATA = 16'h2291;
    SET_OV7670 + 60 : LUT_DATA = 16'h2907;
    SET_OV7670 + 61 : LUT_DATA = 16'h330B;
    SET_OV7670 + 62 : LUT_DATA = 16'h350B;
    SET_OV7670 + 63 : LUT_DATA = 16'h373F;
    SET_OV7670 + 64 : LUT_DATA = 16'h3801;
    SET_OV7670 + 65 : LUT_DATA = 16'h3900;
    SET_OV7670 + 66 : LUT_DATA = 16'h3C78;
    SET_OV7670 + 67 : LUT_DATA = 16'h4D40;
    SET_OV7670 + 68 : LUT_DATA = 16'h4E20;
    SET_OV7670 + 69 : LUT_DATA = 16'h6900;

    SET_OV7670 + 70 : LUT_DATA = 16'h7419; // Edge enhancement / DSP control
    SET_OV7670 + 71 : LUT_DATA = 16'h8D4F;
    SET_OV7670 + 72 : LUT_DATA = 16'h8E00;
    SET_OV7670 + 73 : LUT_DATA = 16'h8F00;
    SET_OV7670 + 74 : LUT_DATA = 16'h9000;
    SET_OV7670 + 75 : LUT_DATA = 16'h9100;
    SET_OV7670 + 76 : LUT_DATA = 16'h9200;
    SET_OV7670 + 77 : LUT_DATA = 16'h9600;
    SET_OV7670 + 78 : LUT_DATA = 16'h9A80;
    SET_OV7670 + 79 : LUT_DATA = 16'hB084;
    SET_OV7670 + 80 : LUT_DATA = 16'hB10C;
    SET_OV7670 + 81 : LUT_DATA = 16'hB20E;
    SET_OV7670 + 82 : LUT_DATA = 16'hB382;
    SET_OV7670 + 83 : LUT_DATA = 16'hB80A;

    SET_OV7670 + 84 : LUT_DATA = 16'h4314; // Color matrix / saturation
    SET_OV7670 + 85 : LUT_DATA = 16'h44F0;
    SET_OV7670 + 86 : LUT_DATA = 16'h4534;
    SET_OV7670 + 87 : LUT_DATA = 16'h4658;
    SET_OV7670 + 88 : LUT_DATA = 16'h4728;
    SET_OV7670 + 89 : LUT_DATA = 16'h483A;
    SET_OV7670 + 90 : LUT_DATA = 16'h5988;
    SET_OV7670 + 91 : LUT_DATA = 16'h5A88;
    SET_OV7670 + 92 : LUT_DATA = 16'h5B44;
    SET_OV7670 + 93 : LUT_DATA = 16'h5C67;
    SET_OV7670 + 94 : LUT_DATA = 16'h5D49;
    SET_OV7670 + 95 : LUT_DATA = 16'h5E0E;

    SET_OV7670 + 96 : LUT_DATA = 16'h6404;
    SET_OV7670 + 97 : LUT_DATA = 16'h6520;
    SET_OV7670 + 98 : LUT_DATA = 16'h6605;
    SET_OV7670 + 99 : LUT_DATA = 16'h9404;
    SET_OV7670 + 100: LUT_DATA = 16'h9508;

    SET_OV7670 + 101: LUT_DATA = 16'h6C0A;
    SET_OV7670 + 102: LUT_DATA = 16'h6D55;
    SET_OV7670 + 103: LUT_DATA = 16'h6E11;
    SET_OV7670 + 104: LUT_DATA = 16'h6F9F;
    SET_OV7670 + 105: LUT_DATA = 16'h6A40;
    SET_OV7670 + 106: LUT_DATA = 16'h0140;
    SET_OV7670 + 107: LUT_DATA = 16'h0240;

    SET_OV7670 + 109: LUT_DATA = 16'h1500; // COM10: sync signal settings

    SET_OV7670 + 110: LUT_DATA = 16'h4F80; // Color matrix coefficients
    SET_OV7670 + 111: LUT_DATA = 16'h5080;
    SET_OV7670 + 112: LUT_DATA = 16'h5100;
    SET_OV7670 + 113: LUT_DATA = 16'h5222;
    SET_OV7670 + 114: LUT_DATA = 16'h535E;
    SET_OV7670 + 115: LUT_DATA = 16'h5480;
    SET_OV7670 + 116: LUT_DATA = 16'h589E;

    SET_OV7670 + 117: LUT_DATA = 16'h4108;
    SET_OV7670 + 118: LUT_DATA = 16'h3F00;
    SET_OV7670 + 119: LUT_DATA = 16'h7505;
    SET_OV7670 + 120: LUT_DATA = 16'h76E1;
    SET_OV7670 + 121: LUT_DATA = 16'h4C00;
    SET_OV7670 + 122: LUT_DATA = 16'h7701;

    SET_OV7670 + 123: LUT_DATA = 16'h4B09;
    SET_OV7670 + 124: LUT_DATA = 16'hC9F0; // DSP tuning
    SET_OV7670 + 125: LUT_DATA = 16'h4138;
    SET_OV7670 + 126: LUT_DATA = 16'h5640;

    SET_OV7670 + 127: LUT_DATA = 16'h3411;
    SET_OV7670 + 128: LUT_DATA = 16'h3B02;
    SET_OV7670 + 129: LUT_DATA = 16'hA489;

    SET_OV7670 + 130: LUT_DATA = 16'h9600;
    SET_OV7670 + 131: LUT_DATA = 16'h9730;
    SET_OV7670 + 132: LUT_DATA = 16'h9820;
    SET_OV7670 + 133: LUT_DATA = 16'h9930;
    SET_OV7670 + 134: LUT_DATA = 16'h9A84;
    SET_OV7670 + 135: LUT_DATA = 16'h9B29;
    SET_OV7670 + 136: LUT_DATA = 16'h9C03;
    SET_OV7670 + 137: LUT_DATA = 16'h9D4C;
    SET_OV7670 + 138: LUT_DATA = 16'h9E3F;

    SET_OV7670 + 139: LUT_DATA = 16'h7804;

    // Advanced DSP tuning sequence (internal undocumented registers)
    SET_OV7670 + 140: LUT_DATA = 16'h7901;
    SET_OV7670 + 141: LUT_DATA = 16'hC8F0;
    SET_OV7670 + 142: LUT_DATA = 16'h790F;
    SET_OV7670 + 143: LUT_DATA = 16'hC800;
    SET_OV7670 + 144: LUT_DATA = 16'h7910;
    SET_OV7670 + 145: LUT_DATA = 16'hC87E;
    SET_OV7670 + 146: LUT_DATA = 16'h790A;
    SET_OV7670 + 147: LUT_DATA = 16'hC880;
    SET_OV7670 + 148: LUT_DATA = 16'h790B;
    SET_OV7670 + 149: LUT_DATA = 16'hC801;
    SET_OV7670 + 150: LUT_DATA = 16'h790C;
    SET_OV7670 + 151: LUT_DATA = 16'hC80F;
    SET_OV7670 + 152: LUT_DATA = 16'h790D;
    SET_OV7670 + 153: LUT_DATA = 16'hC820;
    SET_OV7670 + 154: LUT_DATA = 16'h7909;
    SET_OV7670 + 155: LUT_DATA = 16'hC880;
    SET_OV7670 + 156: LUT_DATA = 16'h7902;
    SET_OV7670 + 157: LUT_DATA = 16'hC8C0;
    SET_OV7670 + 158: LUT_DATA = 16'h7903;
    SET_OV7670 + 159: LUT_DATA = 16'hC840;
    SET_OV7670 + 160: LUT_DATA = 16'h7905;
    SET_OV7670 + 161: LUT_DATA = 16'hC830;
    SET_OV7670 + 162: LUT_DATA = 16'h7926;

    SET_OV7670 + 163: LUT_DATA = 16'h0903;
    SET_OV7670 + 164: LUT_DATA = 16'h3B42;

    default: LUT_DATA = 0;

    endcase
end

endmodule