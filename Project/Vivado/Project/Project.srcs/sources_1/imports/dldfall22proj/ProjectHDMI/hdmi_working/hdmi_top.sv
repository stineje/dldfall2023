module hdmi_top (n2,CLK_125MHZ, HDMI_TX, HDMI_TX_N, HDMI_CLK, 
		 HDMI_CLK_N, HDMI_CEC, HDMI_SDA, HDMI_SCL, HDMI_HPD);
		 
   input  logic [63:0] n2;
   input logic         CLK_125MHZ;   

   // HDMI output
   output logic [2:0]  HDMI_TX;   
   output logic [2:0]  HDMI_TX_N;   
   output logic        HDMI_CLK;   
   output logic	       HDMI_CLK_N;
   
   input logic	       HDMI_CEC;   
   inout logic	       HDMI_SDA;   
   inout logic	       HDMI_SCL;   
   input logic	       HDMI_HPD;

   logic 	           clk_pixel_x5;
   logic 	           clk_pixel;
   logic 	           clk_audio;
   logic [7:0] 	       DataIn; // RGB Data to HDMI
   
   hdmi_pll_xilinx hdmi_pll (.clk_in1(CLK_125MHZ), .clk_out1(clk_pixel), .clk_out2(clk_pixel_x5));
   
   logic [10:0]        counter = 1'd0;
   always_ff @(posedge clk_pixel)
     begin
	counter <= counter == 11'd1546 ? 1'd0 : counter + 1'd1;
     end
   assign clk_audio = clk_pixel && counter == 11'd1546;
   
   localparam AUDIO_BIT_WIDTH = 16;
   localparam AUDIO_RATE = 48000;
   localparam WAVE_RATE = 480;

   // This is to avoid giving you a heart attack -- it'll be really loud if it uses the full dynamic range.   
   logic [AUDIO_BIT_WIDTH-1:0] audio_sample_word;
   logic [AUDIO_BIT_WIDTH-1:0] audio_sample_word_dampened; 
   assign audio_sample_word_dampened = audio_sample_word >> 9;
   
   //sawtooth #(.BIT_WIDTH(AUDIO_BIT_WIDTH), .SAMPLE_RATE(AUDIO_RATE), 
   //.WAVE_RATE(WAVE_RATE)) sawtooth (.clk_audio(clk_audio), .level(audio_sample_word));

   logic [23:0] 	   rgb;
   logic [9:0] 		   cx, cy;
   logic [2:0] 		   tmds;
   logic 		       tmds_clock;
   
   hdmi #(.VIDEO_ID_CODE(4), .VIDEO_REFRESH_RATE(60.0), .AUDIO_RATE(AUDIO_RATE), 
	  .AUDIO_BIT_WIDTH(AUDIO_BIT_WIDTH)) 
   hdmi(.clk_pixel_x5(clk_pixel_x5), .clk_pixel(clk_pixel), .clk_audio(clk_audio), 
	.rgb(DataIn), .audio_sample_word('{audio_sample_word_dampened, audio_sample_word_dampened}), 
	.tmds(tmds), .tmds_clock(tmds_clock), .cx(cx), .cy(cy));

   genvar 		       i;
   generate
      for (i = 0; i < 3; i++)
	  begin: obufds_gen
        OBUFDS #(.IOSTANDARD("TMDS_33")) obufds (.I(tmds[i]), .O(HDMI_TX[i]), .OB(HDMI_TX_N[i]));
	  end
      OBUFDS #(.IOSTANDARD("TMDS_33")) obufds_clock(.I(tmds_clock), .O(HDMI_CLK), .OB(HDMI_CLK_N));
   endgenerate
   
   /*   logic [7:0] character = 8'h30;
   logic [5:0] prevcy = 6'd0;
   always @(posedge clk_pixel)
     begin
	if (cy == 10'd0)
	  begin
             character <= 8'h30;
             prevcy <= 6'd0;
	  end
	else if (prevcy != cy[9:4])
	  begin
             character <= character + 8'h01;
             prevcy <= cy[9:4];
	  end
     end */
   
   // console console(.clk_pixel(clk_pixel), .codepoint(character), 
   //		   .attribute({cx[9], cy[8:6], cx[8:5]}), .cx(cx), .cy(cy), .rgb(rgb));
   
   
   // Game of Life screen configuration
   // Skip each block
   parameter    SKIP = 10; 
   // Distance to each block to block
   parameter	SEGMENT = 50;
   // Starting position (START,START)
   parameter	START = 270;   
   
   always @(posedge CLK_125MHZ)
     begin	
       
	if (cy < START)
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// First Row 
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START) && (cx <= START+SEGMENT*1-SKIP))
	  if (n2[63] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
	  if (n2[62] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
	  if (n2[61] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
	  if (n2[60] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
	  if (n2[59] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
	  if (n2[58] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
	  if (n2[57] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
	  if (n2[56] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	// Beginning/End of Row
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx < START))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx > START+SEGMENT*8))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Skip Row
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*1-SKIP) && (cy <= START+SEGMENT*1))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Second Row		
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START) && (cx <= START+SEGMENT*1-SKIP))
	  if (n2[55] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
		 
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
	  if (n2[54] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
	  if (n2[53] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
	  if (n2[52] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
	  if (n2[51] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
	  if (n2[50] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
	  if (n2[49] == 0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
	  if (n2[48] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx < START))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx > START+SEGMENT*8))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Skip Row
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*2-SKIP) && (cy <= START+SEGMENT*2))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Thrid Row
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START) && (cx <= START+SEGMENT*1-SKIP))
	  if (n2[47] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
	  if (n2[46] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
	  if (n2[45] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
	  if (n2[44] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
	  if (n2[43] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
	  if (n2[42] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
	  if (n2[41] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
	  if (n2[40] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx < START))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx > START+SEGMENT*8))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Skip Row
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*3-SKIP) && (cy <= START+SEGMENT*3))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Fourth Row
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START) && (cx <= START+SEGMENT*1-SKIP))
	  if (n2[39] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
	  if (n2[38] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
	  if (n2[37] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
	  if (n2[36] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
	  if (n2[35] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
	  if (n2[34] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
	  if (n2[33] == 0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
	  if (n2[32] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx < START))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx > START+SEGMENT*8))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Skip Row
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*4-SKIP) && (cy <= START+SEGMENT*4))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Fifth Row
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START) && (cx <= START+SEGMENT*1-SKIP))
	  if (n2[31] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
		 
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
	  if (n2[30] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
		 
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
	  if (n2[29] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	 
		 
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
	  if (n2[28] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
	  if (n2[27] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
	  if (n2[26] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
	  if (n2[25] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
	  if (n2[24] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx < START))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx > START+SEGMENT*8))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Skip Row
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*5-SKIP) && (cy <= START+SEGMENT*5))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Sixth Row
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START) && (cx <= START+SEGMENT*1-SKIP))
	  if (n2[23] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
		 
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
	  if (n2[22] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
		 
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
	  if (n2[21] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
		 
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
	  if (n2[20] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
	  if (n2[19] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
	  if (n2[18] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
	  if (n2[17] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
	  if (n2[16] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx < START))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx > START+SEGMENT*8))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Skip Row
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*6-SKIP) && (cy <= START+SEGMENT*6))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Seventh Row
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START) && (cx <= START+SEGMENT*1-SKIP))
	  if (n2[15] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
		 
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
	  if (n2[14] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
		 
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
	  if (n2[13] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
		 
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
	  if (n2[12] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
	  if (n2[11] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
	  if (n2[10] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
	  if (n2[9] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
		 
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
	  if (n2[8] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx < START))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx > START+SEGMENT*8))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Skip Row
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*7-SKIP) && (cy <= START+SEGMENT*7))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Eighth Row
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START) && (cx <= START+SEGMENT*1-SKIP))
	  if (n2[7] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
	  if (n2[6] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
	  if (n2[5] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
	  if (n2[4] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
	  if (n2[3] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
	  if (n2[2] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
	  if (n2[1] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
	  if (n2[0] == 1'b0)
	    DataIn <= {8'h00, 8'h00, 8'hFF};
	  else 
	    DataIn <= {8'hFF, 8'h00, 8'h00};	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx < START))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx > START+SEGMENT*8))
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Skip Row
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
	  DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
	  DataIn <= {8'h00, 8'h00, 8'h00};	

	// Skip
	if (cy >= START+SEGMENT*8-SKIP)
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
     end
     
endmodule // hdmi_top



