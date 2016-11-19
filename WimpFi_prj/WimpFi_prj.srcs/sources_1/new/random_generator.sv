`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 11:16:30 AM
// Design Name: 
// Module Name: random_generator
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

// This LFSR if from http://courses.cse.tamu.edu/csce680/walker/lfsr_table.pdf
// n = 6 using a 2 tap system
// tap at reg 5 and reg 4
// This goes through all values except for 0

module random_generator(
    input logic clk,
    input logic reset,
    input logic roll,
    output logic [5:0] val
    );

	parameter SEED = 6'h3F; // all ones

	always_ff @(posedge clk)
		if(reset)
			val <= SEED;
		else if(roll)
			begin
				val[5] <= val[0];
				val[4] <= val[0] ^ val[5];
				val[3] <= val[4];
				val[2] <= val[3];
				val[1] <= val[2];
				val[0] <= val[1];
			end
	

endmodule
