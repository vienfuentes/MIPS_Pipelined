`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:15:15 11/27/2013 
// Design Name: 
// Module Name:    mux5 
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
module mux5(
	input [4:0] input0,
	input [4:0] input1,
	input [4:0] input2,
	input [4:0] input3,
	input [1:0] select,
	output reg [4:0] mux_out
    );
	 
	always@(input0 or input1 or input2 or input3 or select) begin
		case(select)
			2'd0: mux_out = input0;
			2'd1: mux_out = input1;
			2'd2: mux_out = input2;
			2'd3: mux_out = input3;
		endcase
	end

endmodule
