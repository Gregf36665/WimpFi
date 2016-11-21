`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2016 01:43:08 PM
// Design Name: 
// Module Name: T3_TX_test
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


module T3_TX_test();

	logic clk = 0;
	logic reset = 1;
	logic txen, txd;
	logic xsnd = 0;
	logic xwr = 0;
	logic [7:0] xdata = 8'h0;
	logic cardet = 0;
	logic xrdy;
	logic [7:0] xerrcnt;
	logic [7:0] rx_addr = 8'h6E;
	logic [7:0] mac_address = 8'h55;
	logic got_ack = 0;
	logic send_ack = 0;

	Transmitter_Interface DUV  (.*);

	always
		#5 clk = ~clk;

	initial
	begin
		#100
		reset = 0;
		#100;
		send_ack = 1;
		#100;
	end



endmodule
