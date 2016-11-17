`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2016 01:15:17 PM
// Design Name: 
// Module Name: Type0_RX_test
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

module Type0_RX_test(
    );

	// connections
	logic clk = 0;
	logic reset = 1;
	logic rrd = 0;
	logic [7:0] mac = 8'h55;
	logic rrdy;
	logic [7:0] rdata, rerrcnt;
	logic cardet;

	// Connections for the tx
	logic [5:0] length = 5;
	logic enb = 0;
	logic txdata, txen;

	assign rxd = txdata;
	TransmitterTestUnit U_TX (.*);

	Receiver_Interface DUV(.*);


	always
		#5 clk = ~clk;


	task send_1byte_addr;
		length = 5;
		enb = 1;
		#100;
		enb = 0;
		@(posedge rrdy); // There is data available
		#1; // get away from a clock
		rrd = 1;
		assert(rdata == 8'ha1) $display("PASS: rx 1 byte for personal MAC");
		@(posedge clk);
		#1 rrd = 0;
	endtask

	initial
	begin
		#100;
		reset = 0;
		#100;
		send_1byte_addr;
		#10_000;
		$finish;
	end
		

endmodule
