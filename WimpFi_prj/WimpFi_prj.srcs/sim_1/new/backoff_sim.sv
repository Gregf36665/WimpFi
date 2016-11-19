`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2016 11:48:46 AM
// Design Name: 
// Module Name: backoff_sim
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


import check_p::*;

module backoff_sim();

	logic clk = 0;
	logic reset = 1;
	logic cardet = 0;
	logic rts = 0;
	logic cts;

	// Add DUV
	Backoff_module DUV (.*);
	always
		#5 clk = ~clk;

	
	task no_traffic;
		check_group_begin("No traffic");
		rts = 1;
		fork : cts_timeout
			@(posedge cts) disable cts_timeout;
			#1000 disable cts_timeout;
		join
		rts = 0;
		check("Verify cts received", cts, 1'b1);
		check_group_end;
	endtask

	task one_traffic;
		check_group_begin("cardet for first try");
		cardet = 1;
		rts = 1;
		#10;
		check("Verify cts low", cts, 1'b0);
		#10 cardet = 0;

		fork : cts_timeout
			@(posedge cts) disable cts_timeout;
			#1000 disable cts_timeout;
		join
		rts = 0;
		check("Verify cts received", cts, 1'b1);
	endtask

	initial
	begin
		#100
		reset = 0;
		#100;
		no_traffic;
		#100;
		one_traffic;
		check_summary_stop;
	end

endmodule
