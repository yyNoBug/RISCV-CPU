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
    output reg wreg_o, //译码阶段的指令是否有要写入的目的寄存�??????????

    // For data-fowarding.
    input wire dataf_ex_we, //If there isn't any error here, I'm 50% confident that data-fowarding will work properly.
    input wire[`RegAddrBus] dataf_ex_wd,
    input wire[`RegBus] dataf_ex_data,
    input wire dataf_mem_we,
    input wire[`RegAddrBus] dataf_mem_wd,
    input wire[`RegBus] dataf_mem_data,

    output reg id_stall
);

    wire[6:0] op = inst_i[6:0];
    reg[`ImmBus] imm; 

    reg instvalid;

    always @ (*) begin
        if (rst || branch_interception) begin
            alusel_o = 0;
            wd_o = 0;
            wreg_o = 0;
            imm = 0;
            opr3_o = 0;
            reg1_read_o = 0;
            reg2_read_o = 0;
            reg1_addr_o = 0;
            reg2_addr_o = 0;
            instvalid = `InstInvalid;
            id_stall = `False;
        
        end else begin
            alusel_o[2:0] = inst_i[14:12];
            wd_o = inst_i[11:7];
            wreg_o = 0;
            imm = 0;
            reg1_read_o = 0;
            reg2_read_o = 0;
            reg1_addr_o = inst_i[19:15];
            reg2_addr_o = inst_i[24:20];
            instvalid = `InstValid;
            id_stall = `False;

            case (op)
            `EXE_ORI: begin
                alusel_o[3] = 1'b0;
                wreg_o = `WriteEnable;
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                imm = {{20{inst_i[31]}}, inst_i[31:20]};
                instvalid = `InstValid;
            end
            `EXE_OR: begin
                alusel_o[4:3] = 1'b00;
                wreg_o = `WriteEnable;
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;
                instvalid = `InstValid;
            end
            `EXE_LUI: begin
                alusel_o = `SEL_LUI;
                wreg_o = `WriteEnable;
                imm = {inst_i[31:12], {12{1'b0}}};
                instvalid = `InstValid;
            end
            `EXE_AUIPC: begin
                alusel_o = `SEL_AUIPC;
                wreg_o = `WriteEnable;
                imm = {inst_i[31:12], {12{1'b0}}};
                instvalid = `InstValid;
            end
            // Below items have not been finished.
            `EXE_JAL: begin
                alusel_o = `SEL_JAL;
                wreg_o = `WriteEnable;
                imm = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
                instvalid = `InstValid;
            end
            `EXE_JALR: begin
                alusel_o = `SEL_JALR;
                wreg_o = `WriteEnable;
                reg1_read_o = 1'b1;
                imm = {{20{inst_i[31]}}, inst_i[31:20]};
            end
            `EXE_BEQ: begin
                alusel_o[4:3] = 2'b10;
                wreg_o = `WriteEnable;
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
                alusel_o[4:3] = 2'b10;
                alusel_o[2:0] = ~alusel_o[2:0];
                reg1_read_o = 1;
                reg2_read_o = 1;
                imm = {{20{inst_i[31]}} ,inst_i[31:25], inst_i[11:7]};
            end
            default: begin
                alusel_o = 0;
                instvalid = `False;
            end
            endcase
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            opr1_o = 0;
        end else if ((reg1_read_o == 1'b1) && (reg1_addr_o == 0)) begin
            opr1_o = 0;
        end else if ((reg1_read_o == 1'b1) && (reg1_addr_o == dataf_ex_wd) 
        && (dataf_ex_we == `WriteEnable)) begin
            opr1_o = dataf_ex_data;
        end else if ((reg1_read_o == 1'b1) && (reg1_addr_o == dataf_mem_wd) 
        && (dataf_mem_we == `WriteEnable)) begin
            opr1_o = dataf_mem_data;
        end else if (reg1_read_o == 1'b1) begin
            opr1_o = reg1_data_i;
        end else if (reg1_read_o == 1'b0) begin
            opr1_o = imm;
        end else begin
            opr1_o = 0; // why can the program go here?
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            opr2_o = 0;
        end else if ((reg2_read_o == 1'b1) && (reg2_addr_o == 0)) begin
            opr2_o = 0;
        end else if ((reg2_read_o == 1'b1) && (reg2_addr_o == dataf_ex_wd) 
        && (dataf_ex_we == `WriteEnable)) begin
            opr2_o = dataf_ex_data;
        end else if ((reg2_read_o == 1'b1) && (reg2_addr_o == dataf_mem_wd) 
        && (dataf_mem_we == `WriteEnable)) begin
            opr2_o = dataf_mem_data;
        end else if (reg2_read_o == 1'b1) begin
            opr2_o = reg2_data_i;
        end else if (reg2_read_o == 1'b0) begin
            opr2_o = imm;
        end else begin
            opr2_o = 0; // why can the program go here?
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            opr3_o = 0;
        end else if(reg1_read_o == 1'b0 && reg2_read_o == 1'b0) begin
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