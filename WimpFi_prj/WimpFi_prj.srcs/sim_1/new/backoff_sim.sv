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
		
		// minimum time allowed
		#1_720_000;
		check("Verify cts low", cts, 1'b0);

		fork : cts_timeout
			@(posedge cts) disable cts_timeout;
			#8_680_000 disable cts_timeout; // maximum time allowed
			// 10_400_000us - 1_720us = 8_680_000us
		join
		rts = 0;
		check("Verify cts received", cts, 1'b1);
		check_group_end;
	endtask

	// False silence
	task glitchy_traffic;
		check_group_begin("Glitchy traffic");
		cardet = 1;
		rts = 1;
		#1_000;
		cardet = 0;
		check("CTS not asserted", cts, 1'b0);
		#1_709_000 cardet = 1; // wait 10us less than DIFS
		cardet = 0;
		#1_720_000; // Should be clear now
		// Deal with contention
		fork : cts_timeout
			@(posedge cts) disable cts_timeout;
			#8_680_000 disable cts_timeout;
		join
		rts = 0;
		check("Verify cts received", cts, 1'b1);
		check_group_end;
	endtask


	task repeat_traffic;
		check_group_begin("Pulsing cardet");
		rts = 1;
		cardet = 1;
		fork : pulse_cardet
			repeat(100)
				begin
					#1_140_000 cardet = 0;
					#200_000 cardet = 1;
				end
			@(posedge cts) disable pulse_cardet;
		join
		check("Verify cts low", cts, 1'b0);
		#100 cardet = 0;
		fork : cts_timeout
			#10_400_000 disable cts_timeout;
			@(posedge cts) disable cts_timeout;
		join
		check("Verify cts high", cts, 1'b0);
		check_group_end;
	endtask



	initial
	begin
		#100
		reset = 0;
		#100;
		//no_traffic;
		#100;
		//one_traffic;
		repeat_traffic;
		#1_000_000;
		//glitchy_traffic;
		#100;
		check_summary_stop;
	end

endmodule
