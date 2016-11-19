`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 09:12:58 AM
// Design Name: 
// Module Name: transmitter_side
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


module transmitter_side(
    input logic clk,
    input logic reset,
	input logic UART_TXD_IN,
	input logic cardet,
	output logic txen, txd
    );

	// Internal connections
	logic xsnd, xwr, ferr, UART_ready, xrdy;
	logic [7:0] data;

	// Attach the transmitter interface
	Transmitter_Interface U_TX_INTERFACE (.clk, .reset, .txen, .txd,
							.xsnd, .xwr, .xdata(data), .cardet,
							.xrdy, .xerrcnt());

	FSM_uart_to_mx U_EXTRACTOR_FSM (.clk, .reset, .UART_ready, .MX_ready(xrdy),
									.ferr, .data_in(data), . save_byte(xwr),
									.send(xsnd));

	receiver U_UART_RX (.clk, .reset, .rxd(UART_TXD_IN), .ferr, .ready(UART_ready),
						.data);
	


endmodule
