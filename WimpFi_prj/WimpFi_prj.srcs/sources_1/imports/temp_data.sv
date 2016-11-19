`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2016 10:23:18 AM
// Design Name: 
// Module Name: temp_data
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


module temp_data(
		input logic clk, data, store_bit, 
		input logic [2:0] bit_count,
		output logic [7:0] data_out
    );
    
    logic [7:0] lden;
    
    reg_parm #(.W(1))  U_BIT_EIGHT (.clk, .reset(1'b0), .lden(lden[7]), .d(data), .q(data_out[7]));
    reg_parm #(.W(1))  U_BIT_SEVEN (.clk, .reset(1'b0), .lden(lden[6]), .d(data), .q(data_out[6]));
    reg_parm #(.W(1))  U_BIT_SIX   (.clk, .reset(1'b0), .lden(lden[5]), .d(data), .q(data_out[5]));
    reg_parm #(.W(1))  U_BIT_FIVE  (.clk, .reset(1'b0), .lden(lden[4]), .d(data), .q(data_out[4]));
    reg_parm #(.W(1))  U_BIT_FOUR  (.clk, .reset(1'b0), .lden(lden[3]), .d(data), .q(data_out[3]));
    reg_parm #(.W(1))  U_BIT_THREE (.clk, .reset(1'b0), .lden(lden[2]), .d(data), .q(data_out[2]));
    reg_parm #(.W(1))  U_BIT_TWO   (.clk, .reset(1'b0), .lden(lden[1]), .d(data), .q(data_out[1]));
    reg_parm #(.W(1))  U_BIT_ONE   (.clk, .reset(1'b0), .lden(lden[0]), .d(data), .q(data_out[0]));
    
    assign lden = store_bit << bit_count;
    
endmodule
