`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
// Title         : Correlator
// Project       : ECE 491 Senior Design 1
//-----------------------------------------------------------------------------
// File          : correlator.sv
// Author        : John Nestor  <nestorj@nestorj-mbpro-15>
// Modified by   : Greg Flynn   <flynng@lafayette.edu>
// Created       : 22.09.2016
// Last modified : 30.09.2016
//-----------------------------------------------------------------------------
// Description :
// Inputs a sequence of bits on d_in and computes the number matching bits a sequence
// of LEN most recent bits with a PATTERN of the same length.
// Asserts h_out true when the number of matching bits equals or exceeds
// threshold value HTHRESH.
// Asserts l_out true when the number of matching equals or is less than LTHRESH.
//-----------------------------------------------------------------------------
// Modification history :
// 22.09.2016 : created
// 30.09.2016 : Overhauled ones function
//-----------------------------------------------------------------------------



module correlator #(parameter LEN=16, PATTERN=16'b0000000011111111, HTHRESH=13, LTHRESH=3, W=$clog2(LEN)+1)
          (
	      input logic 	   clk,
	      input logic 	   reset,
	      input logic 	   enb,
	      input logic 	   d_in,
	      output logic [W-1:0] csum,
	      output logic 	   h_out,  
	      output logic 	   l_out
	      );


	logic [LEN-1:0] 		   shreg, match_count;


	// shift register shifts from right to left so that oldest data is on
	// the left and newest data is on the right
	always_ff  @(posedge clk)
		if (reset) shreg <= '0;
		else if (enb) shreg <= { shreg[LEN-2:0], d_in };

	// FF for csum
	always_ff @(posedge clk)
		if(enb) csum <= count_ones(.val(match_count));


	assign match_count = shreg ^~ PATTERN;

	//assign csum = count_ones(.val(match_count));

	assign h_out = csum >= HTHRESH;

	assign l_out = csum <= LTHRESH;

	logic [2:0] test_1, test_2, test_3;
	assign test_1 = count_ones6(match_count[0+:6]);
	assign test_2 = count_ones6(match_count[6+:6]);
	assign test_3 = count_ones6(.val(match_count[12+:6]));

	// This sends the value into a 6 bit LUT
	// From there all of the values are summed together
	function int count_ones (input [LEN-1:0] val);
		int i;
		localparam PADDING = LEN % 6;
		localparam WIDTH = LEN + PADDING; // ceil LEN to factor of 6
		localparam OUTPUT_WIDTH = $clog2(WIDTH) + 1;

		static logic [PADDING - 1: 0] pad = '0; // get the data a factor of 6
		automatic logic [WIDTH-1:0] data;
		automatic logic [W-1:0] ones = 0;
		automatic logic [5:0] tmp;

		data = {pad, val};
		for (i=0; i< WIDTH / 6; i++)
			ones += count_ones6(.val(data[i*6+:6]));

		return ones; 
	endfunction


	function [2:0] count_ones6(input [5:0] val);
	automatic logic [2:0] out; // set the output
	// Generated in python
	// for x in range(64):
	// print ("6'd%d: out = 3'd%d;" % (x, count_one(x)))
	// 
	// def count_one(a):
	// return bin(a)[2:].count('1')
	case(val)
		6'd0: out = 3'd0;
		6'd1: out = 3'd1;
		6'd2: out = 3'd1;
		6'd3: out = 3'd2;
		6'd4: out = 3'd1;
		6'd5: out = 3'd2;
		6'd6: out = 3'd2;
		6'd7: out = 3'd3;
		6'd8: out = 3'd1;
		6'd9: out = 3'd2;
		6'd10: out = 3'd2;
		6'd11: out = 3'd3;
		6'd12: out = 3'd2;
		6'd13: out = 3'd3;
		6'd14: out = 3'd3;
		6'd15: out = 3'd4;
		6'd16: out = 3'd1;
		6'd17: out = 3'd2;
		6'd18: out = 3'd2;
		6'd19: out = 3'd3;
		6'd20: out = 3'd2;
		6'd21: out = 3'd3;
		6'd22: out = 3'd3;
		6'd23: out = 3'd4;
		6'd24: out = 3'd2;
		6'd25: out = 3'd3;
		6'd26: out = 3'd3;
		6'd27: out = 3'd4;
		6'd28: out = 3'd3;
		6'd29: out = 3'd4;
		6'd30: out = 3'd4;
		6'd31: out = 3'd5;
		6'd32: out = 3'd1;
		6'd33: out = 3'd2;
		6'd34: out = 3'd2;
		6'd35: out = 3'd3;
		6'd36: out = 3'd2;
		6'd37: out = 3'd3;
		6'd38: out = 3'd3;
		6'd39: out = 3'd4;
		6'd40: out = 3'd2;
		6'd41: out = 3'd3;
		6'd42: out = 3'd3;
		6'd43: out = 3'd4;
		6'd44: out = 3'd3;
		6'd45: out = 3'd4;
		6'd46: out = 3'd4;
		6'd47: out = 3'd5;
		6'd48: out = 3'd2;
		6'd49: out = 3'd3;
		6'd50: out = 3'd3;
		6'd51: out = 3'd4;
		6'd52: out = 3'd3;
		6'd53: out = 3'd4;
		6'd54: out = 3'd4;
		6'd55: out = 3'd5;
		6'd56: out = 3'd3;
		6'd57: out = 3'd4;
		6'd58: out = 3'd4;
		6'd59: out = 3'd5;
		6'd60: out = 3'd4;
		6'd61: out = 3'd5;
		6'd62: out = 3'd5;
		6'd63: out = 3'd6;
	endcase

	return out;

	endfunction
endmodule
