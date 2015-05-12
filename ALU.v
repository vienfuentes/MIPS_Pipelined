`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:31:52 02/16/2015 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
	input [31:0] ALU_A,
	input [31:0] ALU_B,
	input [3:0] ALU_Control,
	input [4:0] shamt,
	output reg [31:0] ALU_Output,
	output reg zero
    );
	
	always@(ALU_A or ALU_B or ALU_Control) begin	
		case(ALU_Control)
			4'b0000: ALU_Output = ALU_A + ALU_B;				// ADD
			4'b0001: ALU_Output = ALU_A - ALU_B;				// SUB
			4'b0010: ALU_Output = ALU_A & ALU_B;				// AND
			4'b0011: ALU_Output = ALU_A | ALU_B;				// OR
			4'b0100: ALU_Output = ALU_B << shamt;				// SLL
			4'b0101: ALU_Output = ALU_B >> shamt;				// SRL
			4'b0110: begin										// SRA
				if(shamt == 0) begin
					ALU_Output = ALU_B;
				end else begin
					ALU_Output = (ALU_B >> shamt) | ({32{ALU_B[31]}} << (31 - shamt));
				end
			end
			4'b0111: ALU_Output = {ALU_B[15:0], ALU_A[15:0]};	// LUI
			4'b1000: begin										// SLT
				if(ALU_A > ALU_B) begin
					ALU_Output = 1;
				end else begin
					if(ALU_A == ALU_B) begin
						ALU_Output = ((ALU_A < ALU_B) ? 1:0) ^ ALU_A[31];
					end else begin
						ALU_Output = 0;
					end
				end
			end
		endcase
		zero = ((ALU_A - ALU_B) == 0) ? 1:0;
	end

endmodule
