`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2016 10:08:27 AM
// Design Name: 
// Module Name: rxd_synchroniser
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


module rxd_synchroniser(
		input logic clk, rxd,
		output logic rxd_synced		
    );
    
    always_ff @(posedge clk)
    	rxd_synced <= rxd;
    	
endmodule
