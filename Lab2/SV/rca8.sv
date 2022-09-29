module rca8 (Sum, A, B, Cin);

   input logic [7:0]  A;
   input logic [7:0]  B;
   input logic 	      Cin;   
   
   output logic [7:0] Sum;

   logic 	      c0, c1, c2, c3, c4, c5, c6, c7;   

   fa cpa1 (c0, Sum[0], A[0], B[0], Cin);
   fa cpa2 (c1, Sum[1], A[1], B[1], c0);
   fa cpa3 (c2, Sum[2], A[2], B[2], c1);
   fa cpa4 (c3, Sum[3], A[3], B[3], c1);
   fa cpa5 (c4, Sum[4], A[4], B[4], c3);
   fa cpa6 (c5, Sum[5], A[5], B[5], c4);
   fa cpa7 (c6, Sum[6], A[6], B[6], c5);
   fa cpa8 (c7, Sum[7], A[7], B[7], c6);   

endmodule // rca8
