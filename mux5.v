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
	input [4:0] input4,
	input [4:0] input5,
	input [4:0] input6,
	input [4:0] input7,
	input [2:0] select,
	output reg [4:0] mux_out
    );
	 
	always@(input0 or input1 or input2 or input3 or input4 or input5 or input6 or input7 or select) begin
		case(select)
			3'd0: mux_out = input0;
			3'd1: mux_out = input1;
			3'd2: mux_out = input2;
			3'd3: mux_out = input3;
			3'd4: mux_out = input4;
			3'd5: mux_out = input5;
			3'd6: mux_out = input6;
			3'd7: mux_out = input7;
		endcase
	end

endmodule
