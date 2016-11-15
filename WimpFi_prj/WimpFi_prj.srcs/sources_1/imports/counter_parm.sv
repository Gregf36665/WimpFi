`timescale 1ns / 1ps
module counter_parm #(parameter W=4, parameter CARRY_VAL=4'hF) (
		     input logic clk, reset, enb,
		     output logic [W-1:0] q,
		     output logic carry
		     );
    
   always_ff @(posedge clk)
     if (reset) q <= '0;
     else if (enb) q <= q + 1;
     
   assign carry = (q == CARRY_VAL);
      
endmodule // counter_parm
