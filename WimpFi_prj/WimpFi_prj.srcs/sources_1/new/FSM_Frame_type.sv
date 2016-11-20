`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 07:05:18 PM
// Design Name: 
// Module Name: FSM_Frame_type
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


module FSM_Frame_type(
    input logic clk,
    input logic reset,
    input logic [7:0] byte_count,
    input logic xsnd,
    input logic [7:0] din,
    output logic [2:0] frame_type
    );

	typedef enum logic[2:0] {
		IDLE = 3'b0,
		CHECK_FRAME_TYPE = 3'b1,
		TYPE_0 = 3'h2,
		TYPE_1 = 3'h3,
		TYPE_2 = 3'h4,
		TYPE_3 = 3'h5,
		UNKNOWN = 3'h6,
		WAIT_FOR_SEND = 3'h7
	} states;

	states state, next;

	logic [2:0] next_frame_type;
	logic update_frame_check;
	// Frame types
	// Type 0-3 as expected
	// Type 5 - Unexpected character

	always_ff @(posedge clk)
	begin
		state <= reset ? IDLE : next;
		if(reset)
			frame_type <= 0;
		else if(update_frame_check)
			frame_type <= next_frame_type;
	end

	always_comb
	begin
		next_frame_type = 0;
		update_frame_check = 0;
		case(state)
		IDLE:
			// din is once count behind so use 3 not 2
			next = (byte_count == 3) ? CHECK_FRAME_TYPE : IDLE;
		CHECK_FRAME_TYPE:
			case(din)
				8'h30: next = TYPE_0;
				8'h31: next = TYPE_1;
				8'h32: next = TYPE_2;
				8'h33: next = TYPE_3;
				default next = UNKNOWN;
			endcase
		TYPE_0:
		begin
			next_frame_type = 0;
			update_frame_check = 1;
			next = WAIT_FOR_SEND;
		end
		TYPE_1:
		begin
			next_frame_type = 1;
			update_frame_check = 1;
			next = WAIT_FOR_SEND;
		end
		TYPE_2:
		begin
			next_frame_type = 2;
			update_frame_check = 1;
			next = WAIT_FOR_SEND;
		end
		TYPE_3:
		begin
			next_frame_type = 3;
			update_frame_check = 1;
			next = WAIT_FOR_SEND;
		end
		UNKNOWN:
		begin
			next_frame_type = 5;
			update_frame_check = 1;
			next = WAIT_FOR_SEND;
		end
		WAIT_FOR_SEND:
			next = xsnd ? IDLE : WAIT_FOR_SEND;
		endcase
	end

endmodule
