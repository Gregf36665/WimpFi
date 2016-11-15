`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
// Title         : transmitter - ASYNCHRONOUS TRANSMITTER
// Project       : ECE 491 - Senior Design I
//-----------------------------------------------------------------------------
// File          : transmitter.sv
// Author        : Raji Birru & Greg Flynn
// Created       : 09.05.2016
// Last modified : 09.11.2016
//-----------------------------------------------------------------------------
// Description : This module is for an asynchronus parametrized 8-bit 
// transmitter with a single start bit and a single stop bit with no parity.
// 
//
//-----------------------------------------------------------------------------
// Modification history :
// 09.05.2016 : created
//-----------------------------------------------------------------------------

module transmitter(
    input logic clk,
    input logic send,
    input logic [7:0] data,    
    output logic rdy,    
    output logic txd
    );
    
    parameter BAUD_RATE = 9600;
       
    logic counter_rst, mux_out, carry, lden, clk_reset;
    logic [7:0] saved_data;
    logic [3:0] count; // this counts start, 8-bit and stop, 10 bits total
    
    typedef enum logic [2:0] {
        IDLE    = 3'b000,
        START   = 3'b001,
        SEND    = 3'b010,
        STOP    = 3'b011,
        STAND_BY_START = 3'b100,
        STAND_BY_STOP = 3'b101 ,
		SAVE_DATA = 3'b110
    } states;
    
    states state, next;
    
    always_ff @(posedge clk)
        begin
            state <= next;
        end 
    
   
    always_comb
        begin
            unique case(state)
			// Declare defaults outside of the case in the future
                IDLE:
                    begin
                        if(send) next = SAVE_DATA;
                        else next = IDLE;
                        
                        lden = 1'b0;
                        rdy = 1'b1;
                        txd = 1'b1;
                        counter_rst = 1'b1; // reset the counter 
                        clk_reset = 1'b1;                        
                    end
				SAVE_DATA:
					begin	
						next = STAND_BY_START;
                        lden = 1'b1;
                        txd = 1'b1; 
						rdy = 1'b1;
                        clk_reset = 1'b0;
                        counter_rst = 1'b1; // make sure the counter is at 0
					end
                STAND_BY_START:
                // This waits for the baud rate clock to increment
                    begin
                        if(enb) next = START;
                        else next = STAND_BY_START;
                        
                        lden = 1'b0;
                        txd = 1'b1; 
						rdy = 1'b0;
                        clk_reset = 1'b0;
                        counter_rst = 1'b1; // make sure the counter is at 0
                    end
                
                START:
                    begin
                        // This makes sure that the state changes at the baud rate
                        if (enb) 
						begin
                            next = SEND;
                            counter_rst = 1'b1;
                        end
                        else
                            next = START;
                        lden = 1'b0;
                        txd = 1'b0;
                        rdy = 1'b0;
                        clk_reset = 1'b0;
                        counter_rst = 1'b0;
                    end
                SEND:
                    begin    
                        if(carry == 1'b1) next = STAND_BY_STOP;
                        else next = SEND;
                        
                        rdy = 1'b0;
                        clk_reset = 1'b0;
                        lden = 1'b0;
                        counter_rst = 1'b0;
                        txd = mux_out;
                    end
                STAND_BY_STOP:
                // This lets the stop bit stay in position for the entire baud cycle
                // I think this is acutally the last transmitted bit not the stop bit
                    begin
                        if(enb) next = STOP;
                        else next = STAND_BY_STOP;
                    
                    rdy = 1'b0;
                    clk_reset = 1'b0;
                    lden = 1'b0;
                    counter_rst = 1'b0;
                    txd = mux_out;
                    end                   
                STOP:
                    begin
                        if(send) next = STAND_BY_START;
                        else next = IDLE;
                        
                        lden = 1'b0;
                        rdy = 1'b0;
                        txd = 1'b1;     
                        counter_rst = 1'b0;
                        clk_reset = 1'b0;                 
                    end
                default:
                    begin
                       next = IDLE;
                       lden = 1'b0;
                       rdy = 1'b1;
                       txd = 1'b1;
                       counter_rst = 1'b1; // reset the counter 
                       clk_reset = 1'b1;
                   end
            endcase
        end
        
        clkenb #(.DIVFREQ(BAUD_RATE)) U_CLKENB (.clk(clk), .enb(enb), .reset(clk_reset));
        reg_parm #(.W(8))      U_SNAPSHOT (.clk, .reset(1'b0), .lden, .d(data), .q(saved_data));
        
        
        logic [2:0] sel;
        assign sel = count - 1; // This excludes the count for the start sequence
        
        mux8_parm #(.W(1))     U_SENDER   (.d0(saved_data[0]), .d1(saved_data[1]), .d2(saved_data[2]), 
                                            .d3(saved_data[3]), .d4(saved_data[4]), .d5(saved_data[5]), 
                                            .d6(saved_data[6]), .d7(saved_data[7]), .sel, .y(mux_out));
                                            
        counter_parm #(.W(4), .CARRY_VAL(4'd8))  U_COUNTER  (.clk, .enb(enb), .reset(counter_rst), .q(count), .carry(carry));
            
endmodule
