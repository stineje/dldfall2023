module fa (Cout, Sum, A, B, Cin);

   input logic  A;
   input logic  B;
   input logic  Cin;

   output logic Sum;
   output logic Cout;

   logic 	g1, g2, temp1;   
   
   ha ha1 (g1, temp1, A, B);
   ha ha2 (g2, Sum, temp1, Cin);

   assign Cout = g1 | g2;

endmodule // fa

