module all(reset, clk, n2);
   
   input logic         clk;
   input logic 	       reset;
   
   output logic [63:0] n2;
   
   logic [63:0]        start_state;
   logic [63:0]        n1;
   
   logic [63:0]        n3;
   logic 	       n4;
   
   
   assign start_state = 64'h0C_12_74_34_10_34_3C_28;
   
   fsm fm (clk, reset, n4, CURRENT_STATE, NEXT_STATE);
   mux mx (start_state, n2, n4, n1);
   datapath dp (n1, n3);
   register rges (!clk, n3, n2);
   
endmodule // all

