`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 08:54:24 AM
// Design Name: 
// Module Name: FSM_uart_to_mx
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


module FSM_uart_to_mx(
    input logic clk,
    input logic reset,
	input logic UART_ready,
	input logic ferr,
    input logic [7:0] data_in,
    output logic save_byte,
    output logic send
    );

	// Default send code ctl-D
	localparam SEND_CODE = 8'h04;

	typedef enum logic[3:0] {
		IDLE = 4'h0,
		DATA_INCOMING = 4'h1,
		PARSE_DATA = 4'h2,
		SAVE_DATA = 4'h3,
		SEND = 4'h4
	} states;

	states state, next;

	always_ff @(posedge clk)
		state <= reset ? IDLE : next;

	always_comb
	begin
		save_byte = 0;
		send = 0;

		case(state)
		IDLE:
			// the UART receiver is seeing something
			next = ready ? IDLE : DATA_INCOMING;
		DATA_INCOMING:
			// wait until the UART is done
			if (ferr) next = IDLE; // Did the UART-rx get an error
			else next = ready ? PARSE_DATA : DATA_INCOMING; // good data
		PARSE_DATA:
			// Should we send the data
			next = (data_in == SEND_CODE) ? SEND : SAVE_DATA;
		SEND:
			begin
				next = IDLE;
				send = 1;
			end
		SAVE_DATA:
			begin
				next = IDLE;
				save_byte = 1;
			end
		endcase

	end

endmodule
