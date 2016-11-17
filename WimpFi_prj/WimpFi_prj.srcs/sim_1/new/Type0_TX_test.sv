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
	logic txen, txd, cardet, xrdy;
	logic [7:0] xerrcnt;


	Transmitter_Interface (.*);


	task send_one_byte;
		check_group_begin("Send one byte");
		xdata = 8'h20;

		check_group_end;
	endtask

	always
		#5 clk = ~clk;

			
endmodule
