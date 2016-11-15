`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2016 11:06:24 AM
// Design Name: 
// Module Name: accumulator
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


module accumulator(
    input logic clk,
    input logic reset,
    input logic inc_error,
    input logic dec_error,
    input logic [5:0] error_change,
    output logic sample_inc,
    output logic sample_dec
    );

	
	logic [6:0] error, next_error; //What is the current error
	logic sample_inc_next, sample_dec_next; // store the sample inc and dec signals for 1 clk

	always_ff @(posedge clk)
		begin
			if(reset) 
			begin
				error <= 7'd32; // This is the reset position
									  // Prevent lt 0 numbers
				sample_inc <= 0;
				sample_dec <= 0;
			end
			else 
			begin
				error <=  next_error;
				sample_inc <= sample_inc_next;
				sample_dec <= sample_dec_next;
			end
		end

	localparam GAIN = 8; // 1/GAIN for the feedback loop
	always_comb
	begin
		// Default values
		sample_inc_next = 0;
		sample_dec_next = 0;
		next_error = error;
		if (inc_error)
			if(error > 32 + GAIN)
			begin
				sample_inc_next = 1;
				next_error = error + error_change - GAIN;
			end
			else
				next_error = error + error_change;
		else if(dec_error)
			if(error < 32 - GAIN)
			begin
				sample_dec_next = 1;
				next_error = error - error_change + GAIN;
			end
			next_error = error - error_change;
	end


endmodule
