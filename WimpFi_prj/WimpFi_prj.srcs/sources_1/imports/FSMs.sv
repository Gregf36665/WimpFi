`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Lafayette
// Engineer: Greg
// 
// Create Date: 10/22/2016 03:18:56 PM
// Design Name: 
// Module Name: FSMs
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

module FSMs(input logic clk, reset, preamble_match, sfd_match, match_error, 
            match_idle, match_one, match_zero,
			input logic [6:0] slow_sample_count,
			input logic [5:0] sample_count,
			input logic [2:0] bit_count,
			input logic [6:0] zero_one_strength,
			output logic sample_inc, sample_dec, bit_count_reset, store_bit, 
			slow_sample_reset, data_bit, cardet, store_byte, clr_ferr, set_ferr, 
			write, sample_count_reset, set_ferr1, set_ferr2, set_ferr3);

	logic enable_pll;
	logic enable_data;
	logic data_done;
	logic write_next;
	logic inc_error, dec_error;
	logic [5:0] error_change; // How far out of sync are we

	fsm_pll  U_PLL    (.clk, .reset, .data_bit(data_bit_last), .enable_pll, .sample_count, 
			           .current_corr(zero_one_strength), .sample_inc(inc_error), .sample_dec(dec_error),
					   .error_change);

	fsm_psfd U_DETECT (.clk, .reset, .preamble_match, .sfd_match, .set_ferr,
					   .data_done,  .slow_sample_count, .cardet, .bit_count_reset,
					   .sample_count_reset, .slow_sample_reset, .clr_ferr, .enable_pll, .enable_data);

	fsm_data U_DATA   (.clk, .reset, .match_one, .match_zero, .match_idle, .match_error,
					   .sample_count, .bit_count, .data_bit, .store_bit, .store_byte,
					   .set_ferr, .write(write_next), .enable_data, .data_done, .set_ferr1, .set_ferr2, .set_ferr3);


	
	one_bit_ff U_LAST_BIT (.clk, .reset, .enb(store_bit), .D(data_bit), .Q(data_bit_last));
					
	sync_input U_WRITE (.clk, .async_in(write_next), .sync_out(write));

	accumulator U_ERROR_ACCUM (.clk, .reset, .inc_error, .dec_error, 
								.error_change, .sample_inc, .sample_dec);
endmodule
