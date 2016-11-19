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

module Type0_RX_MX_TX_UART_test(
    );

	// connections
	logic clk = 0;
	logic reset = 1;
	logic [7:0] SW = 8'h55;
	logic cardet, UART_RXD_OUT;

	// Connections for the tx
	logic [5:0] length = 7;
	logic enb = 0;
	logic txdata, txen;
	logic [7:0] pos = 0;

	assign rxd = txdata;
	TransmitterTestUnit U_TX (.*);

	receiver_side DUV (.*);


	always
		#5 clk = ~clk;


	task send_1byte_addr;
		length = 7;
		enb = 1;
		#100;
		enb = 0;
	endtask

	task send_1byte_all_call;
		length = 14;
		pos = 7;
		#100;
		enb = 1;
		#100 enb = 0;
	endtask

	task send_two_packets;
		pos = 0;
		length = 7;
		#100;
		enb = 1;
		#100;
		enb = 0;
		@(negedge cardet); // There is data available
		// send another packet before it is read out
		pos = 14;
		length = 21;
		#100;
		enb = 1;
		#100;
		enb = 0;
	endtask
	
	task bad_mac_address;
		pos = 21;
		length = 32;
		#100;
		enb = 1;
		#100;
		enb = 0;
		fork : rrdy_txen_timeout
			begin
				// Data appeared when it should not have
				@(negedge UART_RXD_OUT) check("Ignore mac address", 1'b0, 1'b1);
				disable rrdy_txen_timeout;
			end
			begin
				// Ignored data not for us
				@(negedge txen) check("Ignore mac address", 1'b1, 1'b1);
				disable rrdy_txen_timeout;
			end
		join;
	endtask


	initial
	begin
		#100;
		reset = 0;
		#100;
		send_1byte_addr;
		#10_000_000;
		send_1byte_all_call;
		#10_000_000;
		send_two_packets;
		#10_000_000;
		bad_mac_address;
		#10_000_000;
		$finish;
	end
		

endmodule
