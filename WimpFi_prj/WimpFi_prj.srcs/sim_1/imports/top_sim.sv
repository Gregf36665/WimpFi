`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Greg
// 
// Create Date: 10/29/2016 02:38:40 PM
// Design Name: 
// Module Name: top_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Test mx_test to tx to rx to 7 seg display
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_sim();


	// Set the inputs all to 0
	logic CLK100MHZ = 0;
	logic BTNC = 0;
	logic BTND = 0;
	logic [15:0] SW = '0;

	// Outputs
	logic [6:0] SEGS;
	logic [1:0] LED;
	logic [7:0] AN;
	logic DP;
	logic [2:0] JA;
	logic UART_RXD_OUT;
	logic LED16_R, LED16_G, LED17_R, LED17_G;


	// Module 
	nexys4DDR DUV (.*); // Connect everything

	// Fire up the clock
	always
		#5 CLK100MHZ = ~ CLK100MHZ;

	task send_preamble;
		BTND = 1;
		repeat(10e2) @(posedge CLK100MHZ); // wait a little
		BTND = 0;
		repeat(10e5) @(posedge CLK100MHZ); // wait a little
	endtask

	task send_data_cont;
		SW[6] = 1;
		repeat(10e6) @(posedge CLK100MHZ); // wait a little
	endtask


	initial
	begin
		BTNC = 1; // Reset systems
		SW[6:0] = 7'h04;// send one byte of data don't enable;
		#100;
		BTNC = 0; // Reset systems
		repeat(10e4) @(posedge CLK100MHZ); // wait a little
		send_preamble;
		repeat(10e4) @(posedge CLK100MHZ); // wait a little
		send_data_cont;
		$finish;
	end

endmodule
