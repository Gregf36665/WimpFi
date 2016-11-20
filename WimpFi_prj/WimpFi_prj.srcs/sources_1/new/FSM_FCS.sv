`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 08:01:01 PM
// Design Name: 
// Module Name: FSM_FCS
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


module FSM_FCS(
    input logic clk,
    input logic reset,
	input logic xwr,
    input logic [7:0] din,
    output logic dout,
    output logic enb_crc
    );
	
	typedef enum logic [2:0] {
		IDLE = 3'h0,
		STORE_DATA = 3'h1,
		CRC_DATA = 3'h2
	} states;

	states state, next;

	logic [7:0] next_data;
	logic store_data;
	logic [2:0] count; 
	assign dout = next_data[7];

	always_ff @(posedge clk)
	if(reset)
		begin
			state <= IDLE;
			count <= 0;
			next_data <= 8'h00;
		end
	else
		begin
			state <= next;
			count <= enb_crc ? count + 1 : 0;
			if(store_data) next_data <= din;
			else if(enb_crc) next_data <= {next_data[6:0], 1'b0};
		end


	always_comb
	begin
		enb_crc = 0;
		store_data = 0;
		next = IDLE;
		case(state)
			IDLE:
				next = xwr ? STORE_DATA : IDLE;
			STORE_DATA:
			begin
				store_data = 1;
				next = CRC_DATA;
			end
			CRC_DATA:
			begin
				enb_crc = 1;
				if (count == 7) next = IDLE;
				else next = CRC_DATA;
			end

		endcase

	end

			
endmodule
