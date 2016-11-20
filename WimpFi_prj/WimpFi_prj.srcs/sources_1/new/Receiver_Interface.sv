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


module Receiver_Interface #(parameter BIT_RATE = 50_000) (
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


	// Create appropriate connections 
	logic write_enb, error, empty, data_available, force_write;
	logic [7:0] data_rx;

	// Create the modules to attach together
	mx_rcvr #(.BIT_RATE(BIT_RATE)) U_RX_MX (.clk, .reset, .rxd, .cardet, .data(data_rx), .write(write_rx), .error,
					.error1(), .error2(), .error3(), .looking(), .error_count());

	FSM_Address_check U_FSM_ADDR (.clk, .reset, .write(write_rx), .error,
									.cardet, .address(mac), .data(data_rx),
									.write_enb, .clear_fifo, .empty, .data_available, .force_write);
	
	// Active low reset
	p_fifo #(.DEPTH(256)) U_FIFO (.clk, .rst(~reset), .clr(clear_fifo), .din(data_rx), 
								.we, .re(rrd), .full(), .empty, .dout(rdata));


	// Add in HW to check packet type
	logic [7:0] byte_count;
	logic [2:0] frame_type;
	counter_parm #(.W(8)) U_FRAME_TYPE_COUNTER (.clk, .reset(reset | empty), .enb(write_rx),
																	.q(byte_count));

	FSM_Frame_type U_FSM_FRAME_ID (.clk, .reset, .byte_count(byte_count+1), .xsnd(empty), .din(data_rx), .frame_type);




	// Assign wires to the top level
	assign we = (write_rx & write_enb) | force_write; // Make sure the address matches first 
	//or the FSM wants to write something out
	assign rrdy = data_available;
	assign rerrcnt = 0; // This can only be triggered by the FCS

endmodule
