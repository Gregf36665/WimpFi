`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FIFO 4 entries deep                                        ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/sasc/      ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: sasc_fifo4.v,v 1.1.1.1 2002/09/16 16:16:41 rudi Exp $
//
//  $Date: 2002/09/16 16:16:41 $
//  $Revision: 1.1.1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: sasc_fifo4.v,v $
//               Revision 1.1.1.1  2002/09/16 16:16:41  rudi
//               Initial Checkin
//				 Modified by Greg
//				 Ported to SV
//				 Made it dimwit resistant (nothing can be idiot proof)
//				 Parameterized the FIFO depth
//


// parameterized entry deep fast fifo
// This fifo reset is active low
module p_fifo #(parameter DEPTH=4)
			(input logic clk, rst, clr, 
			 input logic [7:0] din,
			 input logic we, re, 
			 output logic full, empty,
			 output logic [7:0] dout);

	localparam POINTER_WIDTH = $clog2(DEPTH) - 1; // get the required width of the pointers

	logic [POINTER_WIDTH:0] wp, rp, wp_p1, rp_p1; // set up the read and write pointers

	logic [7:0] mem [0:DEPTH-1]; // the memory for the FIFO

	logic gb; // the guard bit, detect if full or empty

	// reset conditions and pointer incrementing
	always_ff @(posedge clk or negedge rst)
		if(!rst)
		begin
			wp <= #1 0;
			rp <= #1 0;
		end
		else if(clr)		
			begin
				wp <= #1 0;
				rp <= #1 0;
			end
		else
			begin
				if(we && !full)
					wp <= #1 wp_p1;
				if(re && !empty)
					rp <= #1 rp_p1;
			end

	assign wp_p1 = wp + 1;

	assign rp_p1 = rp + 1;

	// Fifo Output
	assign  dout = mem[ rp ];

	// Fifo Input 
	always @(posedge clk)
			if(full | clr | ~rst); // do nothing (active low reset)
			else if(we)     mem[ wp ] <= #1 din;

	// Status
	assign empty = (wp == rp) & !gb;
	assign full  = (wp == rp) &  gb;

	// Guard Bit ...
	always @(posedge clk)
		if(!rst)			gb <= #1 1'b0;
		else
		if(clr)				gb <= #1 1'b0;
		else
		if((wp_p1 == rp) & we)		gb <= #1 1'b1;
		else
		if(re)				gb <= #1 1'b0;

endmodule


