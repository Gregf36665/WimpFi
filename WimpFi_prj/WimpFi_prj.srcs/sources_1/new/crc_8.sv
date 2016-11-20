`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 08:30:34 PM
// Design Name: 
// Module Name: crc_8
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


module crc_8(
    input logic clk,
    input logic reset,
    input logic di,
	input logic enb_crc,  
    output logic [1:8] crc
    );

	assign crc0 = crc[8] ^ di;

	always_ff @(posedge clk)
		if (reset)
			crc <= 8'h0;
		else if(enb_crc)
			begin
				crc[8] <= crc[7];
				crc[7] <= crc[6];
				crc[6] <= crc[5] ^ crc0;
				crc[5] <= crc[4] ^ crc0;
				crc[4] <= crc[3];
				crc[3] <= crc[2];
				crc[2] <= crc[1];
				crc[1] <= crc0;
			end
endmodule
