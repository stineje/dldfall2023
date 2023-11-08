module hdmi_top (n2,CLK_125MHZ, HDMI_TX, HDMI_TX_N, HDMI_CLK, 
		 HDMI_CLK_N, HDMI_CEC, HDMI_SDA, HDMI_SCL, HDMI_HPD);
		 
   input  logic [255:0] n2;
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
   logic [23:0] 	      DataIn; // RGB Data to HDMI
   
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
   logic [10:0] 		   cx, cy;
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
   parameter    SKIP = 5; 
   // Distance to each block to block
   parameter	SEGMENT = 25;
   // Starting position (START,START)
   parameter	START = 270;   
   
   // Color Choice
   logic [23:0] alive, dead;
   assign alive = {8'hFF, 8'hFF, 8'h00};
   assign dead  = {8'h00, 8'h00, 8'hFF};

   always @(posedge CLK_125MHZ)
     begin	
       
	if (cy < START)
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 1st Row
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[255] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[254] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[253] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[252] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[251] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[250] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[249] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[248] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[247] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[246] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[245] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[244] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[243] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[242] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[241] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[240] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*0) && (cy <= START+SEGMENT*1-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*1-SKIP) && (cy <= START+SEGMENT*1))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 2nd Row
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[239] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[238] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[237] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[236] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[235] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[234] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[233] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[232] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[231] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[230] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[229] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[228] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[227] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[226] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[225] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[224] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
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
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*1) && (cy <= START+SEGMENT*2-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*2-SKIP) && (cy <= START+SEGMENT*2))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 3rd Row
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[223] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[222] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[221] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[220] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[219] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[218] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[217] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[216] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[215] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[214] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[213] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[212] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[211] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[210] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[209] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[208] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
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
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*2) && (cy <= START+SEGMENT*3-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*3-SKIP) && (cy <= START+SEGMENT*3))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 4th Row
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[207] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[206] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[205] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[204] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[203] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[202] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[201] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[200] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[199] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[198] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[197] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[196] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[195] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[194] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[193] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[192] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
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
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*3) && (cy <= START+SEGMENT*4-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*4-SKIP) && (cy <= START+SEGMENT*4))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 5th Row
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[191] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[190] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[189] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[188] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[187] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[186] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[185] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[184] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[183] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[182] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[181] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[180] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[179] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[178] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[177] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[176] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
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
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*4) && (cy <= START+SEGMENT*5-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*5-SKIP) && (cy <= START+SEGMENT*5))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 6th Row
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[175] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[174] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[173] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[172] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[171] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[170] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[169] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[168] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[167] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[166] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[165] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[164] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[163] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[162] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[161] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[160] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
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
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*5) && (cy <= START+SEGMENT*6-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*6-SKIP) && (cy <= START+SEGMENT*6))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 7th Row
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[159] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[158] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[157] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[156] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[155] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[154] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[153] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[152] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[151] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[150] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[149] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[148] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[147] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[146] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[145] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[144] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
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
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*6) && (cy <= START+SEGMENT*7-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*7-SKIP) && (cy <= START+SEGMENT*7))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 8th Row
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[143] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[142] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[141] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[140] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[139] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[138] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[137] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[136] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[135] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[134] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[133] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[132] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[131] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[130] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[129] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[128] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
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
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*7) && (cy <= START+SEGMENT*8-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*8-SKIP) && (cy <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 9th Row
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[127] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[126] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[125] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[124] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[123] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[122] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[121] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[120] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[119] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[118] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[117] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[116] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[115] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[114] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[113] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[112] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*8) && (cy <= START+SEGMENT*9-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*9-SKIP) && (cy <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 10th Row
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[111] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[110] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[109] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[108] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[107] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[106] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[105] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[104] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[103] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[102] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[101] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[100] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[99] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[98] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[97] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[96] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*9) && (cy <= START+SEGMENT*10-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*10-SKIP) && (cy <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 11th Row
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[95] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[94] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[93] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[92] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[91] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[90] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[89] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[88] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[87] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[86] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[85] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[84] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[83] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[82] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[81] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[80] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*10) && (cy <= START+SEGMENT*11-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*11-SKIP) && (cy <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 12th Row
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[79] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[78] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[77] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[76] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[75] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[74] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[73] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[72] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[71] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[70] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[69] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[68] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[67] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[66] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[65] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[64] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*11) && (cy <= START+SEGMENT*12-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*12-SKIP) && (cy <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 13th Row
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[63] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[62] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[61] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[60] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[59] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[58] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[57] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[56] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[55] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[54] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[53] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[52] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[51] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[50] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[49] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[48] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*12) && (cy <= START+SEGMENT*13-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*13-SKIP) && (cy <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 14th Row
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[47] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[46] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[45] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[44] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[43] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[42] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[41] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[40] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[39] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[38] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[37] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[36] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[35] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[34] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[33] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[32] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*13) && (cy <= START+SEGMENT*14-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*14-SKIP) && (cy <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 15th Row
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[31] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[30] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[29] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[28] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[27] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[26] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[25] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[24] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[23] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[22] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[21] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[20] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[19] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[18] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[17] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[16] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*14) && (cy <= START+SEGMENT*15-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*15-SKIP) && (cy <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// 16th Row
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*0) && (cx <= START+SEGMENT*1-SKIP))
		if (n2[15] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*1) && (cx <= START+SEGMENT*2-SKIP))
		if (n2[14] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*2) && (cx <= START+SEGMENT*3-SKIP))
		if (n2[13] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*3) && (cx <= START+SEGMENT*4-SKIP))
		if (n2[12] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*4) && (cx <= START+SEGMENT*5-SKIP))
		if (n2[11] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*5) && (cx <= START+SEGMENT*6-SKIP))
		if (n2[10] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*6) && (cx <= START+SEGMENT*7-SKIP))
		if (n2[9] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*7) && (cx <= START+SEGMENT*8-SKIP))
		if (n2[8] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*8) && (cx <= START+SEGMENT*9-SKIP))
		if (n2[7] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*9) && (cx <= START+SEGMENT*10-SKIP))
		if (n2[6] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*10) && (cx <= START+SEGMENT*11-SKIP))
		if (n2[5] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*11) && (cx <= START+SEGMENT*12-SKIP))
		if (n2[4] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*12) && (cx <= START+SEGMENT*13-SKIP))
		if (n2[3] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*13) && (cx <= START+SEGMENT*14-SKIP))
		if (n2[2] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*14) && (cx <= START+SEGMENT*15-SKIP))
		if (n2[1] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	if((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*15) && (cx <= START+SEGMENT*16-SKIP))
		if (n2[0] == 1'b0)
			DataIn <= dead;
		else
			DataIn <= alive;
	
	
	// Beginning/End of Row
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx < START))
		DataIn <= {8'h00, 8'h00, 8'h00};
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx > START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	//  Skip Row
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*1-SKIP) && (cx <= START+SEGMENT*1))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*2-SKIP) && (cx <= START+SEGMENT*2))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*3-SKIP) && (cx <= START+SEGMENT*3))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*4-SKIP) && (cx <= START+SEGMENT*4))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*5-SKIP) && (cx <= START+SEGMENT*5))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*6-SKIP) && (cx <= START+SEGMENT*6))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*7-SKIP) && (cx <= START+SEGMENT*7))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*8-SKIP) && (cx <= START+SEGMENT*8))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*9-SKIP) && (cx <= START+SEGMENT*9))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*10-SKIP) && (cx <= START+SEGMENT*10))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*11-SKIP) && (cx <= START+SEGMENT*11))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*12-SKIP) && (cx <= START+SEGMENT*12))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*13-SKIP) && (cx <= START+SEGMENT*13))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*14-SKIP) && (cx <= START+SEGMENT*14))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*15-SKIP) && (cx <= START+SEGMENT*15))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	if ((cy >= START+SEGMENT*15) && (cy <= START+SEGMENT*16-SKIP) && (cx >= START+SEGMENT*16-SKIP) && (cx <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};	
	
	// Skip Column
	if ((cy >= START+SEGMENT*16-SKIP) && (cy <= START+SEGMENT*16))
		DataIn <= {8'h00, 8'h00, 8'h00};
	
	// Skip
	if (cy >= START+SEGMENT*16-SKIP)
	  DataIn <= {8'h00, 8'h00, 8'h00};
	
     end
     
endmodule // hdmi_top



