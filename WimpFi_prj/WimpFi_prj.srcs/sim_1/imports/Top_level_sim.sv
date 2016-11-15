`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2016 10:40:39 AM
// Design Name: 
// Module Name: Top_level_sim
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


module Top_level_sim();

	// inputs
	logic CLK100MHZ = 0;
	logic [15:0] SW = 4;
	logic BTNC = 1;
	logic BTND = 0;


	// Outputs
	logic [6:0] SEGS;
	logic [7:0] AN;
	logic DP;
	logic OUT_JB1, OUT_JB2, OUT_JB3, OUT_JB4;

	// PMOD logic
	logic IN_JA1 = 0;
	logic OUT_JA2, OUT_JA3, OUT_JA4;

	// UART
	logic UART_RXD_OUT;

	// Status LEDs
	logic LED16_R, LED16_G, LED17_R, LED17_G;

	// Connect the module
	nexys4DDR DUV(.*);

	// Start the clock
	always
		#5 CLK100MHZ = ~ CLK100MHZ;

	task send_data;
			#1000;
			BTNC = 0; // Exit reset
			#10_000;
			BTND = 1;
			#100 BTND = 0;
			@(posedge OUT_JA3) #5000;
	endtask

	
	// Send a manchester bit
	localparam JITTER_AMOUNT = 100; // clock cycles/ baud
	localparam NOISE = 5;
	task send_bit(input logic data_bit);
		repeat($urandom_range(1000-JITTER_AMOUNT,1000+JITTER_AMOUNT)) @(posedge CLK100MHZ) // 1000 clock cycles @10ns = 100kBaud
			IN_JA1 = data_bit ^ ($urandom_range(100,1) < NOISE);  // add in some noise
		repeat($urandom_range(1000-JITTER_AMOUNT,1000+JITTER_AMOUNT)) @(posedge CLK100MHZ) // 1000 clock cycles @10ns = 100kBaud
			IN_JA1 = ~(data_bit ^ ($urandom_range(100,1) < NOISE));  // add in some noise
	endtask

	// Send a byte of data
	// This sends LSB first
	task send_byte(input logic [7:0] data_byte);
		int i;
		for (i=0;i<8;i++)
			send_bit(data_byte[i]);
	endtask

	task receive_data;
		BTNC = 1; // Enter reset
		#1000;
		BTNC = 0; // Exit reset
		#1000;
		repeat(2) send_byte(8'h55); // Send preamble
		send_byte(8'hD0); // send SFD
		repeat(20) send_byte(8'h55); // send data
		IN_JA1 = 1; // Idle the data line
	endtask

	initial
		begin
			//send_data;
			#1000;
			receive_data;
			#18_500_000;
			$finish;
		end

endmodule
