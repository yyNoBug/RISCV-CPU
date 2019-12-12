`include "defines.v"

module id(
    input wire rst,
    input wire branch_interception,

    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus] inst_i,


    // Interaction with regfile.
    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,
    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,

    output reg[`AluSelBus] alusel_o,
    output reg[`RegBus] opr1_o,
    output reg[`RegBus] opr2_o,
    output reg[`ImmBus] opr3_o,
    output reg[`InstAddrBus] opr4_o,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o, //译码阶段的指令是否有要写入的目的寄存器
    output reg[`InstBus] inst_o, // For debug use.

    // For data-fowarding.
    input wire dataf_ex_we, //If there isn't any error here, I'm 50% confident that data-fowarding will work properly.
    input wire[`RegAddrBus] dataf_ex_wd,
    input wire[`RegBus] dataf_ex_data,
    input wire[1:0] dataf_ex_memcnf,
    input wire dataf_exmem_we,
    input wire[`RegAddrBus] dataf_exmem_wd,
    input wire[1:0] dataf_exmem_memcnf,
    input wire dataf_mem_we,
    input wire[`RegAddrBus] dataf_mem_wd,
    input wire[`RegBus] dataf_mem_data,
    //input wire[1:0] dataf_mem_memcnf,

    output wire id_stall
);

    wire[6:0] op = inst_i[6:0];
    reg[`ImmBus] imm; 

    reg flag1;
    reg flag2;
    assign id_stall = flag1 | flag2;

    always @ (*) begin
        if (rst || branch_interception) begin
            alusel_o = 0;
            wd_o = 0;
            wreg_o = 0;
            imm = 0;
            reg1_read_o = 0;
            reg2_read_o = 0;
            reg1_addr_o = 0;
            reg2_addr_o = 0;
            inst_o = 0;
        
        end else begin
            alusel_o[2:0] = inst_i[14:12];
            wd_o = inst_i[11:7];
            wreg_o = 0;
            imm = 0;
            reg1_read_o = 0;
            reg2_read_o = 0;
            reg1_addr_o = inst_i[19:15];
            reg2_addr_o = inst_i[24:20];
            inst_o = inst_i;

            case (op)
            `EXE_ORI: begin
                alusel_o[4:3] = 1'b00;
                wreg_o = `WriteEnable;
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                imm = {{20{inst_i[31]}}, inst_i[31:20]};
            end
            `EXE_OR: begin
                alusel_o[4:3] = 1'b00;
                wreg_o = `WriteEnable;
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;
                imm = {{20{inst_i[31]}}, inst_i[31:20]};
            end
            `EXE_LUI: begin
                alusel_o = `SEL_LUI;
                wreg_o = `WriteEnable;
                imm = {inst_i[31:12], {12{1'b0}}};
            end
            `EXE_AUIPC: begin
                alusel_o = `SEL_AUIPC;
                wreg_o = `WriteEnable;
                imm = {inst_i[31:12], {12{1'b0}}};
            end
            `EXE_JAL: begin
                alusel_o = `SEL_JAL;
                wreg_o = `WriteEnable;
                imm = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
            end
            `EXE_JALR: begin
                alusel_o = `SEL_JALR;
                wreg_o = `WriteEnable;
                reg1_read_o = 1'b1;
                imm = {{20{inst_i[31]}}, inst_i[31:20]};
            end
            `EXE_BEQ: begin
                alusel_o[4:3] = 2'b10;
                reg1_read_o = 1;
                reg2_read_o = 1;
                imm = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
            end
            `EXE_LOAD: begin
                alusel_o[4:3] = 2'b11;
                wreg_o = `WriteEnable;
                reg1_read_o = 1;
                imm = {{20{inst_i[31]}} ,inst_i[31:20]};
            end
            `EXE_STORE: begin
                case(inst_i[14:12])
                3'b000: begin
                    alusel_o = `SEL_SB;
                end
                3'b001: begin
                    alusel_o = `SEL_SH;
                end
                3'b010: begin
                    alusel_o = `SEL_SW;
                end
                default: begin
                    $display("BOOM!");
                end
                endcase
                reg1_read_o = 1;
                reg2_read_o = 1;
                imm = {{20{inst_i[31]}} ,inst_i[31:25], inst_i[11:7]};
            end
            default: begin
                //if (inst_i) $display("BOOMSHAKALAKA!");
                alusel_o = 0;
            end
            endcase
        end
    end

    // For correctness: an instruction must not get the data it calculates by data-forwarding.
    // For correctness: if something after ID stalls, ID may not get the true value from data-fowarding, so IF_ID should also stall.
    always @ (*) begin
        flag1 = `False;
        if (rst == `RstEnable) begin
            opr1_o = 0;
        end else if ((reg1_read_o == 1'b1) && (reg1_addr_o == 0)) begin
            opr1_o = 0;
        end else if (reg1_read_o && reg1_addr_o == dataf_ex_wd
        && dataf_ex_we && dataf_ex_memcnf) begin
            flag1 = `True;
        end else if (reg1_read_o == 1'b1 && reg1_addr_o == dataf_ex_wd 
        && dataf_ex_we == `WriteEnable) begin
            opr1_o = dataf_ex_data;
            //$display("Caught ex.");
        end else if (reg1_read_o == 1'b1 && reg1_addr_o == dataf_mem_wd
        && dataf_mem_we == `WriteEnable) begin
            opr1_o = dataf_mem_data;
            //$display("Caught mem.");
        end else if (reg1_read_o && dataf_exmem_we && 
        reg1_addr_o == dataf_exmem_wd && dataf_exmem_memcnf) begin
            flag1 = `True; // It is awkward, but I think it has to be like that.
        end else if (reg1_read_o == 1'b1) begin
            opr1_o = reg1_data_i;
        end else if (reg1_read_o == 1'b0) begin
            opr1_o = imm;
        end

        if (reg1_read_o && dataf_exmem_we && reg1_addr_o == dataf_exmem_we && !dataf_exmem_memcnf) begin
            $display("Something goes wrong, check ID.");
        end
    end

    always @ (*) begin
        flag2 = `False;
        if (rst == `RstEnable) begin
            opr2_o = 0;
        end else if (reg2_read_o == 1'b1 && reg2_addr_o == 0) begin
            opr2_o = 0;
        end else if (reg2_read_o && reg2_addr_o == dataf_ex_wd
        && dataf_ex_we && dataf_ex_memcnf) begin
            flag2 = `True;
        end else if (reg2_read_o == 1'b1 && reg2_addr_o == dataf_ex_wd 
        && dataf_ex_we == `WriteEnable) begin
            opr2_o = dataf_ex_data;
            //$display("Caught ex.");
        end else if (reg2_read_o == 1'b1 && reg2_addr_o == dataf_mem_wd
        && dataf_mem_we == `WriteEnable) begin
            opr2_o = dataf_mem_data;
            //$display("Caught mem.");
        end else if (reg2_read_o && dataf_exmem_we && 
        reg2_addr_o == dataf_exmem_wd && dataf_exmem_memcnf) begin
            flag2 = `True;
        end else if (reg2_read_o == 1'b1) begin
            opr2_o = reg2_data_i;
        end else if (reg2_read_o == 1'b0) begin
            opr2_o = imm;
        end

        if (reg2_read_o && dataf_exmem_we && reg2_addr_o == dataf_exmem_we && !dataf_exmem_memcnf) begin
            $display("Something goes wrong, check ID.");
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            opr3_o = 0;
        end else if(reg1_read_o == 1'b1 && reg2_read_o == 1'b1) begin
            opr3_o = imm;
        end else begin
            opr3_o = 0;
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            opr4_o = 0;
        end else begin
            opr4_o = pc_i;
        end
    end

endmodule