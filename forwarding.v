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
	input [31:0] inst,
	input [4:0] rs,
	input [4:0] rt,
	input [4:0] ID_EX_rs,
	input [4:0] ID_EX_rt,
    input [4:0] EX_MEM_dest,
    input [4:0] MEM_WB_dest,
	input EX_MEM_Reg_Write,
	input MEM_WB_Reg_Write,
	output reg [1:0] ForwardA_Source,
    output reg [1:0] ForwardB_Source,
    output reg [1:0] ID_ForwardA_Source,
    output reg [1:0] ID_ForwardB_Source,
	output reg [1:0] ID_Data_Source,
	output reg EX_Data_Source
    );
	
	wire sw;
	assign sw 		= inst[31] & ~inst[30] & inst[29] & ~inst[28] & inst[27] & inst[26];
	
	// conditions for ForwardA and ForwardB used are those found in the textbook
	// the difference of ForwardA and ForwardB is simply rs and rt, respectively
	
	// ForwardA
	always@(EX_MEM_Reg_Write or EX_MEM_dest or ID_EX_rs or MEM_WB_Reg_Write or MEM_WB_dest) begin
		if(MEM_WB_Reg_Write && MEM_WB_dest != 0 && MEM_WB_dest == ID_EX_rs && EX_MEM_dest != ID_EX_rs) begin
			ForwardA_Source = 2'b10;
		end else if(EX_MEM_Reg_Write && EX_MEM_dest != 0 && EX_MEM_dest == ID_EX_rs) begin
			ForwardA_Source = 2'b01;
		end else begin
			ForwardA_Source = 2'b00;
		end
	end
	
	// ForwardB
	always@(EX_MEM_Reg_Write or EX_MEM_dest or ID_EX_rt or MEM_WB_Reg_Write or MEM_WB_dest) begin
		if(MEM_WB_Reg_Write && MEM_WB_dest != 0 && MEM_WB_dest == ID_EX_rt && EX_MEM_dest != ID_EX_rt) begin
			ForwardB_Source = 2'b10;
		end else if(EX_MEM_Reg_Write && EX_MEM_dest != 0 && EX_MEM_dest == ID_EX_rt) begin
			ForwardB_Source = 2'b01;
		end else begin
			ForwardB_Source = 2'b00;
		end	
	end
	
	// For 2 spaced dependencies
	
	// ID_ForwardA
	always@(rs or MEM_WB_Reg_Write or MEM_WB_dest) begin
		if(MEM_WB_Reg_Write && MEM_WB_dest != 0 && MEM_WB_dest == rs) begin
			ID_ForwardA_Source = 2'b01;
		end else begin
			ID_ForwardA_Source = 2'b00;
		end
	end
	
	// ID_ForwardB
	always@(rt or MEM_WB_Reg_Write or MEM_WB_dest) begin
		if(MEM_WB_Reg_Write && MEM_WB_dest != 0 && MEM_WB_dest == rt) begin
			ID_ForwardB_Source = 2'b01;
		end else begin
			ID_ForwardB_Source = 2'b00;
		end
	end
	
	// ID Data Forwarding for Memory Writes
	always@(MEM_WB_Reg_Write or MEM_WB_dest or rt or EX_MEM_Reg_Write or EX_MEM_dest) begin
		if(MEM_WB_Reg_Write && MEM_WB_dest != 0 && MEM_WB_dest == rt && EX_MEM_dest != rt) begin
			ID_Data_Source = 2'b10;
		end else if(EX_MEM_Reg_Write && EX_MEM_dest != 0 && EX_MEM_dest == rt) begin
			ID_Data_Source = 2'b01;
		end else begin
			ID_Data_Source = 2'b00;
		end
	end
	
	
	// EX Data Forwarding for Memory Writes
	always@(ID_EX_rt or EX_MEM_Reg_Write or EX_MEM_dest) begin
		if(EX_MEM_Reg_Write && EX_MEM_dest != 0 && EX_MEM_dest == ID_EX_rt) begin
			EX_Data_Source = 1;
		end else begin
			EX_Data_Source = 0;
		end
	end
	
endmodule
