`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Greg
// 
// Create Date: 10/26/2016 07:02:22 PM
// Design Name: 
// Module Name: one_bit_ff
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// A simple 1 bit register
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module one_bit_ff(
    input logic clk,
    input logic reset,
    input logic D,
    output logic  Q,
    input logic enb
    );

	always_ff @(posedge clk)
		if (reset) Q <= 1'b0;
		else if(enb) Q <= D;

endmodule
