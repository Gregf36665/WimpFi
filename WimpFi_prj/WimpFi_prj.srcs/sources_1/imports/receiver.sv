`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2016 09:05:09 AM
// Design Name: 
// Module Name: receiver
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


module receiver #(parameter BAUD_RATE = 9600)(
		input logic rxd,clk, reset,
		output logic ferr, ready,
		output logic [7:0] data
    );
    
	logic data_internal; // A connection between the FSM data and the temporary data.  It is 1 since that is all being sent
	logic [7:0] data_temp; // Connection between temp_data and the output data register
	logic store_bit; // should the data bit be stored
	logic store_data; // should the data be stored (all 8 bits)
	logic full_timer, half_timer; // a pulse every baud and half baud
	logic [2:0] bit_count; // keep track of what bit we are at
	logic [3:0] ferr_delay_count; // keep track of how many bits we have seen a low signal for
	logic delay_timer_rst; // reset the delay timer
	logic ferr_count_inc; // increment the ferr_count counter by 1
	logic ferr_counter_rst; // reset the ferr_counter

    fsm U_FSM ( .clk, .reset, .rxd_synced(rxd_synced), .start_check(start_check), .full_timer, .half_timer, .bit_count,
    			.ferr_delay_count, .bit_counter_rst, .ferr_counter_rst, .delay_timer_rst, .rdy(ready), 
    			.store_data, .store_bit, .clr_ferr(clr_ferr), .set_ferr(set_ferr), .data(data_internal), .ferr_count_inc);
    			
    counter_parm #(.W(3), .CARRY_VAL(4'd7)) U_BIT_COUNTER  		(.clk, .enb(store_bit), .reset(bit_counter_rst), .q(bit_count), .carry());
    counter_parm #(.W(4), .CARRY_VAL(4'd9)) U_FERR_COUNTER 		(.clk, .enb(ferr_count_inc), .reset(ferr_counter_rst), .q(ferr_delay_count), .carry());
    delay_timer  #(.BAUD_RATE(BAUD_RATE)) 	U_DELAY_TIMER  		(.clk, .delay_timer_rst, .half_timer, .full_timer);
    clkenb #(.DIVFREQ(BAUD_RATE*16)) 		U_START_PULSER 		(.clk, .enb(start_check), .reset, .baud());
    rxd_synchroniser 						U_RXD_SYNCHRONISER 	(.clk, .rxd(rxd), .rxd_synced(rxd_synced));
    f_error									U_F_ERROR			(.clk, .reset, .set_ferr(set_ferr), .clr_ferr(clr_ferr), .ferr(ferr));
    
	temp_data U_TEMP_DATA( .clk, .data(data_internal), .store_bit,
						.bit_count,
						.data_out(data_temp)
						);

	data U_DATA (.clk, .reset, .data_in(data_temp), .data_out(data), .store_data);
endmodule
