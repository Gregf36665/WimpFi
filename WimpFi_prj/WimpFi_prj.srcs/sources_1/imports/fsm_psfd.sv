`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Raji Birru & Greg Flynn
// 
// Create Date: 10/20/2016 08:00:54 PM
// Design Name: 
// Module Name: fsm_psfd
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: One of a set of three finite state machines that form the nucleus
// of a Manchester Reciever design. This is in charge of detecting the preamble 
// and then SFD from an incoming serial manchester encoded signal, then setting
// off flags to alert when valid SFD and preamble are found.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fsm_psfd(
		input logic clk, reset, preamble_match, sfd_match, set_ferr, data_done,
		input logic [6:0] slow_sample_count,
		output logic cardet, bit_count_reset, sample_count_reset, slow_sample_reset, 
		clr_ferr, enable_pll, enable_data
		);
				
		typedef enum logic [2:0] {
			IDLE 			  = 3'b000,
			PREAMBLE_MATCH    = 3'b001,
			RESET_SLOW_SAMPLE = 3'b010,
			SFD_MAYBE 		  = 3'b011,
			STARTING		  = 3'b100,
			START 			  = 3'b101,
			RESET			  = 3'b111
		} states;
				
		states state, next;
		
		always_ff @(posedge clk)
			begin
				if(reset) state <= RESET;
				else state <= next;
			end
			
		always_comb
			begin
				
				cardet = 1'b0;
				bit_count_reset = 1'b0;
				sample_count_reset = 1'b0;
				slow_sample_reset = 1'b0;
				clr_ferr = 1'b0;
				enable_pll = 1'b0;
				next = IDLE;
				enable_data = 1'b0;
							
				unique case (state)
					IDLE:
						begin
							if(preamble_match) next = PREAMBLE_MATCH;
							else next = IDLE;
							bit_count_reset      = 1'b1;
							sample_count_reset   = 1'b1;
							slow_sample_reset    = 1'b1;
						end
					PREAMBLE_MATCH:
						begin
							// This looks at the lowest 6 bits of sample
							// This lets the sample count go to 63
							if(slow_sample_count [5:0] == 6'd33)
								begin
									if(!preamble_match) next = RESET_SLOW_SAMPLE;
									else next = PREAMBLE_MATCH;
								end
							else next = PREAMBLE_MATCH;
							cardet = 1'b1;
						end
					RESET_SLOW_SAMPLE:
						begin
							next = SFD_MAYBE;
							cardet = 1'b1;
							slow_sample_reset = 1'b1;
						end
					SFD_MAYBE:
						begin
							if(sfd_match) next = STARTING; // Found SFD
							else if(slow_sample_count == 7'd127) // We should have seen SFD by here
								next = preamble_match ? PREAMBLE_MATCH: IDLE; // Didn't see anything
							else next = SFD_MAYBE;
							cardet = 1'b1;
						end
					STARTING:
						begin
							next = START;
							// Start up the other 2 FSMs
							clr_ferr = 1'b1;
							enable_pll = 1'b1;
							enable_data = 1'b1;
							cardet = 1'b1; // Keep cardet high
						end
					START:
						begin
							if(set_ferr)
								next = IDLE;
							else
								begin
									if(data_done) next = IDLE;
									else next = START;
								end
							cardet = 1'b1;
							enable_pll = 1'b1;
							enable_data = 1'b1;
						end
					RESET:
					begin
						next = IDLE;
						bit_count_reset = 1'b1;
						sample_count_reset = 1'b1;
						slow_sample_reset = 1'b1;
					end
					default:
						next = RESET;
				endcase
			end
endmodule		
