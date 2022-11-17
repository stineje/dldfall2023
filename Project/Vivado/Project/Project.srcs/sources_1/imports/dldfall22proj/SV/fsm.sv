module fsm (clk, reset, s, CURRENT_STATE,NEXT_STATE);
   
   output logic s;
   input logic 	clk;
   input logic 	reset;
   
   parameter  
     S0 = 1'b0,
     S1 = 1'b1;
   
   output logic CURRENT_STATE;
   output logic NEXT_STATE;
   
   always @(posedge clk)
     begin
	if (reset == 1'b1)	
	  CURRENT_STATE <= S0;
	else
	  CURRENT_STATE <= NEXT_STATE;
     end
   
   always @(CURRENT_STATE) 
     begin
	case(CURRENT_STATE)
	  S0:
	    begin
	       NEXT_STATE = S1;
	       s = 1'b0;
	    end
	  S1:
	    begin
	       NEXT_STATE = S1;
	       s = 1'b1;
	    end	 
	endcase
     end
   
endmodule // fsm

