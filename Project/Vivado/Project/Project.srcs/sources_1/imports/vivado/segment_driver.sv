`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/25/2021 05:02:22 PM
// Design Name: 
// Module Name: segment_driver
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


module segment_driver(
  input  logic clk,
  input  logic rst,
  input  logic [3:0] digit0,
  input  logic [3:0] digit1,
  input  logic [3:0] digit2,
  input  logic [3:0] digit3,
  input  logic [3:0] decimals,
  output logic [7:0] segment_cathodes,
  output logic [3:0] digit_anodes
);

// Signals with segment results from converters
logic [6:0] segments0;
logic [6:0] segments1;
logic [6:0] segments2;
logic [6:0] segments3;

// State machine parameters for anode timing.
localparam [1:0] DIGIT_ZERO  = 2'b00;
localparam [1:0] DIGIT_ONE   = 2'b01;
localparam [1:0] DIGIT_TWO   = 2'b10;
localparam [1:0] DIGIT_THREE = 2'b11;

// State register signals for state machine
logic [1:0] CURRENT_STATE;
logic [1:0] NEXT_STATE;

// Logic for state machine register
always_ff@(posedge clk)
  begin
    if(rst)
      CURRENT_STATE <= DIGIT_ZERO;
    else
      CURRENT_STATE <= NEXT_STATE;
  end

// Logic for next state value in state machine
always_comb
  begin
    case(CURRENT_STATE)
      DIGIT_ZERO: 
        begin
          segment_cathodes = {~decimals[0], segments0};
          digit_anodes     = 4'b1110;
          NEXT_STATE       = DIGIT_ONE;
        end
      DIGIT_ONE:
        begin
          segment_cathodes = {~decimals[1], segments1};
          digit_anodes     = 4'b1101;
          NEXT_STATE       = DIGIT_TWO;
        end
      DIGIT_TWO:
        begin
          segment_cathodes = {~decimals[2], segments2};
          digit_anodes     = 4'b1011;
          NEXT_STATE       = DIGIT_THREE;
        end
      DIGIT_THREE:
        begin
          segment_cathodes = {~decimals[3], segments3};
          digit_anodes     = 4'b0111;
          NEXT_STATE       = DIGIT_ZERO;
        end
      default:
        begin
          segment_cathodes = {~decimals[0], segments0};
          digit_anodes     = 4'b1110;
          NEXT_STATE       = DIGIT_ZERO;
        end
    endcase
  end

// Digit-to-segment converters
digit2segments converter0(
  .digit(digit0),
  .segments(segments0)
);

digit2segments converter1(
  .digit(digit1),
  .segments(segments1)
);

digit2segments converter2(
  .digit(digit2),
  .segments(segments2)
);

digit2segments converter3(
  .digit(digit3),
  .segments(segments3)
);

endmodule
