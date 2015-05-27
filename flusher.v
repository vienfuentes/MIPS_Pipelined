`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:45:05 05/05/2015 
// Design Name: 
// Module Name:    hazard 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module flusher(
	input [2:0] branch_jump,
	output reg flush
    );
	
	always@(branch_jump) begin
		case(branch_jump)
			3'd0: flush = 0;
			3'd1: flush = 1;
			3'd2: flush = 1;
			3'd3: flush = 1;
			3'd4: flush = 0;
			3'd5: flush = 0;
			3'd6: flush = 0;
			3'd7: flush = 0;
		endcase
	end

endmodule
