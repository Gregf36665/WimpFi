`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 08:36:03 PM
// Design Name: 
// Module Name: crc_8_test
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


module crc_8_test();

	logic clk = 0;
	logic reset = 1;
	logic [7:0] crc;
	logic enb_crc;

	logic dout;
	assign di = dout;// connect FSM to the CRC

	crc_8 DUV (.*);

	logic xwr = 0;
	logic [7:0] din;
	FSM_FCS U_TX (.*);

	always
		#5 clk = ~clk;

	initial
	begin
		#100 reset = 0;
		din = 8'h2A;
		xwr = 1;
		@(posedge clk) #1 xwr = 0;
		repeat (8) @(posedge clk);
		#100;
		din = 8'h6E;
		xwr = 1;
		@(posedge clk) #1 xwr = 0;
		repeat (8) @(posedge clk);
		#100;
		din = 8'h31;
		xwr = 1;
		@(posedge clk) #1 xwr = 0;
		repeat (8) @(posedge clk);
		#100;
		din = 8'h98;
		xwr = 1;
		@(posedge clk) #1 xwr = 0;
		repeat (8) @(posedge clk);
	end

endmodule
