`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 08:14:22 PM
// Design Name: 
// Module Name: FSM_FCS_test
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


module FSM_FCS_test(
    );

	logic clk = 0;
	logic reset = 1;
	logic xwr = 0;
	logic [7:0] din = 8'h55;
	logic dout, enb_crc;


	FSM_FCS DUV (.*);

	always
		#5 clk = ~clk;

	initial
	begin
		#100 reset = 0;
		#100 xwr = 1;
		@(posedge clk) xwr = 0;
		#400 $stop;
	end
endmodule
