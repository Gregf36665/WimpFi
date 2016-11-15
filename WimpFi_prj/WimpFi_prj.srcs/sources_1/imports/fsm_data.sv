`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Raji Birru & Greg Flynn
// 
// Create Date: 10/20/2016 08:02:22 PM
// Design Name: 
// Module Name: fsm_data
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: One of a set of three finite state machines that form the nucleus
// of a Manchester Reciever design. This is in charge of recieving data bytes in a
// frame.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fsm_data(
		input logic clk, reset, match_one, match_zero, match_idle, match_error, enable_data,
		input logic [5:0] sample_count,
		input logic [2:0] bit_count,
		output logic data_bit, store_bit, store_byte, set_ferr, write, data_done, 
		output logic set_ferr1, set_ferr2, set_ferr3
		);
				
		typedef enum logic [3:0] {
			IDLE 			  = 4'h0,
			START_RECIEVE     = 4'h1,
			LOOKING			  = 4'h2,
			FOUND_ONE		  = 4'h3,
			FOUND_ZERO 		  = 4'h4,
			STORE_DATA		  = 4'h5,
			BYTE_DONE		  = 4'h6,
			WAIT_FOR_NEXT	  = 4'h7,
			ERROR 			  = 4'h8,
			MISSED			  = 4'h9,
			EARLY_STOP		  = 4'hA
		} states;
				
		states state, next;
		logic look;
		
		always_ff @(posedge clk)
			begin
				if(reset) state <= IDLE;
				else state <= next;
			end
			
		always_comb
			begin
				
				look = 1'b0; // this is an internal signal for debugging
				data_bit 	= 1'b0;
				store_bit 	= 1'b0;
				store_byte 	= 1'b0;
				set_ferr    = 1'b0;
				set_ferr1    = 1'b0;
				set_ferr2    = 1'b0;
				set_ferr3    = 1'b0;
				write       = 1'b0;
				data_done   = 1'b0;
							
				case (state)
					IDLE:
					   begin
					       next = enable_data ? START_RECIEVE : IDLE;
					       data_done = 1'b1;
					   end
					START_RECIEVE:
						begin
							if(!enable_data) next = IDLE;
							else next = sample_count == 60 ? LOOKING : START_RECIEVE;
						end
					// The sample count is where we expect to see another correlation
					LOOKING:
					begin
						look = 1'b1;
						if(match_one) next = FOUND_ONE;
						else if(match_zero) next = FOUND_ZERO;
						// Check if we got an EOF at the right point
						else if(match_idle) next = bit_count == 3'b0 ? IDLE: EARLY_STOP;
						else if(match_error) next = ERROR;
						else if(sample_count == 20) next = MISSED; // We missed it
						else next = LOOKING;
					end
					FOUND_ONE:
						begin
							next = STORE_DATA;
							data_bit = 1'b1;
							store_bit = 1'b1;
						end
					FOUND_ZERO:
						begin
							next = STORE_DATA;
							data_bit = 1'b0;
							store_bit = 1'b1;
						end
					STORE_DATA:
						begin
							if(bit_count == 3'b000)	next = BYTE_DONE;
							else next = WAIT_FOR_NEXT;
						end
					BYTE_DONE:
						begin
							next = WAIT_FOR_NEXT;
							store_byte = 1'b1;
							write = 1'b1;
							// Why do we have 2 wires that do the same thing???
							// Because write must happen one clock cycle later
						end
					WAIT_FOR_NEXT:
						next = sample_count >= 21 &&
							   sample_count < 60 ? START_RECIEVE : WAIT_FOR_NEXT;
						// Stay here until sample count has gone past where we are looking
						// Added in <60 to allow overflow first
					ERROR:
					    begin
						  next = IDLE;
						  set_ferr = 1'b1;
						  set_ferr2 = 1'b1;
						end
					MISSED:
						// This is a different state for debugging
					    begin
						  next = IDLE;
						  set_ferr = 1'b1;
						  set_ferr1 = 1'b1;
						end
					EARLY_STOP:
						begin
							next = IDLE;
							set_ferr = 1'b1;
							set_ferr3 = 1'b1;
						end
					default:
						next = IDLE;
				endcase
			end
endmodule		
