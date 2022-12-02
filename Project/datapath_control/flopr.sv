// synchronously resettable flip flop
module flopr(input  logic       clk,
             input  logic       reset, 
             input  logic [7:0] d, 
             output logic [7:0] q);

  // asynchronous reset (similar to HDL Example 4.19)
  always_ff @(posedge clk, posedge reset)
     if (reset) q <= 8'b0;
     else       q <= d;
   
endmodule // flopr

