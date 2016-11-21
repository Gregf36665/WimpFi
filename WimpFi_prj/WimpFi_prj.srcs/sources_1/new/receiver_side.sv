`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 06:49:19 AM
// Design Name: 
// Module Name: receiver_side
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


module receiver_side(
	input logic clk,
	input logic reset,
	input logic rxd,
	input logic [7:0] SW,
	output logic UART_RXD_OUT,
	output logic cardet,
	output logic [7:0] rerrcnt, src,
	output logic got_ack, send_ack,
	output rrdy
	);

	// Internal connections
	logic [7:0] data; // data connection
	logic rrd, send, rdy;

	// RX interface
	Receiver_Interface U_RX_INTERFACE (.clk, .reset, .rrd, .rrdy, .mac(SW),
										.rdata(data), .rerrcnt, .cardet, .rxd,
										.src, .got_ack, .send_ack);

	// FSM to take data out of the receiver
	FSM_rx_mx_to_tx_uart U_EXTRACTOR_FSM (.clk, .reset, .rrdy, .rdy, .rrd, .send);

	// UART tx
	transmitter U_UART_TX (.clk, .send, .data, .rdy, .txd(UART_RXD_OUT));



	
endmodule
