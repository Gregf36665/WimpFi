`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Raji Birru & Greg Flynn
// 
// Create Date: 10/20/2016 08:07:20 PM
// Design Name: 
// Module Name: fsm_pll
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: One of a set of three finite state machines that form the nucleus
// of a Manchester Reciever design. This works to continiously improve the quality
// of our sampling by use of a Phase-Locked Loop.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fsm_pll(
		input logic clk, reset, data_bit, enable_pll,
		input logic [5:0] sample_count, 
		input logic [6:0] current_corr,
		output logic sample_inc, sample_dec,
		output logic [5:0] error_change
		);
				
		typedef enum logic [3:0] {
			IDLE 			  = 4'b0000,
			WAIT			  = 4'b0001,
			FIND_MINMAX		  = 4'b0010,
			UPDATE_MAX 		  = 4'b0011,
			UPDATE_MIN		  = 4'b0100,
			UPDATE_TIME_MAX	  = 4'b0101,
			UPDATE_TIME_MIN   = 4'b0110,
			INC_SAMPLE        = 4'b0111,
			DEC_SAMPLE		  = 4'b1000,
			INC_DEC			  = 4'b1001
		} states;
				
		states state, next;
		
		// Register values to store important values
		logic [6:0] min_corr, max_corr;
		logic [5:0] min_time, max_time, final_time;
		// Enable signals to use registers
		logic update_min_time, update_max_time, update_min_corr, update_max_corr;
		logic update_final_time;
		// Wires for the next value to use
		logic [6:0] next_min_corr, next_max_corr;
		logic [5:0] next_min_time, next_max_time, next_final_time;
		
		// Wire to figure out how far out of sync we are
		logic [5:0] next_error_change;

		logic look; // Internal signal for debugging

		always_ff @(posedge clk)
			begin
				if(reset | !enable_pll) 
				begin
					state <= IDLE;
					min_time <= 0;
					max_time <= 0;
					min_corr <= 0;
					max_corr <= 0;
					final_time <= 0;
					error_change <= 0;
				end
				else
				begin 
					state <= next;
					if(update_min_time) min_time <= next_min_time;
					if(update_max_time) max_time <= next_max_time;
					if(update_min_corr) min_corr <= next_min_corr;
					if(update_max_corr) max_corr <= next_max_corr;
					if(update_final_time) final_time <= next_final_time;
					error_change <= next_error_change;
				end
			end
			
		always_comb
			begin
				look = 1'b0;
				
				sample_inc = 1'b0;
				sample_dec = 1'b0;
				
				next_min_corr = 7'd0;
				next_max_corr = 7'd0;
			
				next_final_time = 6'd0;
				next_min_time = 6'd0;
				next_max_time = 6'd0;
				
				update_min_time = 0;
				update_max_time = 0;
				update_min_corr = 0;
				update_max_corr = 0;
				update_final_time = 0;
				
				next_error_change = 0;

				next = IDLE;
							
				unique case (state)
					IDLE:
						if(enable_pll) next = WAIT;
						else next = IDLE;
					WAIT:
						begin
							if(sample_count == 6'd40) next = FIND_MINMAX; // Start looking
							else next = WAIT;
							next_final_time = 6'd0;
							next_min_corr = 7'd127; // Reset values to default
							next_max_corr = 7'd0;
							// write the values
							update_min_corr = 1'b1;
							update_max_corr = 1'b1;
							update_final_time = 1'b1;
						end
					FIND_MINMAX:
						begin
							if(sample_count == 6'd20) // at the end of looking
								if(data_bit == 1'b1) next = UPDATE_TIME_MAX;
								else next = UPDATE_TIME_MIN;
							else if (current_corr > max_corr) next = UPDATE_MAX;
							else if (current_corr < min_corr) next = UPDATE_MIN;
							else next = FIND_MINMAX;
							look = 1'b1;
						end
					UPDATE_MAX:
						begin
							next = FIND_MINMAX;
							next_max_corr = current_corr;
							next_max_time = sample_count;
							// Update the values
							update_max_time = 1'b1;
							update_max_corr = 1'b1;
						end
					UPDATE_MIN:
						begin
							next = FIND_MINMAX;
							next_min_corr = current_corr;
							next_min_time = sample_count;
							// Update values
							update_min_time = 1'b1;
							update_min_corr = 1'b1;
						end
					UPDATE_TIME_MAX:
						begin
							next = INC_DEC;
							next_final_time = max_time;
							update_final_time = 1'b1;
						end
					UPDATE_TIME_MIN:
						begin
							next = INC_DEC;
							next_final_time = min_time;
							update_final_time = 1'b1;
						end
					INC_DEC:
						begin
							// This is how far we are off by
							next_error_change = final_time > 32 ? 64 - final_time : final_time;
							if((final_time <= 6'd20) && (final_time >= 6'd4)) next = DEC_SAMPLE;
							else if((final_time <= 6'd60) && (final_time >= 6'd40)) next = INC_SAMPLE;
							else next = WAIT;
						end
					INC_SAMPLE:
						begin
							next = WAIT;
							sample_inc = 1'b1;
						end
					DEC_SAMPLE:
						begin
							next = WAIT;
							sample_dec = 1'b1;
						end
					default:
						next = IDLE;
				endcase
			end
endmodule		
