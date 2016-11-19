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
    output logic cardet,
    output logic xrdy,
    output logic [7:0] xerrcnt
    );

	// Internal connections
	logic [7:0] data, fsm_data, fifo_data; // connection from FIFO to data
	logic empty, re, rdy, send, rts, use_fsm;
	manchester_tx #(.BIT_RATE(BIT_RATE)) U_TX_MX (.clk, .send, .reset, .data, 
													.rdy, .txen, .txd);

	p_fifo #(.DEPTH(255)) U_BUFFER (.clk, .rst(~reset), .clr(), .din(xdata), .we(xwr), .re,
									.full(), .empty, .dout(fifo_data));

	FSM_fifo_to_send U_FSM_TX (.clk, .reset, .xsnd, .empty, .rts, .cts,
								.rdy, .send, .read_data(re), .xrdy, .data(fsm_data), 
								.use_fsm);

	assign data = use_fsm ? fsm_data : fifo_data;
	assign cts = 1'b1; // todo implement rts/cts
	assign xerrcnt = 0; // todo implement crc checking

endmodule
