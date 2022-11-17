module mux (d0, d1, s, y);

   input logic [63:0]  d0, d1;
   input logic 	       s;
   output logic [63:0] y;
   
   assign y = s ? d1 : d0;
   
endmodule // mux


