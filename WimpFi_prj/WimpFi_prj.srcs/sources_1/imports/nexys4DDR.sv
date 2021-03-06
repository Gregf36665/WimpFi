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
		  input logic [7:0]   SW,
		  input logic 	      BTNC,
		  input logic 	      BTND,
		  output logic [6:0]  SEGS,
		  output logic [7:0]  AN,
		  output logic 	      DP,
		  input logic         UART_TXD_IN,
		  input logic         IN_JA1,
		  output logic        OUT_JA2,
		  output logic        OUT_JA3,
		  output logic        OUT_JA4,
		  output logic        UART_RXD_OUT,
		  output logic		  LED16_R, LED16_G,
		  output logic		  LED17_R, LED17_G,
		  output logic		  OUT_JB1, OUT_JB2,
							  OUT_JB3, OUT_JB4,
							  OUT_JB5, OUT_JB6	
            );


	// Clock and reset
	assign clk = CLK100MHZ;
	assign reset = BTNC; // GSR

	// PMOD connections
	assign rxd = IN_JA1; // Rx on pin 1
	assign OUT_JA2 = txd;  // Tx on pin 2
	assign OUT_JA3 = ~txen; // txen is the inversion of pin 3
	assign OUT_JA4 = 1'b1; // This pin should always be high

	// Debugging connections
	logic xrdy, xsnd, rrdy;
	assign OUT_JB1 = IN_JA1; // the rx line
	assign OUT_JB2 = xrdy;
	assign OUT_JB3 = cardet | BTND;
	assign OUT_JB4 = txen;
	assign OUT_JB5 = send_ack;
	assign OUT_JB6 = rrdy;

	logic [3:0] debug;
	logic [7:0] txaddr;

	// internal signals
	logic txd, txen, got_ack, send_ack;
	logic cardet; // These are internal signals that can be used
	logic [7:0] xerrcnt, rerrcnt, rxaddr;

	dispctl U_SEG_CTL (.clk, .reset, .d7(SW[7:4]), .d6(SW[3:0]), .d5(rerrcnt[7:4]), 
					.d4(rerrcnt[3:0]), .d3(rxaddr[7:4]), .d2(rxaddr[3:0]), .d1(xerrcnt[7:4]), 
					.d0(xerrcnt[3:0]), .dp7(1'b0), .dp6(1'b0), .dp5(1'b0), 
					.dp4(1'b0), .dp3(1'b0), .dp2(1'b0), .dp1(1'b0), .dp0(1'b0), 
					.seg(SEGS), .dp(DP), .an(AN)); 

	receiver_side U_RX_SIDE (.clk, .reset, .rxd, .SW, .UART_RXD_OUT, .cardet, .rerrcnt,
							.src(rxaddr), .got_ack, .send_ack, .rrdy);


	transmitter_side U_TX_SIDE (.clk, .reset, .UART_TXD_IN, .cardet(cardet | BTND), .txen, .txd, .xrdy, .xsnd,
								.xerrcnt, .rxaddr, .got_ack, .send_ack, .mac_address(SW));


	assign LED16_G = cardet | BTND;
	assign LED16_R = txen;
	assign LED17_R = ~xrdy;
	assign LED17_G = 1'b0;
                                            
endmodule // nexys4DDR
