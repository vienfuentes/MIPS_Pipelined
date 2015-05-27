`timescale 1ns/1ps
`define CLK_PERIOD 100
`define DATA_SIZE 25 
`define TIMEOUT 100
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 32
module tester;
  reg clk,rst_n;
  wire [31:0] inst_addr;
  reg [31:0] inst;
  wire [31:0] data_addr,data_out;
  reg [31:0] data_in;
  wire data_wr;
  // mods
  wire [31:0] PC_IF_ID, PC_ID_EX, PC_EX_MEM, PC_MEM_WB;
  wire [31:0] EPC;
  wire exception, cause;

  reg [`MEM_WIDTH-1:0] memory_data [0:`MEM_DEPTH-1];

  processor UUT(
    .clk(clk),
    .rst_n(rst_n),
    .inst_addr(inst_addr),
    .inst(inst),
    .data_addr(data_addr),
    .data_in(data_in),
    .data_out(data_out),
    .data_wr(data_wr),
	// mods
	.PC_IF_ID(PC_IF_ID),
    .PC_ID_EX(PC_ID_EX),
    .PC_EX_MEM(PC_EX_MEM),
    .PC_MEM_WB(PC_MEM_WB),
	.EPC(EPC),
    .exception(exception),
    .cause(cause)
    );

  always begin
    clk = 0;
    #(`CLK_PERIOD/2.0);
    clk = 1'b1;
    #(`CLK_PERIOD/2.0);
  end

  integer i,cnt_nop,cnt_tout;
  initial begin
    $vcdplusfile("tester.vpd");
    $vcdpluson;
    rst_n = 0;
    cnt_nop = 0;
    cnt_tout = 0;
    #(`CLK_PERIOD/4.0);
    #(`CLK_PERIOD*10);
    rst_n = 1'b1;

    /* Run */
    while((cnt_nop < 19)&&(cnt_tout < `TIMEOUT)) begin		// from 9 to 25
      cnt_tout = cnt_tout + 1;
      if (inst == 0)
        cnt_nop = cnt_nop + 1;
      #`CLK_PERIOD;
    end

    /* Print Memory */
    for (i=0; i<`DATA_SIZE; i=i+1) begin
      $display("addr %d: %x%x%x%x",i*4,
        memory_data[i*4],memory_data[(i*4)+1],
        memory_data[(i*4)+2],memory_data[(i*4)+3]);
    end
    
    //$finish;
  end

  /* instruction memory */
  reg [`MEM_WIDTH-1:0] memory_inst [0:`MEM_DEPTH-1];
  initial begin
    `ifdef t1
     $readmemh("instmem1.txt",memory_inst);
    `elsif t2
     $readmemh("instmem2.txt",memory_inst);
    `elsif t3
     $readmemh("instmem3.txt",memory_inst);
    `else
     $readmemh("instmem5b.txt",memory_inst);
    `endif
  end
  always@(*)
    inst <= {memory_inst[inst_addr],
             memory_inst[inst_addr+1],
             memory_inst[inst_addr+2],
             memory_inst[inst_addr+3]};

  /* data memory */
  initial begin
    $readmemh("datamem3.txt",memory_data);
  end
  always@(*)
    data_in <= {memory_data[data_addr],
                memory_data[data_addr+1],
                memory_data[data_addr+2],
                memory_data[data_addr+3]};
  always@(posedge clk)
    if (data_wr) begin
      memory_data[data_addr] <= data_out[31:24];
      memory_data[data_addr+1] <= data_out[23:16];
      memory_data[data_addr+2] <= data_out[15:8];
      memory_data[data_addr+3] <= data_out[7:0];
    end

endmodule
