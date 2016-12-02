`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2016 12:15:11 PM
// Design Name: 
// Module Name: peak_detector
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


module peak_detector #(parameter W=7)(
    input logic clk,
    input logic reset,
    input logic enb,
    input logic [W-1:0] data,
	output logic peak
    );

	logic [W-1:0] last_data;

	always_ff @(posedge clk)
		if(reset) 
		begin
			peak <= 1'b0;
			last_data <= 0;
		end
		else if(enb) begin
			last_data <= data;
			peak <= data < last_data;
		end
		


endmodule
