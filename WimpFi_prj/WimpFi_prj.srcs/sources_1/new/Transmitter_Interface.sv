`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2016 02:57:49 PM
// Design Name: 
// Module Name: Transmitter_Interface
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


module Transmitter_Interface(
    input logic clk,
    input logic reset,
    input logic txen,
    input logic txd,
    input logic xsnd,
    input logic xwr,
    input logic [7:0] xdata,
    output logic cardet,
    output logic xrdy,
    output logic [7:0] xerrcnt
    );

	manchester_tx #(.BIT_RATE(50_000)) U_TX_MX ();
endmodule
