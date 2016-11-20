`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2016 01:34:22 PM
// Design Name: 
// Module Name: FSM_get_dest_addr
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


module FSM_get_dest_addr(
    input logic clk,
    input logic reset,
    input logic [7:0] data,
    input logic [7:0] byte_count,
    output logic [7:0] addr,
	input logic xsnd
    );

	logic [7:0] next_addr;
	logic store_addr;

	typedef enum logic [1:0]{
		IDLE = 2'h0,
		STORE_DATA = 2'h1,
		WAIT_FOR_SEND = 2'h2
	} states;

	states state, next;
	always_ff @(posedge clk)
			if (reset) 
			begin
				addr <= 8'h0;
				state <= IDLE;
			end
			else
			begin
				if(store_addr) addr <= data;
				state <= next;
			end
			

	always_comb
	begin
		store_addr = 0;
		next = IDLE;
		case(state)
			IDLE:
				next = (byte_count == 1) ? STORE_DATA : IDLE;
			STORE_DATA:
				begin
					store_addr = 1;
					next = WAIT_FOR_SEND;
				end
			WAIT_FOR_SEND:
				next = xsnd ? IDLE : WAIT_FOR_SEND;
	
		endcase
	end
endmodule
