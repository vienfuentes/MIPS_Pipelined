`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:54:46 05/27/2015 
// Design Name: 
// Module Name:    forwarding 
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
module forwarding(
	input [4:0] ID_EX_rs,
	input [4:0] ID_EX_rt,
    input [4:0] EX_MEM_dest,
    input [4:0] MEM_WB_dest,
	input EX_MEM_Reg_Write,
	input MEM_WB_Reg_Write,
	output reg [2:0] ForwardA_Source,
    output reg [2:0] ForwardB_Source
    );
	
	// conditions used are those found in the textbook
	// the difference of ForwardA and ForwardB is simply rs and rt, respectively
	
	// may isa pang case :(
	
	// ForwardA
	always@(EX_MEM_Reg_Write or EX_MEM_dest or ID_EX_rs or MEM_WB_Reg_Write or MEM_WB_dest) begin
		if(MEM_WB_Reg_Write && MEM_WB_dest != 0 && MEM_WB_dest == ID_EX_rs && EX_MEM_dest != ID_EX_rs) begin
			ForwardA_Source = 3'b010;
		end else if(EX_MEM_Reg_Write && EX_MEM_dest != 0 && EX_MEM_dest == ID_EX_rs) begin
			ForwardA_Source = 3'b001;
		end else begin
			ForwardA_Source = 3'b000;
		end
	end
	
	// ForwardB
	always@(EX_MEM_Reg_Write or EX_MEM_dest or ID_EX_rt or MEM_WB_Reg_Write or MEM_WB_dest) begin
		if(MEM_WB_Reg_Write && MEM_WB_dest != 0 && MEM_WB_dest == ID_EX_rt && EX_MEM_dest != ID_EX_rt) begin
			ForwardB_Source = 3'b010;
		end else if(EX_MEM_Reg_Write && EX_MEM_dest != 0 && EX_MEM_dest == ID_EX_rt) begin
			ForwardB_Source = 3'b001;
		end else begin
			ForwardB_Source = 3'b000;
		end	
	end
	
endmodule
