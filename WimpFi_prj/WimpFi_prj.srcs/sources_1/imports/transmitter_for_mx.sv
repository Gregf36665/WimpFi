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

module transmitter_for_mx #(parameter EOF_WIDTH = 2, parameter BAUD_RATE = 9600)(
    input logic clk,
    input logic send,
    input logic reset,
    input logic [7:0] data,
    output logic idle,    
    output logic rdy,
    output logic txen,
    output logic baud,    
    output logic txd
    );   
       
    logic counter_rst, mux_out, carry, lden, clk_reset, eof_carry, eof_reset, sending;
    logic [7:0] saved_data;
    logic [2:0] count; // this counts start, 8-bit and stop, 10 bits total
    logic [$clog2(EOF_WIDTH+1)-1:0] eof_count;
    
    typedef enum logic [3:0] {
        IDLE    = 4'b0000,
        STAND_BY_START   = 4'b0001,
        SEND_0_LOAD    = 4'b1011,
        SEND_0    = 4'b0010,
        SEND_1    = 4'b0011,
        SEND_2    = 4'b0100,
        SEND_3    = 4'b0101,
        SEND_4    = 4'b0110,
        SEND_5    = 4'b0111,
        SEND_6    = 4'b1000,
        SEND_7    = 4'b1001,
        EOF       = 4'b1010
    } states;
    
    states state, next;
    
    always_ff @(posedge clk)
        begin
            if(reset) state <= IDLE;
            else state <= next;
        end 
    
   
    always_comb
        begin
        // Default values
        lden = 1'b0;
        sending = 1'b0;
        txd = 1'b1;
        counter_rst = 1'b1; // reset the counter 
        clk_reset = 1'b1;
        eof_reset = 1'b1;
        idle = 1'b1; 
            case(state)
                IDLE:
                    begin
                        if(send) next = STAND_BY_START;
                        else next = IDLE;
                        
                        lden = 1'b0;
                        rdy = 1'b1;
                        sending = 1'b0;
                        txd = 1'b1;
                        counter_rst = 1'b1; // reset the counter 
                        clk_reset = 1'b1;
                        eof_reset = 1'b1;
                        idle = 1'b1;                      
                    end
                STAND_BY_START:
                // This waits for the baud rate clock to increment
                    begin
                        if(enb) next = SEND_0;
                        else next = STAND_BY_START;
                        
                        lden = 1'b1;
                        rdy = 1'b0;
                        txd = 1'b1; 
                        clk_reset = 1'b0;
                        eof_reset = 1'b1;
                        counter_rst = 1'b1; // make sure the counter is at 0
                        idle = 1'b1;
                    end
                SEND_0_LOAD:
                    begin
                    next = SEND_0;                    
                    lden = 1'b1;
                    rdy = 1'b0;
                    sending = 1'b1;
                    txd = data[0];  // this sends data[0] rather than saved 0
                    // This is because the saved data is being updated.
                    clk_reset = 1'b0;
                    eof_reset = 1'b1;
                    idle = 1'b0;
                    end
                SEND_0:
                    begin
                    if (enb) next = SEND_1;
                    else next = SEND_0;                    
                    lden = 1'b0;
                    rdy = 1'b0;
                    sending = 1'b1;
                    txd = saved_data[0];  // this sends the saved data
                    clk_reset = 1'b0;
                    eof_reset = 1'b1;
                    idle = 1'b0;
                    end
                SEND_1:
                    begin
                    if (enb) next = SEND_2;
                    else next = SEND_1;                    
                    lden = 1'b0;
                    rdy = 1'b0;
                    sending = 1'b1;
                    txd = saved_data[1]; 
                    clk_reset = 1'b0;
                    eof_reset = 1'b1;
                    idle = 1'b0;
                    end
                SEND_2:
                    begin
                    if (enb) next = SEND_3;
                    else next = SEND_2;                    
                    lden = 1'b0;
                    rdy = 1'b0;
                    sending = 1'b1;
                    txd = saved_data[2]; 
                    clk_reset = 1'b0;
                    eof_reset = 1'b1;
                    idle = 1'b0;
                    end
                SEND_3:
                    begin
                    if (enb) next = SEND_4;
                    else next = SEND_3;                    
                    lden = 1'b0;
                    rdy = 1'b0;
                    sending = 1'b1;
                    txd = saved_data[3]; 
                    clk_reset = 1'b0;
                    eof_reset = 1'b1;
                    idle = 1'b0;
                    end
                SEND_4:
                    begin
                    if (enb) next = SEND_5;
                    else next = SEND_4;                    
                    lden = 1'b0;
                    rdy = 1'b0;
                    sending = 1'b1;
                    txd = saved_data[4]; 
                    clk_reset = 1'b0;
                    eof_reset = 1'b1;
                    idle = 1'b0;
                    end
                SEND_5:
                    begin
                    if (enb) next = SEND_6;
                    else next = SEND_5;                    
                    lden = 1'b0;
                    rdy = 1'b0;
                    sending = 1'b1;
                    txd = saved_data[5]; 
                    clk_reset = 1'b0;
                    eof_reset = 1'b1;
                    idle = 1'b0;
                    end
                SEND_6:
                    begin
                    if (enb) next = SEND_7;
                    else next = SEND_6;                    
                    lden = 1'b0;
                    rdy = 1'b0;
                    sending = 1'b1;
                    txd = saved_data[6]; 
                    clk_reset = 1'b0;
                    eof_reset = 1'b1;
                    idle = 1'b0;
                    end
                SEND_7:
                    begin
                    if (enb) next = send ? SEND_0_LOAD : EOF;
                    else next = SEND_7;                    
                    lden = 1'b0;
                    rdy = 1'b1;
                    sending = 1'b1;
                    txd = saved_data[7]; 
                    clk_reset = 1'b0;
                    eof_reset = 1'b1;
                    idle = 1'b0;
                    end
                EOF:
                    begin
                        if(eof_count == EOF_WIDTH) next = IDLE;
                        else next = EOF;
                        lden = 1'b0;
                        rdy = 1'b1;
                        sending = 1'b1;
                        txd = 1'b1;
                        counter_rst = 1'b1; // reset the counter
                        eof_reset = 1'b0;
                        clk_reset = 1'b0;
                        idle = 1'b1;
                    end 
                default:
                    begin
                       next = IDLE;
                       lden = 1'b0;
                       rdy = 1'b1;
                       txd = 1'b1;
                       sending = 1'b0;
                       counter_rst = 1'b1; // reset the counter 
                       eof_reset = 1'b1; 
                       clk_reset = 1'b1;
                       idle = 1'b1;
                   end
            endcase
        end
        
        clkenb #(.DIVFREQ(BAUD_RATE)) U_CLKENB (.clk(clk), .enb(enb), .reset(clk_reset));
        reg_parm #(.W(8))      U_SNAPSHOT (.clk, .reset(1'b0), .lden, .d(data), .q(saved_data));
        
  
        mux8_parm #(.W(1))     U_SENDER   (.d0(saved_data[0]), .d1(saved_data[1]), .d2(saved_data[2]), 
                                           .d3(saved_data[3]), .d4(saved_data[4]), .d5(saved_data[5]), 
                                           .d6(saved_data[6]), .d7(saved_data[7]), .sel(count), .y(mux_out));
                                            
        counter_parm #(.W(3), .CARRY_VAL(4'd7))  U_COUNTER  (.clk, .enb(enb), .reset(counter_rst), .q(count), .carry(carry));
        counter_parm #(.W($clog2(EOF_WIDTH+1)), .CARRY_VAL(EOF_WIDTH))  
                U_EOF_WIDTH_COUNT (.clk, .enb(enb), .reset(eof_reset), .q(eof_count), .carry(eof_carry));
        
        clkenb_baud #(.DIVFREQ(BAUD_RATE * 2)) U_BAUD_GEN (.clk(clk), .baud(baud), .reset(clk_reset), .enb());
        
        assign txen = sending && (eof_count != EOF_WIDTH);
            
endmodule
