`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
// Title         : manchester_tx - MANCHESTER TRANSMITTER
// Project       : ECE 491 - Senior Design I
//-----------------------------------------------------------------------------
// File          : manchester_tx.sv
// Author        : Raji Birru & Greg Flynn
// Created       : 09.13.2016
// Last modified : 09.13.2016
//-----------------------------------------------------------------------------
// Description : This module is for a parametrised Manchester Transmitter.
// 
//
//-----------------------------------------------------------------------------
// Modification history :
// 09.05.2016 : created
//-----------------------------------------------------------------------------

module manchester_tx #(parameter EOF_WIDTH = 2, parameter BAUD_RATE = 50_000)(
    input logic clk,
    input logic send,
    input logic reset,
    input logic [7:0] data,    
    output logic rdy,
    output logic txen,
    output logic txd
    );
    
    logic idle,baud;
    transmitter_for_mx #(.BAUD_RATE(BAUD_RATE), .EOF_WIDTH(EOF_WIDTH)) U_TX (.clk, .send, .reset,.data,.idle,.rdy, .txen,.baud,.txd(txd_nrz));
    assign txd_man = (baud ^ txd_nrz);
    assign txd = txd_man | idle;
    
endmodule
