`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:13:50 02/28/2015 
// Design Name: 
// Module Name:    processor 
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
module processor(
	input clk,
	input rst_n,
	input [31:0] data_in,
	input [31:0] inst,
	output reg [31:0] inst_addr,
	output [31:0] data_out,
	output [31:0] data_addr,
	output data_wr,
	output reg [31:0] PC_IF_ID,
	output reg [31:0] PC_ID_EX,
	output reg [31:0] PC_EX_MEM,
	output reg [31:0] PC_MEM_WB,
	output [31:0] EPC,
	output exception,
	output cause
    );
	
	// bookkeeping
	reg [2:0] state;
	
	// instruction fetch
	wire [31:0] PC;
	wire [2:0] PC_Src;
	
	// register file write muxes
	wire [2:0] Reg_Write_Dest_Source;
	wire [2:0] Reg_Write_Data_Source;
	
	// writes
	wire Reg_Write;
	wire Mem_Write;
	
	// ALU IO
	wire [31:0] ALU_A;
	wire [31:0] ALU_B;
	wire [3:0] ALU_Control;
	wire [4:0] shamt;
	wire [31:0] ALU_Output;
	wire new_zero;
	wire overflow;
	
	// ALU input muxes
	wire [2:0] ALU_A_Source;
	wire [2:0] ALU_B_Source;
	
	// IF/ID registers
	reg [31:0] IF_ID_inst;
	reg [31:0] PC_IF_ID_plus4;
	reg IF_ID_flush;

	// register file IO
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd;
	wire [4:0] writereg;
	wire [31:0] writedata;
	wire regwrite;
	wire [31:0] readdata1;
	wire [31:0] readdata2;
	
	assign rs = IF_ID_inst[25:21];
	assign rt = IF_ID_inst[20:16];
	assign rd = IF_ID_inst[15:11];
	
	// sign extending
	wire [31:0] sign_extended;
	wire [31:0] shifted_sign_extended;	
	wire extend_bit;
	
	assign sign_extended = {{16{extend_bit}}, IF_ID_inst[15:0]};
	assign shifted_sign_extended = sign_extended << 2;
	
	// ALU input muxes
	mux32 mux_ALU_A_handler(readdata1, readdata2, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, ALU_A_Source, ALU_A);
	mux32 mux_ALU_B_handler(sign_extended, readdata2, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, ALU_B_Source, ALU_B);

	// shift amount
	assign shamt = IF_ID_inst[10:6];
	
	// branch calculation
	assign new_zero = ((ALU_A - ALU_B) == 0) ? 1 : 0;
	
	// simple flusher
	wire flush;
	flusher flusher(PC_Src, flush);

	// invalid instructions
	wire inv;
	
	// stalling
	wire stall;
	
	// main hazard unit
	hazard hazard(rst_n, inst, IF_ID_inst, ID_EX_inst, EX_MEM_inst, MEM_WB_inst, stall);
	
	// main control unit
	controller controller(IF_ID_inst, new_zero, IF_ID_flush, stall, Reg_Write_Dest_Source, ALU_A_Source, ALU_B_Source, ALU_Control, PC_Src, Reg_Write_Data_Source, Reg_Write, Mem_Write, extend_bit, inv);
	// zero is deprecated. use new_zero instead, which does not use the ALU.
	
	// jump address
	wire [31:0] jumpaddr;
	assign jumpaddr = {IF_ID_inst[31:28], IF_ID_inst[25:0], 2'b00};
	
	// PC_Src
	mux32 mux_nextPC(inst_addr + 4, PC_IF_ID + 4 + shifted_sign_extended, readdata1, jumpaddr, inst_addr, 32'd0, 32'd0, 32'd0, PC_Src, PC);
	// uses PC_IF_ID instead of inst_addr since branch calculation is in the ID stage
	
	// ID/EX registers
	reg [31:0] ID_EX_inst;	
	reg [31:0] ID_EX_ALU_A;
	reg [31:0] ID_EX_ALU_B;
	reg [31:0] ID_EX_readdata1;
	reg [31:0] ID_EX_readdata2;
	reg [4:0] ID_EX_rs;								// for hazard detection
	reg [4:0] ID_EX_rt;
	reg [4:0] ID_EX_rd;
	reg [4:0] ID_EX_shamt;
	
	reg [2:0] ID_EX_Reg_Write_Dest_Source;
	reg [3:0] ID_EX_ALU_Control;
	reg [2:0] ID_EX_Reg_Write_Data_Source;
	reg ID_EX_Reg_Write;
	reg ID_EX_Mem_Write;
	
	reg ID_EX_inv;
	
	// register write destination mux
	mux5 mux_writeregdest(ID_EX_rd, ID_EX_rt, 5'b11111, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, ID_EX_Reg_Write_Dest_Source, writereg);	
	
	// forwarding stuff
	wire [2:0] ForwardA_Source;
	wire [2:0] ForwardB_Source;
	
	forwarding forwarding(ID_EX_rs, ID_EX_rt, EX_MEM_writereg, MEM_WB_writereg, EX_MEM_Reg_Write, MEM_WB_Reg_Write, ForwardA_Source, ForwardB_Source);
	
	wire [31:0] ForwardA;
	wire [31:0] ForwardB;
	
	mux32 mux_ForwardA_handler(ID_EX_ALU_A, EX_MEM_ALU_Output, writedata, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, ForwardA_Source, ForwardA);
	mux32 mux_ForwardB_handler(ID_EX_ALU_B, EX_MEM_ALU_Output, writedata, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, ForwardB_Source, ForwardB);
	
	// ALU
	ALU ALU(ForwardA, ForwardB, ID_EX_ALU_Control, ID_EX_shamt, ALU_Output, overflow);
	
	// exception handling
	assign exception = ID_EX_inv | overflow;
	assign cause = overflow;
	assign EPC = exception ? ID_EX_inst : 0;
	
	// EX/MEM registers
	reg [31:0] EX_MEM_inst;
	reg [31:0] EX_MEM_ALU_Output;
	reg [31:0] EX_MEM_readdata2;					// will be muxed later in hazard detection, as is readdata1
	reg [4:0] EX_MEM_writereg;
	
	reg [2:0] EX_MEM_Reg_Write_Data_Source;
	reg EX_MEM_Reg_Write;
	reg EX_MEM_Mem_Write;
	
	// processor IO	
	assign data_out = EX_MEM_readdata2;
	assign data_addr = EX_MEM_ALU_Output;
	assign data_wr = EX_MEM_Mem_Write;
	
	// MEM/WB registers
	reg [31:0] MEM_WB_inst;
	reg [31:0] MEM_WB_data_in;
	reg [31:0] MEM_WB_ALU_Output;
	reg [4:0] MEM_WB_writereg;
	
	reg [2:0] MEM_WB_Reg_Write_Data_Source;
	reg MEM_WB_Reg_Write;
	
	// register writeback signal
	assign regwrite = MEM_WB_Reg_Write;

	// register write data mux
	mux32 mux_writeregdata(MEM_WB_data_in, {24'b0, MEM_WB_data_in[31:24]}, PC_MEM_WB + 4, MEM_WB_ALU_Output, 32'd0, 32'd0, 32'd0, 32'd0, MEM_WB_Reg_Write_Data_Source, writedata);
	
	// register file
	registers registers(clk, rst_n, rs, rt, MEM_WB_writereg, writedata, regwrite, readdata1, readdata2);
	
	///////////////////////////////////////////////////////////////

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			state <= 3'b000;
			
			// IF/ID registers
			PC_IF_ID <= 32'b0;
			IF_ID_inst <= 32'b0;
			PC_IF_ID_plus4 <= 32'b0;
			IF_ID_flush <= 0;
			
			// ID/EX registers
			PC_ID_EX <= 32'b0;
			ID_EX_inst <= 32'b0;
			ID_EX_ALU_A <= 32'b0;
			ID_EX_ALU_B <= 32'b0;
			ID_EX_readdata1 <= 32'b0;
			ID_EX_readdata2 <= 32'b0;
			ID_EX_rs <= 5'b0;
			ID_EX_rt <= 5'b0;
			ID_EX_rd <= 5'b0;
			ID_EX_shamt <= 5'b0;
			
			ID_EX_Reg_Write_Dest_Source <= 3'b0;
			ID_EX_ALU_Control <= 4'b0;
			ID_EX_Reg_Write_Data_Source <= 3'b0;
			ID_EX_Reg_Write <= 0;
			ID_EX_Mem_Write <= 0;
			
			ID_EX_inv <= 0;
			
			// EX/MEM registers
			PC_EX_MEM <= 32'b0;
			EX_MEM_inst <= 32'b0;
			EX_MEM_ALU_Output <= 32'b0;
			EX_MEM_readdata2 <= 32'b0;
			EX_MEM_writereg <= 5'b0;
			
			EX_MEM_Reg_Write_Data_Source <= 3'b0;
			EX_MEM_Reg_Write <= 0;
			EX_MEM_Mem_Write <= 0;
			
			// MEM/WB registers
			PC_MEM_WB <= 32'b0;
			MEM_WB_inst <= 32'b0;
			MEM_WB_data_in <= 32'b0;
			MEM_WB_ALU_Output <= 32'b0;
			MEM_WB_writereg <= 5'b0;
					
			MEM_WB_Reg_Write_Data_Source <= 3'b0;
			MEM_WB_Reg_Write <= 0;	

		end else begin
			if(state == 3'b000) begin
				inst_addr <= 0;
				state <= 3'b001;
			end else begin
				if(~stall) begin
					inst_addr <= PC;
				end else begin
				end
				
				// IF/ID registers
				PC_IF_ID <= inst_addr;
				IF_ID_inst <= inst;
				PC_IF_ID_plus4 <= inst_addr + 4;
				IF_ID_flush <= flush;
				
				// ID/EX registers
				PC_ID_EX <= PC_IF_ID;
				ID_EX_inst <= IF_ID_inst;
				ID_EX_ALU_A <= ALU_A;
				ID_EX_ALU_B <= ALU_B;
				ID_EX_readdata1 <= readdata1;
				ID_EX_readdata2 <= readdata2;
				ID_EX_rs <= rs;
				ID_EX_rt <= rt;
				ID_EX_rd <= rd;
				ID_EX_shamt <= shamt;
				
				ID_EX_Reg_Write_Dest_Source <= Reg_Write_Dest_Source;
				ID_EX_ALU_Control <= ALU_Control;
				ID_EX_Reg_Write_Data_Source <= Reg_Write_Data_Source;
				ID_EX_Reg_Write <= Reg_Write;
				ID_EX_Mem_Write <= Mem_Write;
				
				ID_EX_inv <= inv;
									
				// EX/MEM registers
				PC_EX_MEM <= PC_ID_EX;
				EX_MEM_inst <= ID_EX_inst;
				EX_MEM_ALU_Output <= ALU_Output;
				EX_MEM_readdata2 <= ID_EX_readdata2;					// will be muxed later, as is readdata1
				EX_MEM_writereg <= writereg;
				
				EX_MEM_Reg_Write_Data_Source <= ID_EX_Reg_Write_Data_Source;
				EX_MEM_Reg_Write <= ID_EX_Reg_Write;
				EX_MEM_Mem_Write <= ID_EX_Mem_Write;
				
				// MEM/WB registers
				PC_MEM_WB <= PC_EX_MEM;
				MEM_WB_inst <= EX_MEM_inst;
				MEM_WB_data_in <= data_in;
				MEM_WB_ALU_Output <= EX_MEM_ALU_Output;
				MEM_WB_writereg <= EX_MEM_writereg;	
				
				MEM_WB_Reg_Write_Data_Source <= EX_MEM_Reg_Write_Data_Source;
				MEM_WB_Reg_Write <= EX_MEM_Reg_Write;
			end
		end
	end
	
endmodule
