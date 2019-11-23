`include "defines.v"

module id_ex(
    input wire clk,
    input wire rst,

    input wire[`AluOpBus] id_aluop,
    input wire[`AluFunBus] id_alufun,
    input wire[`RegBus] id_reg1,
    input wire[`RegBus] id_reg2,
    input wire[`RegAddrBus] id_wd,
    input wire id_wreg,
    input wire[`ImmBus] id_imm,

    output reg[`AluOpBus] ex_aluop,
    output reg[`AluFunBus] ex_alufun,
    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg,
    output reg[`ImmBus] ex_imm
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ex_aluop <= 0;
            ex_alufun <= 0;
            ex_reg1 <= 0;
            ex_reg2 <= 0;
            ex_wd <= 0;
            ex_wreg <= 0;
            ex_imm <= 0;
        end else begin
            ex_aluop <= id_aluop;
            ex_alufun <= id_alufun;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;
            ex_imm <= id_imm;
        end
    end
endmodule
