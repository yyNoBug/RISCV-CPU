`include "defines.v"

module ex(
    input wire rst,

    // For calculation.
    input wire[`AluOpBus] aluop_i,
    input wire[`AluFunBus] alufun_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i, //此段指令是否有写入的�?终寄存器
    input wire[`ImmBus] imm_i,
    input wire[`InstAddrBus] pc_i,

    // For data-fowarding.
    input wire reg1_re,
    input wire[`RegAddrBus] reg1_i_addr,
    input wire reg2_re,
    input wire[`RegAddrBus] reg2_i_addr,
    input wire dataf_exmem_we, //If there isn't any error here, I'm somehow confident that data-fowarding will work properly.
    input wire[`RegAddrBus] dataf_exmem_wd,
    input wire[`RegBus] dataf_exmem_data,
    input wire dataf_memwb_we,
    input wire[`RegAddrBus] dataf_memwb_wd,
    input wire[`RegBus] dataf_memwb_data,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    output reg ex_stall
);

    reg[`RegBus] logicout;
    
    wire[`RegBus] reg1;
    assign reg1 = ((reg1_i_addr == dataf_exmem_wd) &&  (dataf_exmem_we == `WriteEnable)
        && reg1_re == `ReadEnable) ? dataf_exmem_data : (((reg1_i_addr == dataf_memwb_wd)
        &&  (dataf_memwb_we == `WriteEnable) && reg1_re == `ReadEnable) ? dataf_memwb_data : reg1_i);
    
    wire[`RegBus] reg2;
    assign reg2 = ((reg2_i_addr == dataf_exmem_wd) &&  (dataf_exmem_we == `WriteEnable)
        && reg2_re == `ReadEnable) ? dataf_exmem_data : (((reg2_i_addr == dataf_memwb_wd)
        &&  (dataf_memwb_we == `WriteEnable) && reg2_re == `ReadEnable) ? dataf_memwb_data : reg2_i);

    always @ (*) begin
        if (rst == `RstEnable) begin
            logicout = 0;
        end else begin
            case(aluop_i)
            `EXE_ORI: begin
                case(alufun_i)
                `FUN_ORI: begin
                    logicout = reg1 | imm_i;
                end
                `FUN_ANDI: begin
                    logicout = reg1 & imm_i;
                end
                `FUN_XORI: begin
                    logicout = reg1 ^ imm_i;
                end
                `FUN_ADDI: begin
                    logicout = reg1 + imm_i;
                end
                `FUN_SLTI: begin
                    if ($signed(reg1) < $signed(imm_i)) 
                        logicout = reg1;
                    else logicout = 0;
                end
                `FUN_SLTIU: begin
                    if (reg1 < imm_i) logicout <= reg1;
                    else logicout = 0;
                end
                `FUN_SLLI: begin
                    logicout = reg1 << imm_i[4:0]; //may be wrong here
                end
                `FUN_SRLI: begin
                    if (imm_i[10] == 1'b0)
                        logicout = reg1 >>> imm_i[4:0]; //may be wrong here
                    else
                        logicout = reg1 >> imm_i[4:0]; //may be wrong here
                end
                default: begin
                    logicout = 0;
                end
                endcase
            end
            `EXE_OR: begin
                case(alufun_i)
                `FUN_ADD: begin
                    if (imm_i[10] == 1'b0)
                        logicout = reg1 + reg2;
                    else
                        logicout = reg1 - reg2;
                end
                `FUN_SLL: begin
                    logicout = reg1 << reg2[4:0];
                end
                `FUN_SRL: begin
                    if (imm_i[10] == 1'b0)
                        logicout = reg1 >>> reg2[4:0]; 
                    else
                        logicout = reg1 >> reg2[4:0];
                end
                `FUN_SLT: begin
                    if ($signed(reg1) < $signed(reg2)) 
                        logicout = reg1;
                    else
                        logicout = 0;
                end
                `FUN_SLTU: begin
                    if (reg1 < reg2) logicout = reg1;
                    else logicout = 0;
                end
                `FUN_OR: begin
                    logicout = reg1 | reg2;
                end
                `FUN_AND: begin
                    logicout = reg1 & reg2;
                end
                `FUN_XOR: begin
                    logicout = reg1 ^ reg2;
                end
                endcase
            end
            `EXE_LUI: begin
                logicout = imm_i;
            end
            `EXE_AUIPC: begin
                logicout = pc_i + imm_i;
            end
            default: begin
            end
            endcase
        end
    end

    always @ (*) begin
        wd_o = wd_i;
        wreg_o = wreg_i;
        ex_stall = `False;
        case (aluop_i)
            `EXE_ORI: begin
                wdata_o = logicout;
            end
            default: begin
                wdata_o = 0;
            end
        endcase
    end

endmodule