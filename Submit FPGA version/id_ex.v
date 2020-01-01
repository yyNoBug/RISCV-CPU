`include "defines.v"

module id_ex(
    input wire clk,
    input wire rst,
    input wire branch_interception,
    input wire idex_stall,

    input wire id_stall,
    input wire[`AluSelBus] id_alusel,
    input wire[`RegBus] id_opr1,
    input wire[`RegBus] id_opr2,
    input wire[`ImmBus] id_opr3,
    input wire[`InstAddrBus] id_opr4,
    input wire[`RegAddrBus] id_wd,
    input wire id_wreg,
    input wire[`InstBus] id_inst,
    input wire id_br,

    output reg[`AluSelBus] ex_alusel,
    output reg[`RegBus] ex_opr1,
    output reg[`RegBus] ex_opr2,
    output reg[`ImmBus] ex_opr3,
    output reg[`InstAddrBus] ex_opr4,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg,
    output reg[`InstBus] ex_inst,
    output reg ex_br
);

    always @ (posedge clk) begin
        if (rst) begin
            ex_alusel <= 0;
            ex_opr1 <= 0;
            ex_opr2 <= 0;
            ex_opr3 <= 0;
            ex_opr4 <= 0;
            ex_wd <= 0;
            ex_wreg <= 0;
            ex_inst <= 0;
            ex_br <= 0;
        end else if (idex_stall) begin
        end else if (branch_interception) begin
            ex_alusel <= 0;
            ex_opr1 <= 0;
            ex_opr2 <= 0;
            ex_opr3 <= 0;
            ex_opr4 <= 0;
            ex_wd <= 0;
            ex_wreg <= 0;
            ex_inst <= 0;
            ex_br <= 0;
        end else if (id_stall) begin // may have logic problem about ID_stall here.
            ex_alusel <= 0;
            ex_opr1 <= 0;
            ex_opr2 <= 0;
            ex_opr3 <= 0;
            ex_opr4 <= 0;
            ex_wd <= 0;
            ex_wreg <= 0;
            ex_inst <= 0;
            ex_br <= 0;
        end else if (!idex_stall) begin
            ex_alusel <= id_alusel;
            ex_opr1 <= id_opr1;
            ex_opr2 <= id_opr2;
            ex_opr3 <= id_opr3;
            ex_opr4 <= id_opr4;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;
            ex_inst <= id_inst;
            ex_br <= id_br;
        end else begin
        end
    end
endmodule
