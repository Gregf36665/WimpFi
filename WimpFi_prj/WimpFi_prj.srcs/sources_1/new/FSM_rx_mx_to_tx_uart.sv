`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 06:56:17 AM
// Design Name: 
// Module Name: FSM_rx_mx_to_tx_uart
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


module FSM_rx_mx_to_tx_uart(
    input logic clk,
    input logic reset,
    input logic rrdy,
    input logic rdy,
    output logic rrd,
    output logic send
    );

	typedef enum logic [2:0] {
		IDLE = 0,
		DATA_TO_SEND = 1,
		SEND_DATA = 2,
		GET_NEXT_DATA = 3,
		PAUSE = 4,
		CHECK_EMPTY = 5
	} states;

	states state, next;

	always_ff @(posedge clk)
		state <= reset ? IDLE : next;

	always_comb
	begin
		rrd = 0;
		send = 0;
		next = IDLE;
		case(state)
			IDLE:
				next = rrdy ? DATA_TO_SEND : IDLE;
			DATA_TO_SEND:
				next = rdy ? SEND_DATA : DATA_TO_SEND;
			SEND_DATA:
			begin
				send = 1;
				next = rrdy ? GET_NEXT_DATA : IDLE;
			end
			GET_NEXT_DATA:
			begin
				rrd = 1;
				next = PAUSE;
			end
			PAUSE:
				// rrdy falls one clock edge later
				next = CHECK_EMPTY;
			CHECK_EMPTY:
				// Did we read out the last data packet
				next = rrdy ? DATA_TO_SEND : IDLE;
		endcase
	end
endmodule
