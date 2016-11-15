`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2016 08:58:06 AM
// Design Name: 
// Module Name: transmitterTestUnit_testBench
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


module transmitterTestUnit_testBench();

	logic clk = 0;
	logic enb = 0;
	logic [5:0] length = 3;
	logic reset = 1;
	logic txen, txdata;

	TransmitterTestUnit DUV (.*);

	always
		#5 clk = ~clk;


	initial begin
		#100;
		reset = 0;
		#100;
		enb = 1;
		#10_000;
		enb = 0;
		#20_000;
		//length = 10;
		#800_000;
		//enb = 1;
		#10_000;
		enb = 0;
		#40_000;
		$finish;
	end
endmodule
