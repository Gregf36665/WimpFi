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
		SEND_SFD = 4'h9

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
		next = IDLE;
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
				next = cts ? LOAD_PREAMBLE1 : TIMING_CHECK;
			end
		LOAD_PREAMBLE1:
			begin
				data = PREAMBLE;
				use_fsm = 1;
				next = rdy ? SEND_PREAMBLE1 : LOAD_PREAMBLE1;
			end
		STAND_BY:
			next = rdy ? SEND : STAND_BY;
		SEND:
			begin
				send = 1;
				read_data = 1;
				next = empty ? IDLE : STAND_BY;
			end		
		endcase
			
	end


endmodule
