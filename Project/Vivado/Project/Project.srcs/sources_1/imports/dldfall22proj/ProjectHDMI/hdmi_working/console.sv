module console # (
    parameter BIT_WIDTH = 12,
    parameter BIT_HEIGHT = 11,
    parameter FONT_WIDTH = 8,
    parameter FONT_HEIGHT = 16
) (
    input logic 		 clk_pixel,
    input logic [7:0] 		 codepoint,
    input logic [7:0] 		 attribute,
    input logic [BIT_WIDTH-1:0]  cx,
    input logic [BIT_HEIGHT-1:0] cy,
    output logic [23:0] 	 rgb = 24'd0
);

   logic [127:0]      glyph;
   glyphmap glyphmap(.codepoint(codepoint), .glyph(glyph));

   logic [23:0]       fgrgb, bgrgb;
   logic 	      blink;
   attributemap attributemap(.attribute(attribute), .fgrgb(fgrgb), .bgrgb(bgrgb), .blink(blink));

   logic [BIT_HEIGHT-1:0] prevcy = 0;
   logic [$clog2(FONT_HEIGHT)-1:0] vindex = 0;
   logic [$clog2(FONT_WIDTH)-1:0]  hindex = 0;
   logic [5:0] 			   blink_timer = 0;

   always @(posedge clk_pixel)
     begin
	if (cx == 0 && cy == 0)
	  begin
             prevcy <= 0;
             vindex <= 0;
             hindex <= 0;
             blink_timer <= blink_timer + 1'b1;
	  end
	else if (prevcy != cy)
	  begin
             prevcy <= cy;
             vindex <= vindex == FONT_HEIGHT - 1 ? 1'b0 : vindex + 1'b1;
             hindex <= 0;
	  end
	else
	  begin
             hindex <= hindex == FONT_WIDTH - 1 ? 1'b0 : hindex + 1'b1;
	  end

  if (blink && blink_timer[5])
          rgb <= bgrgb;
	else
          rgb <= glyph[{~vindex, ~hindex}] ? fgrgb : bgrgb;
     end // always @ (posedge clk_pixel)
   
endmodule
