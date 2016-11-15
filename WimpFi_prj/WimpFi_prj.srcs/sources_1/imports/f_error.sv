`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Raji Birru & Greg Flynn
// 
// Create Date: 09/27/2016 10:13:59 AM
// Design Name: 
// Module Name: f_error
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


module f_error(
		input logic clk, set_ferr, clr_ferr, reset,
		output logic ferr
    );
    
    always_ff @(posedge clk)
    	begin
    	    if(reset) ferr <= 1'b0;
    	    else if(set_ferr) ferr <= 1'b1;
    		else if(clr_ferr) ferr <= 1'b0;
    	end
    	
endmodule
