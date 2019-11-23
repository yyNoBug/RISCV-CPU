`include "defines.v"

module ex(
    input wire rst,

    input wire[`AluOpBus] aluop_i,
    input wire[`AluFunBus] alufun_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i, //此段指令是否有写入的�???终寄存器
    input wire[`ImmBus] imm_i,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o
);

    reg[`RegBus] logicout; //保存逻辑运算的结�???(??)

    always @ (*) begin
        if (rst == `RstEnable) begin
            logicout <= 0;
        end else begin
            case(aluop_i)
            `EXE_ORI: begin
                case(alufun_i)
                `FUN_ORI: begin
                    logicout <= reg1_i | imm_i;
                end
                `FUN_ANDI: begin
                    logicout <= reg1_i & imm_i;
                end
                `FUN_XORI: begin
                    logicout <= reg1_i ^ imm_i;
                end
                `FUN_ADDI: begin
                    logicout <= reg1_i + imm_i;
                end
                `FUN_SLTI: begin
                    if ($signed(reg1_i) < $signed(imm_i)) 
                        logicout <= reg1_i;
                    else logicout <= 0;
                end
                `FUN_SLTIU: begin
                    if (reg1_i < imm_i) logicout <= reg1_i;
                    else logicout <= 0;
                end
                `FUN_SLLI: begin
                    logicout <= reg1_i << imm_i[4:0]; //may be wrong here
                end
                `FUN_SRLI: begin
                    if (imm_i[10] == 1'b0)
                        logicout <= reg1_i >>> imm_i[4:0]; //may be wrong here
                    else
                        logicout <= reg1_i >> imm_i[4:0]; //may be wrong here
                end
                default: begin
                    logicout <= 0;
                end
                endcase
            end
            `EXE_OR: begin
                case(alufun_i)
                `FUN_ADD: begin
                    if (imm_i[10] == 1'b0)
                        logicout <= reg1_i + reg2_i;
                    else
                        logicout <= reg1_i - reg2_i;
                end
                `FUN_SLL: begin
                    logicout <= reg1_i << reg2_i[4:0];
                end
                `FUN_SRL: begin
                    if (imm_i[10] == 1'b0)
                        logicout <= reg1_i >>> reg2_i[4:0]; 
                    else
                        logicout <= reg1_i >> reg2_i[4:0];
                end
                `FUN_SLT: begin
                    if ($signed(reg1_i) < $signed(reg2_i)) 
                        logicout <= reg1_i;
                    else
                        logicout <= 0;
                end
                `FUN_SLTU: begin
                    if (reg1_i < reg2_i) logicout <= reg1_i;
                    else logicout <= 0;
                end
                `FUN_OR: begin
                    logicout <= reg1_i | reg2_i;
                end
                `FUN_AND: begin
                    logicout <= reg1_i & reg2_i;
                end
                `FUN_XOR: begin
                    logicout <= reg1_i ^ reg2_i;
                end
                endcase
            end
            default: begin
            end
            endcase
        end
    end

    always @ (*) begin
        //why needn't judging rst
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        case (aluop_i)
            `EXE_ORI: begin
                wdata_o <= logicout;
            end
            default: begin
                wdata_o <= 0;
            end
        endcase
    end

endmodule