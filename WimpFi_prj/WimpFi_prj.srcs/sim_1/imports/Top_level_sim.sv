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
	logic [7:0] SW = 8'h55; // MAC address
	logic BTNC = 1;
	logic BTND = 0;


	// Outputs
	logic [6:0] SEGS;
	logic [7:0] AN;
	logic DP;
	logic OUT_JB1, OUT_JB2, OUT_JB3, OUT_JB4, OUT_JB5, OUT_JB6;

	// PMOD logic
	logic IN_JA1;
	logic OUT_JA2, OUT_JA3, OUT_JA4;

	// UART
	logic UART_RXD_OUT, UART_TXD_IN;

	// Status LEDs
	logic LED16_R, LED16_G, LED17_R, LED17_G;

	// Connect the module
	nexys4DDR DUV(.*);

	// COnnect the UART tx
	logic send = 0;
	logic [7:0] data = 8'h0;
	logic rdy;
	transmitter DUV_TX_UART (.clk(CLK100MHZ), .send, .data, .rdy, .txd(UART_TXD_IN));

	// Connect the MX rx
	logic write, error;
	logic [7:0] mx_data;

	mx_rcvr DUV_RX_MX (.clk(CLK100MHZ), .reset(BTNC), .rxd(OUT_JA2), .cardet(), .data(mx_data_rx),
					.write, .error, .error1(), .error2(), .error3(), .looking(), .error_count());

	logic send_mx, mx_tx_rdy;
	logic [7:0] mx_data_tx = 8'h0;
	manchester_tx DUV_TX_MX (.clk(CLK100MHZ), .reset(BTNC), .send(send_mx), .data(mx_data_tx), 
							.rdy(mx_tx_rdy), .txen(), .txd(IN_JA1));
	// Start the clock
	always
		#5 CLK100MHZ = ~ CLK100MHZ;


	task send_byte_UART(logic [7:0] byte_to_send);
		if(!rdy)
			@(posedge rdy);
		// Wait for the tx to be ready
		data = byte_to_send;
		send = 1;
		@(negedge rdy)
			send = 0;
		@(posedge rdy); // Wait till the tx is done
	endtask

	task send_byte_MX(logic [7:0] byte_to_send);
		if(!mx_tx_rdy)
			@(posedge mx_tx_rdy);
		// Wait for the tx to be ready
		mx_data_tx = byte_to_send;
		send_mx = 1;
		@(negedge mx_tx_rdy)
			send_mx = 0;
		@(posedge mx_tx_rdy); // Wait till the tx is done
	endtask

	task send_type_0;
		send_byte_UART(8'h2a);
		send_byte_UART(8'h55);
		send_byte_UART(8'h30);
		send_byte_UART(8'h04);
	endtask

	task send_type_1;
		send_byte_UART(8'h2a);
		send_byte_UART(8'h55);
		send_byte_UART(8'h31);
		send_byte_UART(8'h04);
	endtask

	task send_type_2;
		send_byte_UART(8'h2a);
		send_byte_UART(8'h55);
		send_byte_UART(8'h32);
		send_byte_UART(8'h04);
	endtask

	task get_type_2;
		// Preamble
		send_byte_MX(8'h55);
		send_byte_MX(8'h55);
		send_byte_MX(8'hD0);
		send_byte_MX(8'h55); // To U
		send_byte_MX(8'h24); // From $
		send_byte_MX(8'h32); // Type 2
		send_byte_MX(8'hB6); // CRC
	endtask
		
	task get_type_2_all_call;
		// Preamble
		send_byte_MX(8'h55);
		send_byte_MX(8'h55);
		send_byte_MX(8'hD0);
		send_byte_MX(8'h2a); // All call
		send_byte_MX(8'h24); // From $
		send_byte_MX(8'h32); // Type 2
		send_byte_MX(8'h06); // CRC
	endtask

	initial
		begin
			#100 BTNC = 0;
			get_type_2_all_call;
			#5_000_000;
			get_type_2;
			#5_000_000;
			//send_type_0;
			//#1_500_000;
			//send_type_1;
			//#1_500_000;
			//send_type_2;
			//#1_500_000;

			$finish;
		end

endmodule
