`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2016 08:37:03 PM
// Design Name: 
// Module Name: Type3_test
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


module Type3_test();

	logic clk = 0;
	logic reset = 1;
	logic txen, txd;
	logic xsnd = 0;
	logic xwr = 0;
	logic [7:0] xdata = 0;
	logic cardet = 0;
	logic xrdy;
	logic [7:0] xerrcnt;
	logic [7:0] rxaddr = 8'h20;
	logic [7:0] mac_address = 8'h55;
	logic got_ack = 0;
	logic send_ack = 0;

	Transmitter_Interface DUV (.*);

	always 
		#5 clk = ~clk;

	initial
	begin
		#100;
		reset = 0;
		#100;
		@(negedge clk)
			send_ack = 1;
		@(posedge clk) 
			send_ack = 0;

	end

endmodule
