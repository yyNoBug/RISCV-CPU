`include "defines.v"

module ex(
    input wire rst,

    input wire[`AluOpBus] aluop_i,
    input wire[`AluFunBus] alufun_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i, //此段指令是否有写入的�?终寄存器

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o
);

    reg[`RegBus] logicout; //保存逻辑运算的结�?(??)

    always @ (*) begin
        if (rst == `RstEnable) begin
            logicout <= 0;
        end else begin
            case(aluop_i)
                `EXE_OR_OP: begin
                    logicout <= reg1_i | reg2_i;
                end
                default: begin
                    logicout <= 0;
                end
            endcase
        end
    end

    always @ (*) begin
        //why needn't judging rst
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        case (alufun_i)
            `EXE_RES_LOGIC: begin
                wdata_o <= logicout;
            end
            default: begin
                wdata_o <= 0;
            end
        endcase
    end

endmodule