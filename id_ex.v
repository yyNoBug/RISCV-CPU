`include "defines.v"

module id_ex(
    input wire clk,
    input wire rst,
    input wire ex_stall,

    input wire[`AluSelBus] id_alusel,
    input wire[`RegBus] id_opr1,
    input wire[`RegBus] id_opr2,
    input wire[`ImmBus] id_opr3,
    input wire[`InstAddrBus] id_opr4,
    input wire[`RegAddrBus] id_wd,
    input wire id_wreg,

    output reg[`AluSelBus] ex_alusel,
    output reg[`RegBus] ex_opr1,
    output reg[`RegBus] ex_opr2,
    output reg[`ImmBus] ex_opr3,
    output reg[`InstAddrBus] ex_opr4,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ex_alusel <= 0;
            ex_opr1 <= 0;
            ex_opr2 <= 0;
            ex_opr3 <= 0;
            ex_opr4 <= 0;
            ex_wd <= 0;
            ex_wreg <= 0;
        end else begin
            ex_alusel <= id_alusel;
            ex_opr1 <= id_opr1;
            ex_opr2 <= id_opr2;
            ex_opr3 <= id_opr3;
            ex_opr3 <= id_opr4;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;
        end
    end
endmodule
