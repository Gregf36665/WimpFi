`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Greg
// 
// Create Date: 10/29/2016 01:46:34 PM
// Design Name: 
// Module Name: fifo_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Continiously try to drain a FIFO and push it out to a tx
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo_fsm(input logic clk, empty, reset, ready,
				output logic read, send,
				input logic [7:0] data_fifo,
				output logic [7:0] data_fsm);
	
	// Internal signal to update data output
	logic update_data;

	always_ff @(posedge clk)
	begin
		if (reset)
		begin
			state <= IDLE;
			data_fsm <= 0;
		end
		else
		begin
			state <= next_state;
			if(update_data) data_fsm <= data_fifo;
		end
	end

	typedef enum logic [1:0] {
		IDLE = 0,
		UPDATE_DATA = 1,
		CHECK_READY = 2,
		SEND = 3
	} states;

	states state, next_state;

	always_comb
	begin
		// Default conditions
		read = 0;
		update_data = 0;
		send = 0;
		next_state = IDLE;
		case(state)
			IDLE: 
				if(!empty) next_state = UPDATE_DATA;
			UPDATE_DATA:
				begin
					next_state = CHECK_READY;
					update_data = 1;
				end
			CHECK_READY:
					if(ready) next_state = SEND;
					else next_state = CHECK_READY;
			SEND:
				begin
					send = 1;
					read = 1;
					next_state = IDLE;
				end
		endcase
	end				
endmodule
