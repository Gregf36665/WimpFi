`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 11:25:01 AM
// Design Name: 
// Module Name: random_sim
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


module random_sim(
    );

	logic clk = 0;
	logic reset = 1;
	logic roll = 0;
	logic [5:0] val;

	always
		#5 clk = ~clk;

	random_generator DUV (.*);

	initial
	begin
		#100;
		reset = 0;
		#100;
		roll = 1;
		repeat(63) @(posedge clk);
		roll = 0;
		#100;
		$finish();
	end


endmodule
