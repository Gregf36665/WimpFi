`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 10:47:11 AM
// Design Name: 
// Module Name: Backoff_FSM
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


module Backoff_FSM(
    input logic clk,
    input logic reset,
    input logic rts,
    input logic cardet,
	input logic difs_timeout,
	input logic sifs_timeout,
	input logic slots_done,
	input logic rts_ack,
    output logic cts,
    output logic roll,
	output logic enb_slots_counter,
	output logic enb_difs_counter,
	output logic enb_sifs_counter,
	output logic reset_counters
    );

	typedef enum logic [3:0] {
		IDLE = 4'h1,
		CTS = 4'h3,
		NETWORK_BUSY = 4'h4,
		ROLL = 4'h6,
		CONTENTION = 4'h5,
		SIFS_TIMEOUT = 4'h7,
		FIRST_WAIT = 4'h8
	} states;

	states state, next;

	always_ff @(posedge clk)
		state <= reset ? IDLE : next;

	always_comb
	begin
		cts = 0;
		roll = 0;
		enb_slots_counter = 0;
		enb_difs_counter = 0;
		enb_sifs_counter = 0;
		reset_counters = 0;
		next = IDLE;

		case(state)
			IDLE:
			begin
				if (rts) next = cardet ? NETWORK_BUSY : FIRST_WAIT; // Always wait one DIFS
				else if (rts_ack) next = SIFS_TIMEOUT;
				reset_counters = 1;
			end
			FIRST_WAIT:
			begin
				if(cardet)
				begin
					reset_counters = 1;
					next = NETWORK_BUSY;
				end
				else
				begin
					next = difs_timeout ? CTS : FIRST_WAIT;
					enb_difs_counter = 1;
				end
			end

			NETWORK_BUSY:
			begin
				if(cardet) reset_counters = 1;
				else enb_difs_counter = 1;
				next = difs_timeout ? ROLL : NETWORK_BUSY;
			end
			
			ROLL:
			begin
				roll = 1;
				next = cardet ? NETWORK_BUSY : CONTENTION;
				reset_counters = 1;
			end
			CONTENTION:
			begin
				if(slots_done) next = cardet ? NETWORK_BUSY : CTS;
				else next = cardet ? NETWORK_BUSY : CONTENTION;
				enb_slots_counter = 1;
			end
			CTS:
			begin
				cts = 1;
				next = IDLE;
			end
			SIFS_TIMEOUT:
				begin
					next = sifs_timeout ? CTS : SIFS_TIMEOUT;
					enb_sifs_counter = 1;
				end
				
		endcase

	end
endmodule
