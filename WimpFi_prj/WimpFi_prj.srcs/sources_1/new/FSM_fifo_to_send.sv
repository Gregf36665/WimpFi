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
    output logic read,
	output logic xrdy
    );

	typedef enum logic[1:0]{
		IDLE = 2'b00,
		TIMING_CHECK = 2'b01,
		STAND_BY = 2'b10,
		SEND = 2'b11
	} states;

	states state, next;

	always_ff @(posedge clk)
		state <= reset ? IDLE : next;

	always_comb
	begin
		rts = 0;
		send = 0;
		read = 0;
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
				next = cts ? STAND_BY : TIMING_CHECK;
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
