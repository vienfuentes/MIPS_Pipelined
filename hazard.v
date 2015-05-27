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
    input [31:0] ID_EX_inst,
    input [31:0] EX_MEM_inst,
    input [31:0] MEM_WB_inst,
	output reg stall
    );
	
	wire [4:0] rs;
	wire [4:0] rt;
	
	wire [4:0] IF_ID_rs;
	wire [4:0] IF_ID_rt;
	
	wire [4:0] ID_EX_rt;
	
	assign rs = inst[25:21];
	assign rt = inst[20:16];
	
	assign IF_ID_rs = IF_ID_inst[25:21];
	assign IF_ID_rt = IF_ID_inst[20:16];
	
	assign ID_EX_rt = ID_EX_inst[20:16];
	
	wire lw, lb, l_type;
	wire mem_access;
	
	assign lw 		= inst[31] & ~inst[30] & ~inst[29] & ~inst[28] & inst[27] & inst[26];
	assign lb 		= inst[31] & ~inst[30] & ~inst[29] & ~inst[28] & ~inst[27] & ~inst[26];
	assign l_type 	= lw | lb;
	assign mem_access = l_type;
	
	always@(inst or IF_ID_inst or ID_EX_inst or EX_MEM_inst or MEM_WB_inst) begin
		if(~rst_n) begin
			stall <= 0;
		end else begin
			if(((ID_EX_rt == IF_ID_rt) | (ID_EX_rt == IF_ID_rs)) && (IF_ID_inst != 32'd0) && mem_access) begin
				stall <= 1;
			end else begin
				stall <= 0;
			end
		end
	end

endmodule
