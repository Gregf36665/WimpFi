`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 08:54:24 AM
// Design Name: 
// Module Name: FSM_uart_to_mx
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


module FSM_uart_to_mx(
    input logic clk,
    input logic reset,
    input logic [7:0] data_in,
    output logic [7:0] data_out,
    output logic save_byte,
    output logic send
    );

	typedef enum logic[3:0] {
		IDLE = 4'h0,
		SAVE_DATA = 4'h1,
		SEND = 4'h2
	} states;

	states state, next;

	always_ff @(posedge clk)
		state <= reset ? IDLE : next;

	always_comb
	begin
		save_byte = 0;
		send = 0;

	end

endmodule
