`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:22:31 05/26/2015 
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
	input rst_n,
	input [31:0] inst,
	input [31:0] IF_ID_inst,
	output reg stall
    );
	
	wire [4:0] rs;
	wire [4:0] rt;
	
	wire [4:0] IF_ID_rs;
	wire [4:0] IF_ID_rt;
	
	assign rs = inst[25:21];
	assign rt = inst[20:16];
	
	assign IF_ID_rt = IF_ID_inst[20:16];
	
	always@(inst or IF_ID_inst) begin
		if(((IF_ID_rt == rt) | (IF_ID_rt == rs)) && (inst != 32'd0)) begin
			stall = 1;
		end else begin
			stall = 0;
		end
	end

endmodule
