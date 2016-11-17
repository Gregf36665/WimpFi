`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Raji Birru
// 
// Create Date: 10/14/2016 03:34:44 AM
// Design Name: 
// Module Name: correlator_bench_2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for correlator module with noise input option.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module correlator_bench_2();
    
    parameter LEN=16, PATTERN=16'h00FF, HTRESH=13, LTRESH=3,  W=$clog2(LEN)+1;
    
    // inputs
    logic clk;
    logic reset;
    logic enb;
    logic d_in;
    
    // outputs
    logic [W-1:0] csum;
    logic h_out;  
    logic l_out;
    
    correlator DUV (.clk(clk), .reset(reset), .enb(enb), .d_in(d_in), .csum(csum), .h_out(h_out), .l_out(l_out));
    
    task init_signals;
        clk = 0;
        enb = 1;
    endtask
    
    task reset_pulse;
        reset = 1;
        repeat(1) @(posedge clk) #1;
        reset = 0;
        repeat(1) @(posedge clk) #1;
    endtask
    
    task pulse_64;
        d_in = 0;
        repeat(64) @(posedge clk) #1;
        d_in = 1;
        repeat(64) @(posedge clk) #1;
        d_in = 0;
        repeat(64) @(posedge clk) #1;    
    endtask
    
    parameter ERROR_RATE = 20; // % prob. of error
    logic noise_error, d_in_noisy;
    
    always @(posedge clk) begin
        #1; // inject error (if any) after clock edge
        if ($urandom_range(100,1) <= ERROR_RATE) noise_error = 1;
        else noise_error = 0;
    end
    
    assign d_in_noisy = d_in ^ noise_error;
    
    always
        #50 clk = ~clk;
    
    initial begin
        init_signals;
        reset_pulse;
        pulse_64;
        $stop;
    end

endmodule
