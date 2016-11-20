`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2016 09:29:16 AM
// Design Name: 
// Module Name: Type1_RX_MX
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


module Type1_RX_MX(
    );

	logic clk = 0;
	logic reset = 1;
	logic rrd = 0;
	logic [7:0] mac  = 8'h55, xdata;
	logic [7:0] xerrcnt, rdata, rerrcnt;
	logic cardet;
	logic txd;
	assign rxd = txd;
	logic txen;
	logic xsnd = 0;
	logic xwr = 0;
	logic xrdy;
	logic rrdy;


	Transmitter_Interface U_TX (.*);
	Receiver_Interface DUV (.*);

	task send_empty_T1;
		@(negedge clk)
			xwr = 1;
			xdata = 8'h2a;
		@(posedge clk)
			xwr = 0;
		repeat(10) @(posedge clk)
			xwr = 1;
			#1 xdata = 8'h55;
		@(posedge clk)
			#1 xwr = 0;
		@(posedge clk)
		repeat(10) @(posedge clk)
			xwr = 1;
			#1 xdata = 8'h31;
		@(posedge clk)
			#1 xwr = 0;
		repeat(10) @(posedge clk);
		xsnd = 1;
		@(posedge txen)
			#1 xsnd = 0;

	endtask


	always
		#5 clk = ~clk;

	initial
	begin
		#100;
		reset = 0;
		send_empty_T1;
		
	end
	
endmodule
