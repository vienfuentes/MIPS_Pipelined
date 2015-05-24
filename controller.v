`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:27:51 02/19/2015 
// Design Name: 
// Module Name:    controller 
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
module controller(
	input [31:0] inst,		
	input zero,								// branch computation
	input flush,							// basic flushing from branch/jump
	output [1:0] Reg_Write_Dest_Source,		// mux
	output [1:0] ALU_A_Source,				// mux
	output [1:0] ALU_B_Source,				// mux
	output reg [3:0] ALU_Control,			// ALU
	output [1:0] PC_Src,					// mux
	output [1:0] Reg_Write_Data_Source,		// mux
	output Reg_Write,						// register
	output Mem_Write,						// data memory
	output extend_bit,						// immediate computation
	output [31:0] EPC,
	output exception,
	output cause
    );

	wire l_type, lw, lb;
	wire s_type, sw;
	wire r_type;
	wire i_type, addi, andi, ori, slti, lui;	
	wire b_type;
	wire j_type, jal, jr;
	
	wire und, noop;
	
	assign lw 		= inst[31] & ~inst[30] & ~inst[29] & ~inst[28] & inst[27] & inst[26];
	assign lb 		= inst[31] & ~inst[30] & ~inst[29] & ~inst[28] & ~inst[27] & ~inst[26];
	assign l_type 	= lw | lb;
	
	assign sw 		= inst[31] & ~inst[30] & inst[29] & ~inst[28] & inst[27] & inst[26];
	assign s_type	= sw;
	
	assign j 		= ~inst[31] & ~inst[30] & ~inst[29] & ~inst[28] & inst[27] & ~inst[26];
	assign jal 		= ~inst[31] & ~inst[30] & ~inst[29] & ~inst[28] & inst[27] & inst[26];
	assign jr 		= ~inst[31] & ~inst[30] & ~inst[29] & ~inst[28] & ~inst[27] & ~inst[26] & ~inst[5] & ~inst[4] & inst[3] & ~inst[2] & ~inst[1] & ~inst[0];
	assign j_type 	= j | jal | jr;
	
	assign r_type	= ~inst[31] & ~inst[30] & ~inst[29] & ~inst[28] & ~inst[27] & ~inst[26] & ~jr;
	
	assign addi		= ~inst[31] & ~inst[30] & inst[29] & ~inst[28] & ~inst[27] & ~inst[26];
	assign andi		= ~inst[31] & ~inst[30] & inst[29] & inst[28] & ~inst[27] & ~inst[26];
	assign ori 		= ~inst[31] & ~inst[30] & inst[29] & inst[28] & ~inst[27] & inst[26];
	assign slti		= ~inst[31] & ~inst[30] & inst[29] & ~inst[28] & inst[27] & ~inst[26];
	assign lui		= ~inst[31] & ~inst[30] & inst[29] & inst[28] & inst[27] & inst[26];
	assign i_type	= addi | andi | ori | slti | lui;
	
	assign b_type	= ~inst[31] & ~inst[30] & ~inst[29] & inst[28] & ~inst[27];
	
	assign noop		= (inst == 0) ? 1 : 0;
	assign und		= ((~l_type & ~s_type & ~j_type & ~r_type & ~i_type & ~b_type) | noop);
	
	assign Reg_Write_Dest_Source[1] = jal;
	assign Reg_Write_Dest_Source[0] = l_type | i_type;

	assign Reg_Write_Data_Source[1] = r_type | i_type | jal;
	assign Reg_Write_Data_Source[0] = r_type | i_type | lb;

	assign ALU_A_Source[1] = 0;
	assign ALU_A_Source[0] = lui;
	
	assign ALU_B_Source[1] = 0;
	assign ALU_B_Source[0] = r_type | b_type;

	assign PC_Src[1] = j_type & ~flush & ~und;
	assign PC_Src[0] = (((zero ^ inst[26]) & b_type) | j | jal) & ~flush & ~und;
	
	assign Reg_Write = (l_type | r_type | i_type | jal) & ~flush & ~und;				// no-ops are handled by the register file
	assign Mem_Write = (s_type) & ~flush & ~und;
	
	assign EPC = 0;
	assign exception = 0;
	assign cause = 0;
	
	// ALU_Control
	always@(inst) begin
		case(inst[31:26])
			6'b000000: begin							// r-type
				case(inst[5:0])
					6'b000000: ALU_Control = 4'b0100;		// SLL
					6'b000010: ALU_Control = 4'b0101;		// SRL
					6'b000011: ALU_Control = 4'b0110;		// SRA
					6'b100000: ALU_Control = 4'b0000;		// ADD
					6'b100010: ALU_Control = 4'b0001;		// SUB
					6'b100100: ALU_Control = 4'b0010;		// AND
					6'b100101: ALU_Control = 4'b0011;		// OR
					6'b101010: ALU_Control = 4'b1000;		// SLT			
				endcase
			end
														// b-type
			6'b000100: ALU_Control = 4'b0001;				// BEQ		SUB
			6'b000101: ALU_Control = 4'b0001;				// BNE		SUB
														// i-type
			6'b001000: ALU_Control = 4'b0000;				// ADDI		ADD
			6'b001100: ALU_Control = 4'b0010;				// ANDI		AND
			6'b001101: ALU_Control = 4'b0011;				// ORI		OR
			6'b001010: ALU_Control = 4'b1000;				// SLTI		SLT
			6'b001111: ALU_Control = 4'b0111;				// LUI		LUI
														// l-type
			6'b100011: ALU_Control = 4'b0000;				// LW		ADD
			6'b100000: ALU_Control = 4'b0000;				// LB		ADD
														// s-type
			6'b101011: ALU_Control = 4'b0000;				// SW		ADD
		endcase
	end
	
	assign extend_bit = andi | (inst[15] & ~ori);


endmodule
