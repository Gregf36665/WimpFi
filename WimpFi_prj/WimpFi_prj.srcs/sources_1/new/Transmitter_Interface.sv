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
    output logic [7:0] xerrcnt,
	input logic [7:0] rxaddr,
	input logic got_ack,
	input logic send_ack
    );

	localparam CUTOUT_DURATION = 511; // How many bit periods before watch dog shutdown

	// Internal connections
	logic [7:0] data, fsm_data, fifo_data, fcs; // connection from FIFO to data
	logic mx_txen;
	logic [2:0] frame_type;
	logic empty, re, rdy, send, rts, cts, use_fsm, reset_crc;
	manchester_tx #(.BIT_RATE(BIT_RATE)) U_TX_MX (.clk, .send, .reset, .data, 
													.rdy, .txen(mx_txen), .txd);
	
	localparam DEPTH = 255;
	localparam POINTER_WIDTH = $clog2(DEPTH)-1;
	logic [POINTER_WIDTH:0] rp, rp_val;
	logic set_rp;
	p_fifo #(.DEPTH(DEPTH)) U_BUFFER (.clk, .rst(~reset), .clr(1'b0), .din(xdata), .we(xwr), .re,
									.full(), .empty, .dout(fifo_data), .rp, .rp_val, .set_rp, .pop(0));

	logic good_ack, exceed_retry, retry_send;
	FSM_fifo_to_send U_FSM_TX (.clk, .reset, .xsnd, .empty, .rts, .cts,
								.rdy, .send, .read_data(re), .xrdy, .data(fsm_data), 
								.use_fsm, .frame_type, .fcs, .reset_crc, .good_ack, .exceed_retry,
								.retry_send);


	// Watchdog timer to prevent continious transmissions
	logic wd_enb, problem, safety_cutout;

	// Start counting if txen is high
	counter_parm #(.W($clog2(CUTOUT_DURATION)),.CARRY_VAL(CUTOUT_DURATION))
				U_WATCHDOG_TIMER (.clk, .reset(reset | ~txen), .enb(wd_enb), .q(), .carry(problem));

	clkenb #(.DIVFREQ(BIT_RATE)) U_WATCHDOG_ENB (.clk, .reset, .enb(wd_enb));

	f_error U_WATCHDOG_LATCH (.clk, .reset, .set_ferr(problem), .clr_ferr(1'b0), .ferr(safety_cutout));

	// Add a backoff module to deal with traffic 
	logic start_ack_timeout, ack_timeout, retry;
	Backoff_module U_BACKOFF_MODULE (.clk, .reset, .cardet, .rts, .cts, .rts_ack(),
									.start_ack_timeout, .ack_timeout, .retry);

	// Count which byte is selected
	// TO FROM TYPE
	logic [7:0] byte_count;
	counter_parm #(.W(8)) U_FRAME_TYPE_COUNTER (.clk, .reset(reset | xsnd), .enb(xwr),
																	.q(byte_count));

	FSM_Frame_type U_FSM_FRAME_ID (.clk, .reset, .byte_count, .xsnd, .din(xdata), .frame_type);

	
	// Generate a FCS
	logic dout, enb_crc;
	FSM_FCS U_FCS_FSM (.clk, .reset, .xwr(send & ~use_fsm), .din(fifo_data), .dout, .enb_crc);

	crc_8 U_CRC_GEN (.clk, .reset(reset | reset_crc), .di(dout), .enb_crc, .crc(fcs));


	// Create a module to timeout after no ack
	logic [7:0] tx_addr;

	FSM_ack_timeout U_FSM_ACK_TIMEOUT (.clk, .reset, .frame_type, .xsnd, .ack(got_ack), .ack_timeout,
										.tx_addr, .rx_addr(rxaddr), .start_ack_timeout, 
										.retry, .good_ack, .exceed_retry);

	FSM_get_dest_addr U_GET_DEST_ADDR (.clk, .reset, .data(xdata), .byte_count, .addr(tx_addr));

	FSM_retry #(.W(POINTER_WIDTH)) U_RETRY (.clk, .reset, .frame_type, .good_ack, .curr_rp(rp), 
											.set_rp, .rp_val, .retry, .xsnd(retry_send));
	counter_parm #(.W(8)) U_NAK_COUNT (.clk, .reset, .enb(exceed_retry), .q(xerrcnt));

	assign data = use_fsm ? fsm_data : fifo_data;
	assign txen = safety_cutout ? 1'b0 : mx_txen; // shutdown if there is a problem

endmodule
