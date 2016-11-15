`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Greg
// 
// Create Date: 10/30/2016 07:20:40 PM
// Design Name: 
// Module Name: single_pulser
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Generate a single pulse for 1 clock cycle when enb goes high
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module single_pulser(
    input logic clk,
    input logic reset,
    input logic enb,
    output logic pulse
    );

	logic curr, last;

	always_ff @(posedge clk)
	if (reset)
		begin
			curr <= 1'b0;
			last <= 1'b0;
		end
	else
		begin
			curr <= enb;
			last <= curr;
		end


	assign pulse = curr & ~last;
	
endmodule
