`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2016 02:12:18 PM
// Design Name: 
// Module Name: Type2_TX
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


module Type2_TX(

    );

	logic clk = 0;
	logic reset = 1;
	logic [7:0] mac  = 8'h55, xdata, rxaddr = 8'h2a;
	logic [7:0] xerrcnt, rdata, rerrcnt;
	logic cardet;
	logic txd;
	assign rxd = txd;
	logic txen;
	logic xsnd = 0;
	logic xwr = 0;
	logic xrdy;
	logic rrdy;
	assign rrd = rrdy; // If something can be read read it.
	logic got_ack = 0, send_ack = 0;


	Transmitter_Interface U_TX (.*);
	Receiver_Interface DUV (.*);

	task send_byte(logic [7:0] data);
		// Send data
		@(negedge clk)
			xwr = 1;
			xdata = data;
		@(posedge clk)
			#1 xwr = 0;
		repeat(10) @(posedge clk);
	endtask

	task send_empty_T2;
		// Send 2a
		@(negedge clk)
			xwr = 1;
			xdata = 8'h2a;
		@(posedge clk)
			#1 xwr = 0;
		repeat(10) @(posedge clk);
		// Send 55
		@(negedge clk);
			#1 xwr = 1;
			xdata = 8'h55;
		@(posedge clk)
			#1 xwr = 0;
		repeat(10) @(posedge clk);
		// Send 31
		@(negedge clk);
			xwr = 1;
			#1 xdata = 8'h32;
		@(posedge clk)
			#1 xwr = 0;
		repeat(10) @(posedge clk);
		// Send all bytes
		xsnd = 1;
		@(posedge txen)
			#1 xsnd = 0;
		@(negedge txen);

	endtask


	task send_empty_T1_good_CRC;
		// Send 2a
		@(negedge clk)
			xwr = 1;
			xdata = 8'h2a;
		@(posedge clk)
			#1 xwr = 0;
		repeat(10) @(posedge clk);
		// Send 55
		@(negedge clk);
			#1 xwr = 1;
			xdata = 8'h55;
		@(posedge clk)
			#1 xwr = 0;
		repeat(10) @(posedge clk);
		// Send 31
		@(negedge clk);
			xwr = 1;
			#1 xdata = 8'h32;
		@(posedge clk)
			#1 xwr = 0;
		repeat(10) @(posedge clk);
		// Send 96
		@(negedge clk);
			xwr = 1;
			#1 xdata = 8'h96;
		@(posedge clk)
			#1 xwr = 0;
		repeat(10) @(posedge clk);
		xsnd = 1;
		@(posedge txen)
			#1 xsnd = 0;
		@(negedge txen);

	endtask

	always
		#5 clk = ~clk;

	initial
	begin
		#100;
		reset = 0;
		send_empty_T2;
		#500_000;
		//send_empty_T1_good_CRC;
	end

endmodule
