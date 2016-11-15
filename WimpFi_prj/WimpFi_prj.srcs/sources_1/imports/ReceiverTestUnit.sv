`timescale 1ns / 1ps
// Module to interface between wimpFi and manchester rx
// Created by Greg Flynn
// 2016-11-01

module ReceiverTestUnit(
				input logic clk, reset,
				input logic rxdata,
				output logic [6:0] SEGS,
				output logic [7:0] AN,
				output logic DP,
				output logic cardet, error,
				output logic UART_RXD_OUT,
				output logic LED16_R, LED16_G, LED17_R, LED17_G, // signal LEDs
				output logic looking
				);


	// Data outputs for rx, data out of the fifo and the fsm
    logic [7:0] data_out, data_fifo, data_fsm, error_count;

	logic error1, error2, error3; // Error codes
	logic [3:0] error_code;
	assign error_code = {error, error1, error2, error3};
    
	// Modules to connect
	
	// receiver
	mx_rcvr U_RX (.clk, .reset, .rxd(rxdata), .cardet, .data(data_out), .write, .error, 
				.error1, .error2, .error3, .looking, .error_count);

	// Control the seven seg display with data from the rx
	dispctl U_SEG_CTL (.clk, .reset, .d7(error_code), .d6(4'h0), .d5(error_count[7:4]), 
						.d4(error_count[3:0]), .d3(4'h0), .d2(4'h0), .d1(data_out[7:4]), 
						.d0(data_out[3:0]), .dp7(1'b0), .dp6(1'b0), .dp5(1'b0), 
						.dp4(1'b0), .dp3(1'b0), .dp2(1'b0), .dp1(1'b0), .dp0(1'b0), 
						.seg(SEGS), .dp(DP), .an(AN)); 
						
	// Conections between the FIFO and the FSM
	logic empty, read, full;

	// The FIFO is active low reset
	// A FIFO to deal with data from the receiver
	// What is the biggest packet we can deal with?
	// 1kB FIFO
	// If more space is needed on the board make this smaller
	p_fifo #(.DEPTH(1024)) U_FIFO (.clk, .rst(~reset), .clr(1'b0), 
							.din(data_out), .we(write), .re(read),
							.full, .empty, .dout(data_fifo));

	// Connection between FIFO and UART_tx
	logic send_uart, ready; 
	// This FIFO FSM pulls data out of the FIFO
	fifo_fsm U_FIFO_EXTRACTOR (.clk, .reset, .empty, .ready,
								.read, .send(send_uart),
								.data_fifo, .data_fsm);

	// This UART tx sends the messages to the com port

	transmitter U_UART_TX (.clk, .send(send_uart), .data(data_fsm), .rdy(ready), .txd(UART_RXD_OUT));

                     
    
	// Color LEDs to update the user
	// Green = Empty
	// Red = Full
	// FIFO information
	assign LED16_G = empty;
	assign LED16_R = full; 


	// Mx receiver info
	assign LED17_R = error; // Red = error
	assign LED17_G = cardet; // carrier detected

                                            
endmodule // nexys4DDR

