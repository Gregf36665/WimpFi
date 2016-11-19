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
    output logic cts
    );

	// Frequency of bits
	parameter BIT_RATE = 50_000;
	// How many bit periods for each option
	parameter DIFS_COUNT = 80;
	parameter SIFS_COUNT = 40;
	parameter SLOT_TIME = 8;

	// Internal wires
	logic [5:0] current_slot_count;

	// Add the FSM
	Backoff_FSM U_FSM (.clk, .reset, .rts, .cardet, .cts, .roll,
						.difs_timeout, .sifs_timeout, .slots_done,
						.enb_slots_counter, enb_difs_counter,
						.enb_sifs_counter, .reset_counters);

	// Add the bit period timer
	clkenb #(.DIVFREQ(BIT_RATE)) U_BIT_RATE_CLOCK (.clk, .reset, .enb);
						
	// Add the timeout counters
	counter_parm #(.W($clog2(DIFS_COUNT)), .CARRY_VAL(DIFS_COUNT)) U_DIFS_COUNTER
					(.clk, .reset(reset | reset_counters), .enb(enb & enb_difs_counter),
					.carry(difs_timeout));

	counter_parm #(.W($clog2(SIFS_COUNT)), .CARRY_VAL(SIFS_COUNT)) U_SIFS_COUNTER
					(.clk, .reset(reset | reset_counters), .enb(enb & enb_sifs_counter),
					.carry(sifs_timeout));

	counter_parm #(.W($clog2(SLOT_TIME)), .CARRY_VAL(SLOT_TIME)) U_SLOTS_COUNTER
					(.clk, .reset(reset | reset_counters), .enb(enb & enb_slots_counter),
					.q(current_slot_count));




endmodule
