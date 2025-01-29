`timescale 1ns / 1ps

module vga_sync_gen (
    input  wire        clk_50MHz,   // 50 MHz reference clock
    input  wire        reset,       // asynchronous reset (active high)
    output wire        pixel_clk,   // ~25 MHz pixel clock
    output wire        hsync,       // horizontal sync
    output wire        vsync,       // vertical sync
    output wire        video_active,// high during visible region
    output reg  [7:0]  pixel_r,     // red component (8 bits)
    output reg  [7:0]  pixel_g,     // green component (8 bits)
    output reg  [7:0]  pixel_b      // blue component (8 bits)
);

//-----------------------------------------------------------------
// 1) Generate a ~25 MHz pixel clock from 50 MHz
//-----------------------------------------------------------------
reg clk_div = 1'b0;

always @(posedge clk_50MHz or posedge reset) begin
    if (reset) 
        clk_div <= 1'b0;
    else
        clk_div <= ~clk_div;
end

// Pixel clock is 50 MHz / 2 = ~25 MHz
assign pixel_clk = clk_div;

//-----------------------------------------------------------------
// 2) Define VGA timing parameters for 640x480 @ 60 Hz
//-----------------------------------------------------------------
// Horizontal timing (in pixels)
localparam H_DISPLAY = 640;   // visible area
localparam H_FRONT   = 16;    // front porch
localparam H_SYNC    = 96;    // sync pulse
localparam H_BACK    = 48;    // back porch
localparam H_TOTAL   = H_DISPLAY + H_FRONT + H_SYNC + H_BACK; // 800

// Vertical timing (in lines)
localparam V_DISPLAY = 480;   // visible area
localparam V_FRONT   = 10;    // front porch
localparam V_SYNC    = 2;     // sync pulse
localparam V_BACK    = 33;    // back porch
localparam V_TOTAL   = V_DISPLAY + V_FRONT + V_SYNC + V_BACK; // 525

//-----------------------------------------------------------------
// 3) Horizontal and Vertical Counters
//-----------------------------------------------------------------
reg [9:0] h_count = 0; // enough bits to count up to 800
reg [9:0] v_count = 0; // enough bits to count up to 525

always @(posedge pixel_clk or posedge reset) begin
    if (reset) begin
        h_count <= 0;
        v_count <= 0;
    end
    else begin
        // Increment horizontal counter
        if (h_count == (H_TOTAL - 1)) begin
            h_count <= 0;
            // When we wrap horizontal, increment vertical
            if (v_count == (V_TOTAL - 1))
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end 
        else begin
            h_count <= h_count + 1;
        end
    end
end

//-----------------------------------------------------------------
// 4) Generate hsync and vsync signals (typically active low)
//-----------------------------------------------------------------
assign hsync = ~((h_count >= (H_DISPLAY + H_FRONT)) &&
                 (h_count <  (H_DISPLAY + H_FRONT + H_SYNC)));

assign vsync = ~((v_count >= (V_DISPLAY + V_FRONT)) &&
                 (v_count <  (V_DISPLAY + V_FRONT + V_SYNC)));

//-----------------------------------------------------------------
// 5) Video active region
//-----------------------------------------------------------------
assign video_active = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);

//-----------------------------------------------------------------
// 6) Generate Horizontal Color Bars
//-----------------------------------------------------------------
// We'll divide the 640 active pixels into 8 bars (each 80 pixels wide).
// Each bar has a distinct color. When not in the active region, output black.
always @(*) begin
    // Default to black
    pixel_r = 8'd0;
    pixel_g = 8'd0;
    pixel_b = 8'd0;

    if (video_active) begin
        // Which bar are we in horizontally?
        if      (h_count < 80)  begin
            // White
            pixel_r = 8'hFF;
            pixel_g = 8'hFF;
            pixel_b = 8'hFF;
        end
        else if (h_count < 160) begin
            // Yellow
            pixel_r = 8'hFF;
            pixel_g = 8'hFF;
            pixel_b = 8'h00;
        end
        else if (h_count < 240) begin
            // Cyan
            pixel_r = 8'h00;
            pixel_g = 8'hFF;
            pixel_b = 8'hFF;
        end
        else if (h_count < 320) begin
            // Green
            pixel_r = 8'h00;
            pixel_g = 8'hFF;
            pixel_b = 8'h00;
        end
        else if (h_count < 400) begin
            // Magenta
            pixel_r = 8'hFF;
            pixel_g = 8'h00;
            pixel_b = 8'hFF;
        end
        else if (h_count < 480) begin
            // Red
            pixel_r = 8'hFF;
            pixel_g = 8'h00;
            pixel_b = 8'h00;
        end
        else if (h_count < 560) begin
            // Blue
            pixel_r = 8'h00;
            pixel_g = 8'h00;
            pixel_b = 8'hFF;
        end
        else if (h_count < 640) begin
            // Black
            pixel_r = 8'h00;
            pixel_g = 8'h00;
            pixel_b = 8'h00;
        end
    end
end

endmodule
