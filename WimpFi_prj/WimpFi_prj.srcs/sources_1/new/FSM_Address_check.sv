`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2016 12:45:56 PM
// Design Name: 
// Module Name: FSM_Address_check
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


module FSM_Address_check(
    input clk,
    input reset,
    input write,
    input cardet,
	input error,
	input empty,
	input [7:0] address,
	input [7:0] data,
    output logic write_enb,
	output logic force_write,
	output logic clear_fifo,
	output logic data_available
    );

	localparam ALL_CALL = 8'h2a; // all call address = *

	typedef enum logic [2:0] {
		IDLE = 3'b000,
		STORE_DATA = 3'b001,
		NOT_US = 3'b010,
		FLUSH = 3'b011,
		DONE = 3'b100
	} states;

	states state, next;

	always_ff @(posedge clk)
		state <= reset ? IDLE : next;

	always_comb
	begin
		// Default values
		clear_fifo = 0;
		write_enb = 0;
		data_available = 0;
		next = IDLE;
		force_write = 0;

		case(state)
			IDLE: // Wait till data is coming in
				if(write) // saw a good byte
				begin
					if(data == address)
					begin
						next = STORE_DATA;
						force_write = 1; // Save the dest address
					end
					else if(data == ALL_CALL) 
					begin
						next = STORE_DATA;
						force_write = 1; // save the all call address
					end
					else next = NOT_US; // address didn't match us
				end
			STORE_DATA:
				// If match on address start saving data
				begin
					write_enb = 1;
					if(error) next = FLUSH;
					else next = cardet ? STORE_DATA : DONE;
				end
			FLUSH:
				// If there is an error with the receiver error
				begin
					clear_fifo = 1;
					next = IDLE;
				end
			NOT_US:
				// If it is not our address wait till cardet drops
				next = cardet ? NOT_US : IDLE;
			DONE:
				// Wait until the FIFO has been drained
				begin
					data_available = 1;
					next = empty ? IDLE : DONE;
				end

		endcase
	end

endmodule
