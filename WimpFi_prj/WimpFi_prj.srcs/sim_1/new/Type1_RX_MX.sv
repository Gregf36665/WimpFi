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

import check_p::*;

module Type1_RX_MX(
    );

	logic clk = 0;
	logic reset = 1;
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
	assign rrd = rrdy; // If something can be read read it.
	logic [7:0] src;
	logic got_ack, send_ack;
	logic [7:0] rxaddr;
	assign rxaddr = src;
	logic [7:0] mac_address;


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

	task send_empty_T1;
		// Send 2a
		check_group_begin("rx2.1 MAC type 1");
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
			#1 xdata = 8'h31;
		@(posedge clk)
			#1 xwr = 0;
		repeat(10) @(posedge clk);
		// Send all bytes
		xsnd = 1;
		@(posedge txen)
			#1 xsnd = 0;
		@(posedge rrdy);
			check("Incomming message to from 2a", rdata, 8'h2a);
		@(posedge clk);
		@(posedge clk)
			check("Incomming message to 55", rdata, 8'h55);
		@(posedge clk)
			check("Incomming message type 31", rdata, 8'h31);
		@(posedge clk)
			check("Incomming message crc 96", rdata, 8'h96);
		
		check_group_end;
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
			#1 xdata = 8'h31;
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

	task send_type2;
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
		// Send 32
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
		#800 got_ack = 1;
		@(negedge clk) got_ack = 0;
		#1_000_000;

	endtask

	task send_type3;
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
		// Send 33
		@(negedge clk);
			xwr = 1;
			#1 xdata = 8'h33;
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
		check_summary_stop;
		
	end
	
endmodule
