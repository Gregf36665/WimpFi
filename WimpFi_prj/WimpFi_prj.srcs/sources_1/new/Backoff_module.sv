`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 11:00:49 AM
// Design Name: 
// Module Name: Backoff_module
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


module Backoff_module(
    input logic clk,
    input logic reset,
    input logic cardet,
    input logic rts,
    input logic rts_ack,
    output logic cts,
	input logic start_ack_timeout,
	output logic ack_timeout,
	input logic retry
    );

	// Frequency of bits
	parameter BIT_RATE = 50_000;
	// How many bit periods for each option
	parameter DIFS_COUNT = 80;
	parameter SIFS_COUNT = 40;
	parameter SLOT_TIME = 8;
	parameter ACK_COUNT = 256;

	// Internal wires
	logic [5:0] current_slots_count;
	logic roll;

	// Signals to enable the 3 counters
	logic enb_slots_counter, enb_sifs_counter, enb_difs_counter;

	// Add the FSM
	Backoff_FSM U_FSM (.clk, .reset, .rts, .cardet, .cts, .roll,
						.difs_timeout, .sifs_timeout, .slots_done,
						.enb_slots_counter, .enb_difs_counter,
						.enb_sifs_counter, .reset_counters);

	// Add the bit period timer
	clkenb #(.DIVFREQ(BIT_RATE)) U_BIT_RATE_CLOCK (.clk, .reset, .enb);
						
	// Add the timeout counters
	counter_parm #(.W($clog2(DIFS_COUNT + 1)), .CARRY_VAL(DIFS_COUNT)) U_DIFS_TIMER
					(.clk, .reset(reset | reset_counters), .enb(enb & enb_difs_counter),
					.carry(difs_timeout), .q());

	counter_parm #(.W($clog2(SIFS_COUNT + 1)), .CARRY_VAL(SIFS_COUNT)) U_SIFS_TIMER
					(.clk, .reset(reset | reset_counters), .enb(enb & enb_sifs_counter),
					.carry(sifs_timeout), .q());

	counter_parm #(.W($clog2(SLOT_TIME)), .CARRY_VAL(SLOT_TIME-1)) U_SLOTS_TIMER
					(.clk, .reset(reset | reset_counters), .enb(enb & enb_slots_counter),
					.carry(inc_slots), .q());

	counter_parm #(.W($clog2(ACK_COUNT + 1)), .CARRY_VAL(ACK_COUNT)) U_ACK_TIMER
					(.clk, .reset(reset | retry | ~start_ack_timeout), 
					.enb(enb & start_ack_timeout), .carry(ack_timeout), .q());

	// Count how many slots have passed
	counter_parm #(.W(6)) U_SLOTS_COUNTER
					(.clk, .reset(reset | reset_counters), .enb(enb & inc_slots),
					.q(current_slots_count), .carry());


	// Add the random generator for slot count
	logic [5:0] slot_target;
	random_generator U_LFSR (.clk, .reset, .roll, .val(slot_target));

	assign slots_done = (slot_target == current_slots_count);



endmodule
