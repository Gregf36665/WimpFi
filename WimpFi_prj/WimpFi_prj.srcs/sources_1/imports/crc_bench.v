`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:       Lafayette College
// Engineer:      John Nestor
//
// Create Date:   18:26:53 12/01/2008
// Design Name:   crc
// Module Name:   crc_bench.v
// Project Name:  crc_demo
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: crc
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// This testbench exercises the reference CRC circuit provided in class.
// Currently it applies two bytes to the CRC, and then applies the CRC itself
// starting with x[8] and ending with x[1].  The result of this two-byte message
// and CRC must be zero.  Note that in this design, x[8] is the LEFTMOST bit
// of the CRC, while x[1] is the RIGHTMOST bit.  This is the reverse of the
// order in which we whould usually like to transmit the CRC.  Module crc_r.v
// has the bit ordering of x reversed, which may be preferable for use in 
// your design.
//
////////////////////////////////////////////////////////////////////////////////

module crc_bench_v;

	// Inputs
	reg clk;
	reg rst;
	reg d;


	// Outputs
	wire [8:1] x;
	reg [8:1] crc; // for saving the value

	// Instantiate the Unit Under Test (UUT)
	crc uut (
		.clk(clk), 
		.rst(rst), 
		.d(d), 
		.x(x)
	);

  // apply data bit di to the CRC input for one clock cycle
  task set_bit;
    input di;
  
    begin
      d = di;
	   @(posedge clk) #1;
    end
  endtask
  
  // apply the 8 data bits in bi to the CRC input over eight
  // clock cycles, starting with bi[0]
  task set_byte;
    input [7:0] bi;
	 
	 integer i;
	 
	 begin
	   for (i = 0; i <= 7; i = i+1)
		  set_bit(bi[i]);
	 end
  endtask

   // clock oscillator
   always begin
	  clk = 0; #5;
	  clk = 1; #5;
	end

   // apply two characters; then apply bits x[8] down to x[1]
	initial begin
		// Initialize Inputs
		rst = 1;
		d = 0;
		@(posedge clk) #1;
		rst = 0;
		set_byte("a");
		set_byte("b");
		crc = x;
		$display("Sending CRC Code: %x", x);
		// apply the CRC.  Sinc3e x[8] is the
		// leftmost bit, can't use set_byte here
		set_bit(crc[8]);
		set_bit(crc[7]);
		set_bit(crc[6]);
		set_bit(crc[5]);
		set_bit(crc[4]);
		set_bit(crc[3]);
		set_bit(crc[2]);
		set_bit(crc[1]);
		if (x==0) $display("CRC recevived correctly: %x", x);
		else $display("CRC recevived incorrectly: %x", x);
		d = 0;
      @(posedge clk) #1;
		$stop;			
	end
      
endmodule

