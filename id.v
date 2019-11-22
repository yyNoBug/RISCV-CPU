`include "defines.v"

module id(
    input wire rst,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus] inst_i,

    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,

    output reg reg1_read_o, //Regfile模块第一个端口的读使能信�?
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,

    output reg[`AluOpBus] aluop_o,
    output reg[`AluFunBus] alufun_o,
    output reg[`RegBus] reg1_o,
    output reg[`RegBus] reg2_o,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o //译码阶段的指令是否有要写入的目的寄存�?
);

    wire[6:0] op = inst_i[6:0];
    //wire[4:0] op2 = inst_i[10:6];
    //wire[5:0] op3 = inst_i[5:0];
    //wire[4:0] op4 = inst_i[20:16];

    reg[`RegBus] imm;

    reg instvalid;

    always @ (*) begin
        if (rst == `RstEnable) begin
            reg1_read_o <= 0;
            reg2_read_o <= 0;
            reg1_addr_o <= 0;
            reg2_addr_o <= 0;

            aluop_o <= 0;
            alufun_o <= 0;
            wd_o <= 0;
            wreg_o <= 0;

            instvalid <= `InstInvalid;
            imm <= 0;
        end else begin
            aluop_o <= 0;
            alufun_o <= 0;
            wd_o <= inst_i[15:11]; //it's wrong!
            wreg_o <= 0;
            instvalid <= `InstValid;
            reg1_read_o <= 0;
            reg2_read_o <= 0;
            reg1_addr_o <= inst_i[25:21];
            reg2_addr_o <= inst_i[20:16];
            imm <= 0;
        
            case (op)
                `EXE_ORI: begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `EXE_OR_OP;
                    alufun_o <= `EXE_RES_LOGIC;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    imm <= {16'h0, inst_i[31:20]};
                    wd_o <= inst_i[11:7];
                    instvalid = `InstValid;
                end

                default: begin
                end
            endcase
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            reg1_o <= 0;
        end else if (reg1_read_o == 1'b1) begin
            reg1_o <= reg1_data_i;
        end else if (reg1_read_o == 1'b0) begin
            reg1_o <= imm; // I'm not sure whether RISC does it like that.
        end else begin
            reg1_o <= 0; // why can the program go here?
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            reg2_o <= 0;
        end else if (reg2_read_o == 1'b1) begin
            reg2_o <= reg2_data_i;
        end else if (reg2_read_o == 1'b0) begin
            reg2_o <= imm;
        end else begin
            reg2_o <= 0; // why can the program go here?
        end
    end

endmodule