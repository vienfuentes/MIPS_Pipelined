`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:34:00 02/19/2015 
// Design Name: 
// Module Name:    registers 
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
module registers(
	input clk,
	input rst_n,
	input [4:0] readreg1,
	input [4:0] readreg2,
	input [4:0] writereg,
	input [31:0] writedata,
	input regwrite,						// regwriteenable
	output reg [31:0] readdata1,
	output reg [31:0] readdata2
    );
	
	integer i;
	reg [31:0] regfile [0:31];

	// also handles no write in no-ops
	always@(readreg1 or regfile[readreg1]) begin
		if (readreg1 == 0) readdata1 = 0;
		else readdata1 = regfile[readreg1];
	end
	
	// also handles no write in no-ops
	always@(readreg2 or regfile[readreg2]) begin
		if (readreg2 == 0) readdata2 = 0;
		else readdata2 = regfile[readreg2];
	end
	
	/* no $r0 modification
	assign readdata1 = regfile[readreg1];
	assign readdata2 = regfile[readreg2];
	*/
	
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			regfile[0]  <= 32'b0;
			regfile[1]  <= 32'b0;
			regfile[2]  <= 32'b0;
			regfile[3]  <= 32'b0;
			regfile[4]  <= 32'b0;
			regfile[5]  <= 32'b0;
			regfile[6]  <= 32'b0;
			regfile[7]  <= 32'b0;
			regfile[8]  <= 32'b0;
			regfile[9]  <= 32'b0;
			regfile[10] <= 32'b0;
			regfile[11] <= 32'b0;
			regfile[12] <= 32'b0;
			regfile[13] <= 32'b0;
			regfile[14] <= 32'b0;
			regfile[15] <= 32'b0;
			regfile[16] <= 32'b0;
			regfile[17] <= 32'b0;
			regfile[18] <= 32'b0;
			regfile[19] <= 32'b0;
			regfile[20] <= 32'b0;
			regfile[21] <= 32'b0;
			regfile[22] <= 32'b0;
			regfile[23] <= 32'b0;
			regfile[24] <= 32'b0;
			regfile[25] <= 32'b0;
			regfile[26] <= 32'b0;
			regfile[27] <= 32'b0;
			regfile[28] <= 32'b0;
			regfile[29] <= 32'b0;
			regfile[30] <= 32'b0;
			regfile[31] <= 32'b0;
		end else begin
			if(regwrite && writereg) begin
				regfile[writereg] <= writedata;
			end
		end	
	end
	
endmodule
