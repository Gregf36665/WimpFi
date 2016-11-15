`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
// Title         : Nexys4 Simple Top-Level File
// Project       : ECE 491
//-----------------------------------------------------------------------------
// File          : nexys4DDR.sv
// Author        : John Nestor  <nestorj@nestorj-mbpro-15>
// Created       : 22.07.2016
// Last modified : 22.07.2016
//-----------------------------------------------------------------------------
// Description :
// This file provides a starting point for Lab 1 and includes some basic I/O
// ports.  To use, un-comment the port declarations and the corresponding
// configuration statements in the constraints file "Nexys4DDR.xdc".
// This module only declares some basic i/o ports; additional ports
// can be added - see the board documentation and constraints file
// more information
//-----------------------------------------------------------------------------
// Modification history :
// 22.07.2016 : created
//-----------------------------------------------------------------------------

module nexys4DDR (
          input logic         CLK100MHZ,
		  input logic [15:0]  SW,
		  input logic 	      BTNC,
		  input logic 	      BTND,
		  output logic [6:0]  SEGS,
		  output logic [7:0]  AN,
		  output logic 	      DP,
//		  input logic         UART_TXD_IN,
		  input logic         IN_JA1,
		  output logic        OUT_JA2,
		  output logic        OUT_JA3,
		  output logic        OUT_JA4,
		  output logic        UART_RXD_OUT,
		  output logic		  LED16_R, LED16_G,
		  output logic		  LED17_R, LED17_G,
		  output logic		  OUT_JB1, OUT_JB2,
							  OUT_JB3, OUT_JB4
            );


	// Clock and reset
	assign clk = CLK100MHZ;
	assign reset = BTNC; // GSR

	// PMOD connections
	assign rxdata = IN_JA1; // Rx on pin 1
	assign OUT_JA2 = txdata;  // Tx on pin 2
	assign OUT_JA3 = ~txen; // txen is the inversion of pin 3
	assign OUT_JA4 = 1'b1; // This pin should always be high

	// Debugging connections
	assign OUT_JB1 = IN_JA1; // the rx line
	assign OUT_JB2 = looking;
	assign OUT_JB3 = cardet;
	assign OUT_JB4 = error;


	//Button connections
	assign enb = BTND;

	// Length selection
	logic [5:0] length;
	assign length = SW[5:0]; // The 6 switches to the right
	// internal signals
	logic txdata, txen;
	logic cardet, error; // These are internal signals that can be used

	logic looking; // signal to connect the looking pulse

	ReceiverTestUnit U_RX_UNIT (.clk, .reset, .rxdata, .SEGS, .AN, .DP,
								.cardet, .error, .UART_RXD_OUT,
								.LED16_R, .LED16_G, .LED17_R, .LED17_G,
								.looking);

	TransmitterTestUnit U_TX_UNIT (.clk, .reset, .enb, .length,
									.txen, .txdata);


                                            
endmodule // nexys4DDR
