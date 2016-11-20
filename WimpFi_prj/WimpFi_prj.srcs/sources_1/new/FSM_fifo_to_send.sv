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
	output logic use_fsm,
	input logic [2:0] frame_type,
	input logic [7:0] fcs,
	output logic reset_crc,
	input logic good_ack,
	input logic exceed_retry,
	input logic retry_send,
	output logic [3:0] debug
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
		GET_NEXT_BYTE = 4'hB,
		FCS = 4'hC,
		SEND_FCS = 4'hD,
		RESET_CRC = 4'hE,
		WAIT_FOR_ACK = 4'hF

	} states;

	states state, next;

	assign debug = state;

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
		reset_crc = 0;
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
			begin
				data = PREAMBLE;
				use_fsm = 1;
				next = rdy ? SEND_PREAMBLE2 : LOAD_PREAMBLE2;
			end
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
				begin
				if (empty)
					next = (frame_type == 0) ? IDLE : FCS;
				else
					next = STAND_BY;
				end
			FCS:
				next = rdy ? SEND_FCS : FCS;
			SEND_FCS:
				begin
					data = fcs;
					send = 1;
					use_fsm = 1;
					next = rdy ? SEND_FCS : RESET_CRC;
				end
			RESET_CRC:
				begin
					reset_crc = 1;
					next = (frame_type == 2) ? WAIT_FOR_ACK : IDLE;
				end
			WAIT_FOR_ACK:
				if(retry_send) next = TIMING_CHECK;
				else next = (good_ack | exceed_retry) ? IDLE : WAIT_FOR_ACK;
		endcase
			
	end


endmodule
