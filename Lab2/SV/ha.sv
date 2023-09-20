module ha (Cout, Sum, A, B);

   input logic  A;
   input logic  B;

   output logic Cout;
   output logic Sum;

   assign Cout = A & B;   

   assign Sum = (~(Cout)) & (A | B);

endmodule // ha

