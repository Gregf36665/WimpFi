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
	logic [7:0] src;
	logic got_ack, send_ack;

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
		check("Incomming message to 55", rdata, 8'h55);
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
		check("Incomming all call", rdata, 8'h2a);
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
		check_group_begin("Rx mac address type 0 multi packet");
		pos = 0;
		length = 7;
		#100;
		enb = 1;
		#100;
		enb = 0;
		@(posedge rrdy); // There is data available
		// send another packet before it is read out
		pos = 14;
		length = 21;
		#100;
		enb = 1;
		#100;
		enb = 0;
		
		@(negedge txen); // wait for the tx to stop
		@(negedge txen); // wait for the tx to stop twice
		#1; // get away from a clock
		rrd = 1;
		@(posedge clk);
		check("Incomming message for 55 not changed by b0", rdata, 8'h55);
		@(posedge clk);
		check("Incomming message from a1 not changed by b0", rdata, 8'ha1);
		@(posedge clk);
		check("Packet type 0", rdata, 8'h30);
		@(posedge clk);
		check("Data correct from a1", rdata, 8'ha1);
		@(posedge clk);
		#1 rrd = 0;
		check("All data removed", rrdy, 1'b0);
		check_group_end;
	endtask
	
	task bad_mac_address;
		check_group_begin("Rx not our mac address type 0");
		pos = 21;
		length = 32;
		#100;
		enb = 1;
		#100;
		enb = 0;
		fork : rrdy_txen_timeout
			begin
				// Data appeared when it should not have
				@(posedge rrdy) check("Ignore mac address", 1'b0, 1'b1);
				disable rrdy_txen_timeout;
			end
			begin
				// Ignored data not for us
				@(negedge txen) check("Ignore mac address", 1'b1, 1'b1);
				disable rrdy_txen_timeout;
			end
		join;

		check_group_end;
	endtask

	initial
	begin
		#100;
		reset = 0;
		#100;
		send_1byte_addr;
		#10_000;
		send_1byte_all_call;
		#10_000;
		send_two_packets;
		#10_000;
		bad_mac_address;
		#10_000;
		check_summary_stop;
		$finish;
	end
		

endmodule
