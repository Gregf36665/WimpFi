`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2016 03:38:25 PM
// Design Name: 
// Module Name: Type0_TX_test
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


import check_p::*;

module Type0_TX_test( );


	logic clk = 0;
	logic reset = 1;
	logic xsnd = 0;
	logic xwr = 0;
	logic [7:0] xdata = 0;
	logic txen, txd, cardet = 0, xrdy;
	logic [7:0] xerrcnt;


	Transmitter_Interface DUV (.*);


	task send_one_byte;
		check_group_begin("Send one byte");
		xdata = 8'h55;
		@(posedge clk) #1 xwr = 1;
		xdata = 8'h55;
		@(posedge clk) #1 xwr = 1;
		@(posedge clk) #1 xwr = 0;
		xsnd = 1;
		@(posedge clk) #1 xsnd = 0;
		check_group_end;
	endtask

	always
		#5 clk = ~clk;


	initial
	begin
		#100;
		reset = 0;
		#1000 send_one_byte;
		#10_000;
		check_summary_stop;
	end
			
endmodule
