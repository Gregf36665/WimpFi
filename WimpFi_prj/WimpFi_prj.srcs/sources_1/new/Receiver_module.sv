`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Greg Flynn
// 
// Create Date: 11/15/2016 08:46:07 AM
// Design Name: 
// Module Name: Receiver_module
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


module Receiver_module(
    input clk,
    input reset,
	input rxd,
	output [7:0] data,
	output cardet,
	output  somethign
    );

	
	// Attach the MX receiver
	U_MX_RX mx_rcvr(.clk, .reset, .rxd, .cardet, .data, .write, .error, .error1()
					.error2(), .error3(), . looking(), .error_count());
					// The error# looking and error count are all debug signals

endmodule
