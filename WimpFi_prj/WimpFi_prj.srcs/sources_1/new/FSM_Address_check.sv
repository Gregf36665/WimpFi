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
	input [7:0] address,
	input [7:0] data,
    output logic write_enb,
	output logic clear_fifo
    );

	localparam ALL_CALL = 8'h2a; // all call address = *

	typedef enum logic [1:0] {
		IDLE = 2'b00,
		STORE_DATA = 2'b01,
		NOT_US = 2'b10,
		FLUSH = 2'b11
	} states;

	states state, next;

	always_ff @(posedge clk)
		state <= reset ? IDLE : next;

	always_comb
	begin
		// Default values
		clear_fifo = 0;
		write_enb = 0;
		next = IDLE;

		case(state)
			IDLE: // Wait till data is coming in
				if(write)
				begin
					if(data == address) next = STORE_DATA;
					if(data == ALL_CALL) next = STORE_DATA;
				end
			STORE_DATA:
				// If match on address start saving data
				begin
					write_enb = 1;
					if(error) next = FLUSH;
					else next = cardet ? STORE_DATA : IDLE;
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
		endcase
	end

endmodule
