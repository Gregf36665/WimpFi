`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2016 08:09:52 AM
// Design Name: 
// Module Name: fsm
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


module fsm(
	input logic clk, reset, rxd_synced, start_check, full_timer, half_timer,
	input logic [2:0] bit_count,
	input logic [3:0] ferr_delay_count,
	output logic bit_counter_rst, ferr_counter_rst, delay_timer_rst, rdy, store_data, store_bit, clr_ferr, set_ferr,
	output logic data, ferr_count_inc
    );
    
    assign data = rxd_synced;
    
    
    typedef enum logic [3:0] {
            IDLE    	= 4'b1000,
            START_MAYBE = 4'b0001,
            CLEAR_FLAG  = 4'b1011,
            UPDATE_DATA = 4'b0010,
            WAIT    	= 4'b0011,
            EOF    		= 4'b0100,
            DATA_GOOD   = 4'b0101,
            DATA_BAD    = 4'b0110,
            STILL_BAD   = 4'b0111,
            LAST_SAVE	= 4'b1100
    } states;
    
    states state, next;
    
    
	always_ff @(posedge clk)
		begin
			if(reset) state <= IDLE;
			else state <= next;
		end 

    
    always_comb
    	begin
    	
    	// So I know this is how FSM are meant to be coded
    	// but it creates aweful waveforms and pulses of 0 width
    	// in simulation.  Fixes? Other than declare in every state
			rdy = 1'b0; // see this one looks really really ugly
			bit_counter_rst = 1'b0;
			ferr_counter_rst = 1'b0;
			delay_timer_rst = 1'b0;
			store_data = 1'b0;
			clr_ferr = 1'b0;
			set_ferr = 1'b0;
			store_bit = 1'b0;
			ferr_count_inc = 1'b0;
			next = IDLE;
    	
    		unique case(state)
    			IDLE:
    				begin
    					if(start_check)
    						begin
    							if(~rxd_synced) next = START_MAYBE;
    							else next = IDLE;
    						end
    					else next = IDLE;
    					rdy = 1'b1;
    					bit_counter_rst  = 1'b1;
    					ferr_counter_rst = 1'b1;
    					delay_timer_rst  = 1'b1;
    				end
    			START_MAYBE:
    				begin
    					if(half_timer)
    						begin
    							if(!rxd_synced) next = CLEAR_FLAG;
    							else next = IDLE;
    							delay_timer_rst = 1; // reset the 1/2 full timer
    						end
    					else next = START_MAYBE;
    					rdy = 1'b1;
    					bit_counter_rst = 1'b1;
    					ferr_counter_rst = 1'b1;
    				end
    			CLEAR_FLAG:
    				begin
    					if(full_timer) next = UPDATE_DATA;
    					else next = CLEAR_FLAG;
    					clr_ferr = 1'b1;
    					bit_counter_rst = 1'b1;
    				end
    			UPDATE_DATA:
    				begin
    					next = WAIT;
    					store_bit = 1'b1;
    			    end
    			WAIT:
    				begin
    					if(full_timer)
    						begin
    							if(bit_count == 7) next = LAST_SAVE;
    							else next = UPDATE_DATA;
    						end
    					else next = WAIT;
    				end
    			LAST_SAVE:
    				begin
    					next = EOF;
    					store_bit = 1'b1;
    				end
    			EOF:
    				begin
    					if(full_timer)
    						begin
    							if(rxd_synced) next = DATA_GOOD;
    							else next = DATA_BAD;
    						end
    					else next = EOF;
    					ferr_counter_rst = 1'b1;
    				end
    			DATA_GOOD:
    				begin
    					next = IDLE;
    					store_data = 1'b1;
    				end
    			DATA_BAD:
    				begin
    					if(full_timer)
    						begin
    							if(rxd_synced)
    								begin
										ferr_count_inc = 1;
    									if(ferr_delay_count == 4'd9) next = IDLE;
    									else next = DATA_BAD;
    								end
    							else next = STILL_BAD;
    						end
    					else next = DATA_BAD;
    					set_ferr = 1'b1;
    				end
    			STILL_BAD:
    				begin
    					next = DATA_BAD;
    					ferr_counter_rst = 1'b1;
    				end
				default:
					next <= IDLE;
    		endcase
    		
    	end

endmodule
