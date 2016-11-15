`timescale 1ns / 1ps
// A module that allows an interface between
// a manchester transmitter and a wimpFi radio
// Created by Greg Flynn
// 2016-11-01

module TransmitterTestUnit(
			input logic clk,
			input logic reset,
			input logic enb,
			input logic [5:0] length,
			output logic txen,
			output logic txdata
            );


    // Connection between mx_test and data
	logic [7:0] data;
	
	
	logic send; // internal send signal
	logic run; // run signal

	// Modules to connect
	
	// Single pulser to enable MX_test once
	single_pulser U_PULSER (.clk, .reset, .pulse(run), .enb);

	// mx_test, ROM to send bytes 
	mxtest_2 U_MXTEST (.clk, .reset, .run, .length, .send, .data, .ready(rdy));

	// transmitter 
	manchester_tx U_TX (.clk, .reset, .send, .txen, .data, .rdy, .txd(txdata));

                                            
endmodule
