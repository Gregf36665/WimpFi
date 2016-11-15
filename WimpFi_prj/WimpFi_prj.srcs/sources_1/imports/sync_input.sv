`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Greg
// 
// Create Date: 10/22/2016 03:59:37 PM
// Design Name: 
// Module Name: sync_input
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Simple synchronizer, can be made larger (more ff)if needed
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sync_input(
    input logic clk,
    input logic async_in,
    output logic sync_out
    );

	always_ff @(posedge clk)
		sync_out <= async_in;

endmodule
