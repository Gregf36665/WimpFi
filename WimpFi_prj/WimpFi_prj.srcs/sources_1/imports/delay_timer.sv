`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2016 09:41:28 AM
// Design Name: 
// Module Name: delay_timer
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


module delay_timer #(parameter BAUD_RATE = 9600)(
		input logic clk, delay_timer_rst,
		output logic half_timer, full_timer
    );
    
    clkenb #(.DIVFREQ(BAUD_RATE*2)) U_HALF (.clk, .enb(half_timer), .reset(delay_timer_rst), .baud());
    clkenb #(.DIVFREQ(BAUD_RATE)) 	U_FULL (.clk, .enb(full_timer), .reset(delay_timer_rst), .baud());
    
endmodule
