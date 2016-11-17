`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2016 12:39:53 PM
// Design Name: 
// Module Name: Receiver_Interface
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


module Receiver_Interface(
    input clk,
    input reset,
    input rrd,
    output rrdy,
    input [7:0] mac,
    output [7:0] rdata,
    output [7:0] rerrcnt,
    output cardet,
    input rxd
    );


	// Create the modules to attach together

	mx_rcvr U_RX_MX (.clk, .reset, .rxd, .cardet, .data(data_rx), .write(write_rx), .error(),
					.error1(), .error2(), .error3(), .looking(), .error_count());

	FSM_Address_check U_FSM_ADDR (.clk, .reset, .write(write_rx), .cardet, .address(mac), .data(data_rx),
									.write_enb, .clear_fifo);
	
	// Active low reset
	p_fifo U_FIFO (.clk, .rst(~reset), .clr(clear_fifo), .din(data_rx), .we, .re(rrd), .full(), .empty, .dout(rdata));

endmodule
