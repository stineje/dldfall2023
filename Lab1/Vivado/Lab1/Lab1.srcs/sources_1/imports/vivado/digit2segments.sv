`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/25/2021 05:54:17 PM
// Design Name: 
// Module Name: digit2segments
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module digit2segments(
  input  logic [3:0] digit,
  output logic [6:0] segments
);

always_comb
  begin
    case(digit)
    //| DIGIT |             | GFE_DCBA |
      4'b0000 : segments = 7'b100_0000;
      4'b0001 : segments = 7'b111_1001;
      4'b0010 : segments = 7'b010_0100;
      4'b0011 : segments = 7'b011_0000;
      4'b0100 : segments = 7'b001_1001;
      4'b0101 : segments = 7'b001_0010;
      4'b0110 : segments = 7'b000_0010;
      4'b0111 : segments = 7'b111_1000;
      4'b1000 : segments = 7'b000_0000;
      4'b1001 : segments = 7'b001_0000;
      4'b1010 : segments = 7'b000_1000;
      4'b1011 : segments = 7'b000_0011;
      4'b1100 : segments = 7'b100_0110;
      4'b1101 : segments = 7'b010_0001;
      4'b1110 : segments = 7'b000_0110;
      4'b1111 : segments = 7'b000_1110;
      default : segments = 7'b111_1111;
    endcase
  end

endmodule
