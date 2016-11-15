`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2016 04:13:36 PM
// Design Name: 
// Module Name: counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// A counter that can be incremented or decremented
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module counter #(parameter MAX = 7)(
	input logic clk, enb, inc, dec, reset,
	output logic [$clog2(MAX)-1:0] q
    );

	always_ff @(posedge clk)
	begin
		if(reset) q <= 0;
		if(inc)   q <= q + 2; // skip a step up
		if(dec)   q <= q - 7; // skip a step down
		if(enb)   q <= q+1;
	end
endmodule
