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
module hazard(
	input [1:0] branch_jump,
	output reg flush
    );
	
	always@(branch_jump) begin
		case(branch_jump)
			2'd0: flush = 0;
			2'd1: flush = 1;
			2'd2: flush = 1;
			2'd3: flush = 1;
		endcase
	end

endmodule
