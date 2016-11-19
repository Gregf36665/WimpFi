`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 09:27:54 AM
// Design Name: 
// Module Name: Type0_TX_MX_RX_UART_test
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


module Type0_TX_MX_RX_UART_test();

	// Wires for transmitter side
	logic clk = 0;
	logic reset = 1;
	logic cardet = 0;
	logic txen, txd; // outputs
	logic rts, cts;

	// Wires for UART transmitter
	logic send = 0;
	logic [7:0] data = 8'h55;
	logic rdy; 

	assign UART_TXD_IN = UART_txd; // connect the UART tx to the tx side

	transmitter_side DUV (.*);

	transmitter U_UART_TX (.txd(UART_txd), .*);

	always
		#5 clk = ~clk;

	task send_one_byte;
		send = 1;
		@(negedge rdy) send = 0;
		data = 8'h04; // Send command
		@(posedge rdy) send = 1;
		@(negedge rdy) send = 0;
	endtask

	task traffic;
		cardet = 1;
		#100;
		data = 8'h55; // Data
		send = 1;
		@(negedge rdy) send = 0;
		data = 8'h04; // Send command
		@(posedge rdy) send = 1;
		@(negedge rdy) send = 0;
		fork : ready_timeout
			@(posedge txen) disable ready_timeout;
			#20_000_000 disable ready_timeout;
		join
		cardet = 0;
		@(posedge txen);
		@(negedge txen);
	endtask

	initial 
	begin
		#100;
		reset = 0;
		#100;
		//send_one_byte;
		traffic;

	end
endmodule

