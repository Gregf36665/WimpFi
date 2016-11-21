`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2016 07:51:06 PM
// Design Name: 
// Module Name: fsm_send_ack
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


module fsm_send_ack(
    input logic clk,
    input logic reset,
    input logic send_ack,
	input logic cts,
	input logic rdy,
	input logic [7:0] mac_address, src_addr,
    output logic [7:0] dout,
	output logic write,
    output logic send,
	output logic rts_ack
    );

	typedef enum logic [3:0]{
		IDLE = 4'h0,
		RTS = 4'h1,
		LOAD_DEST = 4'h2,
		LOAD_SRC  = 4'h3,
		LOAD_TYPE = 4'h4,
		SEND = 4'h5
		
	} states;

	states state, next;

	always_ff @(posedge clk)
		state <= reset ? IDLE : next;


	always_comb
	begin
		send = 0;
		rts_ack = 0;
		dout = 0;
		write = 0;
		next = IDLE;
		case(state)
		IDLE:
			next = send_ack ? LOAD_DEST : IDLE;
		LOAD_DEST:
			begin
				next = LOAD_SRC;
				dout = src_addr;
				write = 1;
			end
		LOAD_SRC:
			begin
				next = LOAD_TYPE;
				dout = mac_address;
				write = 1;
			end
		LOAD_TYPE:
			begin
				next = RTS;
				dout = 8'h33;
				write = 1;
			end
		RTS:
			begin
				rts_ack = 1;
				next = cts ? RTS : SEND;
			end
		SEND:
			begin
				send = 1;
				next = rdy ? SEND : IDLE;
			end
		endcase
	end


endmodule
