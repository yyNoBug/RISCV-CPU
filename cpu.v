`include "defines.v"
// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
    input  wire					rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

  	output wire [31:0]		    dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

//PC_REG -> IF
wire[`InstAddrBus] if_pc_i;

//IF -> IF/ID
wire[`InstAddrBus] if_pc_o;
wire[`InstAddrBus] if_inst_o;

//IF/ID -> ID
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstAddrBus] id_inst_i;

//ID -> ID/EX
wire[`AluOpBus] id_alusel_o;
wire[`RegBus] id_opr1_o;
wire[`RegBus] id_opr2_o;
wire[`ImmBus] id_opr3_o;
wire[`InstAddrBus] id_opr4_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;

//ID/EX -> EX
wire[`AluOpBus] ex_alusel_i;
wire[`RegBus] ex_opr1_i;
wire[`RegBus] ex_opr2_i;
wire[`ImmBus] ex_opr3_i;
wire[`InstAddrBus] ex_opr4_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;

//EX -> EX/MEM
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_wdata_o;
wire[`MemAddrBus] ex_memaddr_o;
wire ex_memwr_o;
wire[1:0] ex_memcnf_o;
wire ex_memsigned_o;

//EX/MEM -> MEM
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_wdata_i;
wire[`MemAddrBus] mem_memaddr_i;
wire mem_memwr_i;
wire[1:0] mem_memcnf_i;
wire mem_memsigned_i;

//MEM -> MEM/WB
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_wdata_o;
wire[1:0] mem_memcnf_o;

//MEM/WB -> WB
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegBus] wb_wdata_i;

//ID -> RegFile
wire reg1_read;
wire reg2_read;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

//Stall
/*
NOTICE: For stall correctness.
For (*) modules like ID, when it stalls, it should maintain the same output.
For (clk) modules like ID_EXE, when it receives the same input, it should maintain the same output.
*/
wire if_stall;
wire id_stall;
wire ex_stall;
wire mem_stall;
wire pcreg_stall;
wire ifid_stall;
wire idex_stall;
wire exmem_stall;


// Branch
wire br;
wire[`InstAddrBus] npc;

//Mem-control
wire[`InstAddrBus] mc_inst_addr_i;
wire[`InstAddrBus] mc_inst_addr_o;
wire mc_almost_available_o;
wire mc_available_o;
wire[`InstBus] mc_inst_o;

pc_reg pc_reg0(
    .clk(clk_in), .rst(rst_in), 
    .branch_interception(br), .npc(npc),
    .if_stall(pcreg_stall), .if_pc_i(if_pc_i)
);

iF if0(
    .rst(rst_in), .branch_interception(br),
    .pc_in(if_pc_i), .pc_out(if_pc_o), .inst_out(if_inst_o),
    .addr_needed(mc_almost_available_o),
    .inst_available(mc_available_o), .inst_in(mc_inst_o),
    .pc_back(mc_inst_addr_o), .pc_mem(mc_inst_addr_i), .if_stall(if_stall)
);

//assign mem_a = pc;

mem_control mem_control0(
    .clk(clk_in), .rst(rst_in), .branch_interception(br),
    .dout_ram(mem_dout), .din_ram(mem_din),
    .addr_ram(mem_a), .wr_ram(mem_wr),
    .inst_addr_i(mc_inst_addr_i), .inst_addr_o(mc_inst_addr_o),
    .almost_available(mc_almost_available_o),
    .available(mc_available_o), .inst(mc_inst_o)
);

if_id if_id0(
    .clk(clk_in), .rst(rst_in), .branch_interception(br),
    .if_pc(if_pc_o),
    .if_inst(if_inst_o), .id_pc(id_pc_i),
    .id_inst(id_inst_i), .ifid_stall(ifid_stall)
);

id id0(
    .rst(rst_in), .pc_i(id_pc_i), .branch_interception(br),
    .inst_i(id_inst_i),
    
    //from RegFile
    .reg1_data_i(reg1_data), .reg2_data_i(reg2_data),

    //to RegFile
    .reg1_read_o(reg1_read), .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),
    
    //to ID/EX
    .alusel_o(id_alusel_o),
    .opr1_o(id_opr1_o), .opr2_o(id_opr2_o), 
    .opr3_o(id_opr3_o), .opr4_o(id_opr4_o),
    .wd_o(id_wd_o), .wreg_o(id_wreg_o),

    //data-fowarding
    .dataf_ex_we(ex_wreg_o), .dataf_ex_wd(ex_wd_o),
    .dataf_ex_data(ex_wdata_o), .dataf_ex_memcnf(ex_memcnf_o),
    .dataf_mem_we(mem_wreg_o), .dataf_mem_wd(mem_wd_o), 
    .dataf_mem_data(mem_wdata_o), .dataf_mem_memcnf(mem_memcnf_o),

    .id_stall(id_stall)
);

regfile regfile0(
    .clk(clk_in), .rst(rst_in),
    .we(wb_wreg_i), .waddr(wb_wd_i), .wdata(wb_wdata_i),
    .re1(reg1_read), .re2(reg2_read), 
    .raddr1(reg1_addr), .raddr2(reg2_addr),
    .rdata1(reg1_data), .rdata2(reg2_data)
);

id_ex id_ex0(
    .clk(clk_in), .rst(rst_in), .branch_interception(br),
    .id_alusel(id_alusel_o),
    .id_opr1(id_opr1_o), .id_opr2(id_opr2_o), 
    .id_opr3(id_opr3_o), .id_opr4(id_opr4_o),
    .id_wd(id_wd_o), .id_wreg(id_wreg_o),
    
    .ex_alusel(ex_alusel_i),
    .ex_opr1(ex_opr1_i), .ex_opr2(ex_opr2_i),
    .ex_opr3(ex_opr3_i), .ex_opr4(ex_opr4_i),
    .ex_wd(ex_wd_i), .ex_wreg(ex_wreg_i),

    .idex_stall(idex_stall)
);

ex ex0(
    .rst(rst_in),
    .alusel_i(ex_alusel_i),
    .opr1_i(ex_opr1_i), .opr2_i(ex_opr2_i),
    .opr3_i(ex_opr3_i), .opr4_i(ex_opr4_i),
    .wd_i(ex_wd_i), .wreg_i(ex_wreg_i),
    
    .wd_o(ex_wd_o), .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),
    .memaddr_o(ex_memaddr_o), .memwr_o(ex_memwr_o),
    .memcnf_o(ex_memcnf_o), .memsigned_o(ex_memsigned_o),

    .branch_interception(br), .npc(npc),

    .ex_stall(ex_stall)
);

ex_mem ex_mem0(
    .clk(clk_in), .rst(rst_in),
    .ex_wd(ex_wd_o), .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),
    .ex_memaddr(ex_memaddr_o), .ex_memwr(ex_memwr_o),
    .ex_memcnf(ex_memcnf_o), .ex_memsigned(ex_memsigned_o),
    .mem_wd(mem_wd_i), .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),
    .mem_memaddr(mem_memaddr_i), .mem_memwr(mem_memwr_i),
    .mem_memcnf(mem_memcnf_i), .mem_memsigned(mem_memsigned_i),

    .exmem_stall(exmem_stall)
);

mem mem0(
    .rst(rst_in),
    .wd_i(mem_wd_i), .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),

    .memaddr_i(mem_memaddr_i), .memwr_i(mem_memwr_i),
    .memcnf_i(mem_memcnf_i), .memsigned_i(mem_memsigned_i),

    .wd_o(mem_wd_o), .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o), .memcnf_o(dataf_mem_memcnf),

    .mem_stall(mem_stall)
);

mem_wb mem_wb0(
    .clk(clk_in), .rst(rst_in),
    .mem_wd(mem_wd_o), .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),

    .wb_wd(wb_wd_i), .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i)
);

stall_control stall_ctrl0(
    .if_stall(if_stall), .id_stall(id_stall),
    .ex_stall(ex_stall), .mem_stall(mem_stall),
    .pcreg_stall(pcreg_stall), .ifid_stall(ifid_stall),
    .idex_stall(idex_stall), .exmem_stall(exmem_stall)
);

/*
always @(posedge clk_in)
  begin
    if (rst_in)
      begin
      
      end
    else if (!rdy_in)
      begin
      
      end
    else
      begin
      
      end
  end
*/
endmodule