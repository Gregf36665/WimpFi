`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
// Title         : 7-Segment Display Controller
// Project       : ECE 491 - Senior Design Project 1
//-----------------------------------------------------------------------------
// File          : dispctl.sv
// Author        : John Nestor
// Created       : 08.08.2011
// Last modified : 07.22.2015
//-----------------------------------------------------------------------------
// Description :
// Control circuit that handles time-multiplexing of eight different 4-bit binary
// inputs to the time-multiplexed seven-segment display on the Nexys4DDR board.
// Output seg[6:0] connects to the seven-segment output to the display, while
// output an[7:0] enables whichever digits are held low.  This circuit must be
// clocked at a relatively low frequency for the time-multiplexing to work
// properly.
//-----------------------------------------------------------------------------
// Modification history :
// 08.08.2011 : created (original Verilog version)
// 07.22.2015 : ported to SystemVerilog and expanded to 8 digits for nexys4ddr
//-----------------------------------------------------------------------------

module dispctl (
		input logic 	   clk,
		input logic 	   reset,
		input logic [3:0]  d7, d6, d5, d4, d3, d2, d1, d0,
		input logic 	   dp7, dp6, dp5, dp4, dp3, dp2, dp1, dp0,
		output logic [6:0] seg,
		output logic dp,
		output logic [7:0] an
		);

   logic 			   enb;
   logic               [2:0] Q;
   logic               [7:0] an_n;
   logic               [3:0] seg_val;

   clkenb #(.DIVFREQ(1000)) U_CLKENB(.clk(clk), .enb(enb), .reset(reset));

   counter_parm #(.W(3)) U_COUNTER(.clk(clk), .enb(enb), .reset(reset), .q(Q), .carry());
   
   decoder_3_8_en U_DECODER (.a(Q), .enb(1'b1), .y(an_n));
   
   // Anodes and Decimal points are active-low
   assign an = ~an_n;
   assign dp = ~dp_n;
   
   mux8_parm #(.W(1)) U_DPMUX(.d0(dp0), .d1(dp1), .d2(dp2), .d3(dp3), .d4(dp4), 
               .d5(dp5), .d6(dp6), .d7(dp7), .sel(Q), .y(dp_n));
               
   mux8_parm #(.W(4)) U_SEGMUX(.d0(d0), .d1(d1), .d2(d2), .d3(d3), .d4(d4), 
               .d5(d5), .d6(d6), .d7(d7), .sel(Q), .y(seg_val));
               
   seven_seg U_SEVEN_SEG (.data(seg_val), .segments(seg));             

endmodule // dispctl

   
