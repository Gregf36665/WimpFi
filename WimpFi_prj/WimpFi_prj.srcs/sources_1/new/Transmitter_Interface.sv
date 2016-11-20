`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2016 02:57:49 PM
// Design Name: 
// Module Name: Transmitter_Interface
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


module Transmitter_Interface #(parameter BIT_RATE = 50_000) (
    input logic clk,
    input logic reset,
    output logic txen,
    output logic txd,
    input logic xsnd,
    input logic xwr,
    input logic [7:0] xdata,
    input logic cardet,
    output logic xrdy,
    output logic [7:0] xerrcnt
    );

	localparam CUTOUT_DURATION = 511; // How many bit periods before watch dog shutdown

	// Internal connections
	logic [7:0] data, fsm_data, fifo_data, fcs; // connection from FIFO to data
	logic mx_txen;
	logic [2:0] frame_type;
	logic empty, re, rdy, send, rts, cts, use_fsm;
	manchester_tx #(.BIT_RATE(BIT_RATE)) U_TX_MX (.clk, .send, .reset, .data, 
													.rdy, .txen(mx_txen), .txd);

	p_fifo #(.DEPTH(255)) U_BUFFER (.clk, .rst(~reset), .clr(1'b0), .din(xdata), .we(xwr), .re,
									.full(), .empty, .dout(fifo_data));

	FSM_fifo_to_send U_FSM_TX (.clk, .reset, .xsnd, .empty, .rts, .cts,
								.rdy, .send, .read_data(re), .xrdy, .data(fsm_data), 
								.use_fsm, .frame_type, .fcs);


	// Watchdog timer to prevent continious transmissions
	logic wd_enb, problem, safety_cutout;

	// Start counting if txen is high
	counter_parm #(.W($clog2(CUTOUT_DURATION)),.CARRY_VAL(CUTOUT_DURATION))
				U_WATCHDOG_TIMER (.clk, .reset(reset | ~txen), .enb(wd_enb), .q(), .carry(problem));

	clkenb #(.DIVFREQ(BIT_RATE)) U_WATCHDOG_ENB (.clk, .reset, .enb(wd_enb));

	f_error U_WATCHDOG_LATCH (.clk, .reset, .set_ferr(problem), .clr_ferr(1'b0), .ferr(safety_cutout));

	// Add a backoff module to deal with traffic 
	Backoff_module U_BACKOFF_MODULE (.clk, .reset, .cardet, .rts, .cts);

	// Count which byte is selected
	// TO FROM TYPE
	logic [7:0] byte_count;
	counter_parm #(.W(8)) U_FRAME_TYPE_COUNTER (.clk, .reset(reset | xsnd), .enb(xwr),
																	.q(byte_count));

	FSM_Frame_type U_FSM_FRAME_ID (.clk, .reset, .byte_count, .xsnd, .din(xdata), .frame_type);

	
	// Generate a FCS
	logic dout, enb_crc;
	FSM_FCS U_FCS_FSM (.clk, .reset, .xwr, .din(xdata), .dout, .enb_crc);


	assign data = use_fsm ? fsm_data : fifo_data;
	assign xerrcnt = 0; // todo implement crc checking
	assign txen = safety_cutout ? 1'b0 : mx_txen; // shutdown if there is a problem

	assign fcs = 8'h24;
endmodule
