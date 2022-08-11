module clk_div (input logic clk, input logic rst, output logic clk_en);

   logic [23:0] clk_count;

   always_ff @(posedge clk) begin
      if (rst)
	clk_count <= 24'h0;
      else
	clk_count <= clk_count + 1;
   end   
   
   assign clk_en = clk_count[23];
   
endmodule // clk_div
