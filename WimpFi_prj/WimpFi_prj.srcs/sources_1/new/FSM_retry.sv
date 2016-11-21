`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2016 02:46:49 PM
// Design Name: 
// Module Name: FSM_retry
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


module FSM_retry #(parameter W=4) (
    input logic clk,
    input logic reset,
    input logic retry,
	input logic good_ack,
    input logic [2:0] frame_type,
    input logic [W:0] curr_rp,
    output logic set_rp,
    output logic [W:0] rp_val,
    output logic xsnd,
	input logic exceed_retry
    );

	typedef enum logic [3:0]{
		IDLE = 4'h0,
		RETRY = 4'h1,
		WAIT = 4'h2,
		RESEND = 4'h3
	} states;

	states state, next;

	logic store_rp;

	always_ff @(posedge clk)
		if(reset)
			begin
				state <= IDLE;
				rp_val <= '0;
			end
		else
			begin
				state <= next;
				if(store_rp) rp_val <= curr_rp;
			end

	always_comb
	begin
		set_rp = 0;
		store_rp = 0;
		xsnd = 0;
		next = IDLE;

		case(state)
			IDLE:
			if(frame_type == 2)
				begin
					store_rp = 1;
					next = WAIT;
				end		
			WAIT:
				if(good_ack | exceed_retry) next = IDLE;
				else if(retry) next = RETRY;
				else next = WAIT;
			RETRY:
			begin
				set_rp = 1;
				next = RESEND;
			end
			RESEND:
			begin
				xsnd = 1;
				next = WAIT;
			end
		endcase


	end

endmodule
