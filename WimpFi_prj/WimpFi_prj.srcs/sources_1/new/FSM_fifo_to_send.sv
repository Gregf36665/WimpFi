`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2016 03:26:57 PM
// Design Name: 
// Module Name: FSM_fifo_to_send
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


module FSM_fifo_to_send(
    input logic clk,
    input logic reset,
    input logic xsnd,
    input logic empty,
    output logic rts,
    input logic cts,
    input logic rdy,
    output logic send,
    output logic read_data,
	output logic xrdy,
	output logic [7:0] data,
	output logic use_fsm
    );

	localparam PREAMBLE = 8'h55;
	localparam SFD = 8'hd0;

	typedef enum logic[3:0]{
		IDLE = 4'h0,
		TIMING_CHECK = 4'h1,
		STAND_BY = 4'h2,
		SEND = 4'h3,
		LOAD_PREAMBLE1 = 4'h4,
		SEND_PREAMBLE1 = 4'h5,
		LOAD_PREAMBLE2 = 4'h6,
		SEND_PREAMBLE2 = 4'h7,
		LOAD_SFD = 4'h8,
		SEND_SFD = 4'h9,
		CHECK_EMPTY = 4'hA,
		GET_NEXT_BYTE = 4'hB

	} states;

	states state, next;

	always_ff @(posedge clk)
		state <= reset ? IDLE : next;

	always_comb
	begin
		rts = 0;
		send = 0;
		read_data = 0;
		xrdy = 0;
		data = 0;
		next = IDLE;
		use_fsm = 0;
		case(state)
			IDLE:
				begin
					if(empty) next = IDLE; // don't send if there is nothing to send
					else next = xsnd ? TIMING_CHECK : IDLE;
					xrdy = 1;
				end
			TIMING_CHECK:
				begin
					rts = 1;
					// Verify cts signal
					next = cts ? LOAD_PREAMBLE1 : TIMING_CHECK;
				end
			LOAD_PREAMBLE1:
				// Wait till we are ready
				next = rdy ? SEND_PREAMBLE1 : LOAD_PREAMBLE1;
			SEND_PREAMBLE1:
				begin
					send = 1;
					data = PREAMBLE;
					use_fsm = 1;
					// Wait until ready falls before advancing
					next = rdy ? SEND_PREAMBLE1 : LOAD_PREAMBLE2;
				end
			LOAD_PREAMBLE2:
				next = rdy ? SEND_PREAMBLE2 : LOAD_PREAMBLE2;
			SEND_PREAMBLE2:
				begin
					send = 1;
					data = PREAMBLE;
					use_fsm = 1;
					next = rdy ? SEND_PREAMBLE2 : LOAD_SFD;
				end
			LOAD_SFD:
				next = rdy ? SEND_SFD : LOAD_SFD;
			SEND_SFD:
				begin
					data = SFD;
					use_fsm = 1;
					send = 1;
					next = rdy ? SEND_SFD : STAND_BY;
				end
			STAND_BY:
				next = rdy ? SEND : STAND_BY;
			SEND:
				begin
					send = 1;
					next = rdy ? SEND : GET_NEXT_BYTE;
				end		
			GET_NEXT_BYTE:
				begin
					read_data = 1;
					next = CHECK_EMPTY; 
				end
			CHECK_EMPTY:
				next = empty ? IDLE : STAND_BY;
		endcase
			
	end


endmodule
