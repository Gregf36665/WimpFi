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
	logic [5:0] length = 7;
	logic enb = 0;
	logic txdata, txen;
	logic [7:0] pos = 0;

	assign rxd = txdata;
	TransmitterTestUnit U_TX (.*);

	Receiver_Interface DUV(.*);


	always
		#5 clk = ~clk;


	task send_1byte_addr;
		check_group_begin("Rx mac address type 0");
		length = 7;
		enb = 1;
		#100;
		enb = 0;
		@(posedge rrdy); // There is data available
		#1; // get away from a clock
		rrd = 1;
		@(posedge clk);
		check("Incomming message from a1", rdata, 8'ha1);
		@(posedge clk);
		check("Packet type 0", rdata, 8'h30);
		@(posedge clk);
		check("Data correct", rdata, 8'ha1);
		@(posedge clk);
		#1 rrd = 0;
		check("All data removed", rrdy, 1'b0);
		check_group_end;
	endtask

	task send_1byte_all_call;
		check_group_begin("Rx all call type 0");
		length = 14;
		pos = 7;
		#100;
		enb = 1;
		#100 enb = 0;
		@(posedge rrdy); // Data available
		rrd = 1;
		@(posedge clk);
		check("Incomming all call from a1", rdata, 8'ha1);
		@(posedge clk);
		check("Data type 0", rdata, 8'h30);
		@(posedge clk);
		check("Data parsed from all call from a1", rdata, 8'h10);
		@(posedge clk);
		#1 rrd = 0;
		check("All data removed", rrdy, 1'b0);
		check_group_end;

	endtask

	task send_two_packets;


	endtask
	
	initial
	begin
		#100;
		reset = 0;
		#100;
		send_1byte_addr;
		#10_000;
		send_1byte_all_call;
		check_summary_stop;
		$finish;
	end
		

endmodule
