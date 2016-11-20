`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2016 01:26:58 PM
// Design Name: 
// Module Name: FSM_ack_timeout
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


module FSM_ack_timeout(
    input logic clk,
    input logic reset,
    input logic [2:0] frame_type,
    input logic xsnd,
    input logic ack,
	input logic ack_timeout,
    input logic [7:0] tx_addr,
    input logic [7:0] rx_addr,
	output logic retry,
	output logic start_ack_timeout,
	output logic good_ack,
	output logic exceed_retry
    );

	localparam RETRY_COUNT = 5;

	typedef enum logic[3:0]{
		IDLE = 4'h0,
		START_COUNTING = 4'h1,
		CHECK_ADDR = 4'h2,
		TIMEOUT = 4'h5,
		EXCEED_RETRY = 4'h6
	} states;

	states state,next;

	logic [$clog2(RETRY_COUNT):0] retry_counter;
	logic retry_counter_reset;


	always_ff @(posedge clk)
	begin
		state <= reset ? IDLE : next;
		if(reset | retry_counter_reset) retry_counter <= 0;
		else retry_counter <= retry ? retry_counter + 1 : retry_counter;
	end



	always_comb
	begin
		retry = 0;
		start_ack_timeout = 0;
		next = IDLE;
		retry_counter_reset = 0;
		exceed_retry = 0;
		good_ack = 0;
		case(state)
			IDLE:
			begin
				if(frame_type == 2) next = xsnd ? START_COUNTING : IDLE;
				retry_counter_reset = 1;
			end
			START_COUNTING:
			begin
				start_ack_timeout = 1;
				next = START_COUNTING;
				if(ack_timeout) retry = 1;
				if(ack) next = CHECK_ADDR;
				if(retry_counter == RETRY_COUNT) next = EXCEED_RETRY;
			end
			CHECK_ADDR:
			begin
				if (tx_addr == rx_addr) 
				begin
					good_ack = 1;
					next = IDLE;
				end
				else next = START_COUNTING;
				start_ack_timeout = 1; // Keep counting incase it is a false ack
			end
			EXCEED_RETRY:
			begin
				start_ack_timeout = 1; // Last chance
				next = IDLE;
				if(ack_timeout) exceed_retry = 1;
				else if(ack) next = CHECK_ADDR;
				else next = EXCEED_RETRY;
			end
				

		endcase
	end

endmodule
