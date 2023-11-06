module ring_counter (input logic clk, reset, output logic [1:0] count_out);

   logic  [1:0] count = 0;
   
   flopr #(2) countflop (clk, reset, count, count_out);
   always_ff @(*)
     count <= count_out + 1;
   
endmodule // ring_counter


