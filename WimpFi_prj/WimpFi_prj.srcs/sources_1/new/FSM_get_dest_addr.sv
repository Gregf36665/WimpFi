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
    output logic [7:0] addr
    );

	logic [7:0] next_addr;
	assign next_addr = data;

	always_ff @(posedge clk)
		if (reset) addr <= 8'h0;
		else if(byte_count == 1) addr <= next_addr;

endmodule
