`include "defines.v"

module ex(
    input wire rst,

    // For calculation.
    input wire[`AluSelBus] alusel_i,
    input wire[`RegBus] opr1_i,
    input wire[`RegBus] opr2_i,
    input wire[`ImmBus] opr3_i,
    input wire[`InstAddrBus] opr4_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i, //此段指令是否有写入的寄存器

    // For branch instructions.
    output reg branch_interception,
    output reg[`InstAddrBus] npc,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    // For mem stage.
    output reg[`MemAddrBus] memaddr_o,
    output reg memwr_o, // 0 for load, 1 for store.
    output reg[1:0] memcnf_o, // 0 for not using mem, 1 for B, 2 for H, 3 for W. 
    output reg memsigned_o, // 0 for unsigned, 1 for signed, only valid in load instructions.

    output reg ex_stall
);

    reg[`RegBus] logicout;

    always @ (*) begin
        if (rst == `RstEnable) begin
            branch_interception = 0;
            logicout = 0;
            memcnf_o = 0;
        end else begin
            branch_interception = 0;
            memcnf_o = 0;
            case(alusel_i)
            `SEL_OR: begin
                logicout = opr1_i | opr2_i;
            end
            `SEL_AND: begin
                logicout = opr1_i & opr2_i;
            end
            `SEL_XOR: begin
                logicout = opr1_i ^ opr2_i;
            end
            `SEL_ADD: begin
                logicout = opr1_i + opr2_i;
            end
            `SEL_SLT: begin
                if ($signed(opr1_i) < $signed(opr2_i)) 
                    logicout = opr1_i;
                else logicout = 0;
            end
            `SEL_SLTU: begin
                if (opr1_i < opr2_i) logicout <= opr1_i;
                else logicout = 0;
            end
            `SEL_SLL: begin
                logicout = opr1_i << opr2_i[4:0]; //may be wrong here
            end
            `SEL_SRL: begin
                if (opr2_i[10] == 1'b0)
                    logicout = opr1_i >>> opr2_i[4:0]; //may be wrong here
                else
                    logicout = $signed(opr1_i) >> opr2_i[4:0]; //may be wrong here
            end
            `SEL_LUI: begin
                logicout = opr1_i;
            end
            `SEL_AUIPC: begin
                logicout = opr1_i + opr2_i;
            end
            `SEL_JAL: begin
                logicout = opr4_i + 4;
                npc = opr1_i + opr4_i;
                branch_interception = `True;
            end
            `SEL_JALR: begin
                logicout = opr4_i + 4;
                npc = (opr1_i + opr2_i) & (-2); //not sure
                branch_interception = `True;
            end
            `SEL_BEQ: begin
                logicout = 0;
                if (opr1_i == opr2_i) begin
                    npc = opr3_i + opr4_i;
                    branch_interception = `True;
                end
            end
            `SEL_BNE: begin
                logicout = 0;
                if (opr1_i != opr2_i) begin
                    npc = opr3_i + opr4_i;
                    branch_interception = `True;
                end
            end
            `SEL_BLTU: begin
                logicout = 0;
                if (opr1_i < opr2_i) begin
                    npc = opr3_i + opr4_i;
                    branch_interception = `True;
                end
            end
            `SEL_BGEU: begin
                logicout = 0;
                if (opr1_i >= opr2_i) begin
                    npc = opr3_i + opr4_i;
                    branch_interception = `True;
                end
            end
            `SEL_BLT: begin
                logicout = 0;
                if ($signed(opr1_i) < $signed(opr2_i)) begin
                    npc = opr3_i + opr4_i;
                    branch_interception = `True;
                end
            end
            `SEL_BGE: begin
                logicout = 0;
                if ($signed(opr1_i) >= $signed(opr2_i)) begin
                    npc = opr3_i + opr4_i;
                    branch_interception = `True;
                end
            end
            `SEL_LB: begin // A problem to be solved: data-fowarding.
                memaddr_o = opr1_i + opr2_i;
                memwr_o = 0;
                memcnf_o = 2'b01;
                memsigned_o = 1;
            end
            `SEL_LH: begin // A problem to be solved: data-fowarding.
                memaddr_o = opr1_i + opr2_i;
                memwr_o = 0;
                memcnf_o = 2'b10;
                memsigned_o = 1;
            end
            `SEL_LW: begin // A problem to be solved: data-fowarding.
                memaddr_o = opr1_i + opr2_i;
                memwr_o = 0;
                memcnf_o = 2'b11;
                memsigned_o = 1;
            end
            `SEL_LBU: begin // A problem to be solved: data-fowarding.
                memaddr_o = opr1_i + opr2_i;
                memwr_o = 0;
                memcnf_o = 2'b01;
                memsigned_o = 0;
            end
            `SEL_LHU: begin // A problem to be solved: data-fowarding.
                memaddr_o = opr1_i + opr2_i;
                memwr_o = 0;
                memcnf_o = 2'b10;
                memsigned_o = 0;
            end
            `SEL_SB: begin
                logicout = opr2_i; // Note here: I'm just using the wire, but it does not go into reg.
                memaddr_o = opr1_i + opr3_i;
                memwr_o = 1;
                memcnf_o = 2'b01;
            end
            `SEL_SH: begin
                logicout = opr2_i; // Note here: I'm just using the wire, but it does not go into reg.
                memaddr_o = opr1_i + opr3_i;
                memwr_o = 1;
                memcnf_o = 2'b10;
            end
            `SEL_SW: begin
                logicout = opr2_i; // Note here: I'm just using the wire, but it does not go into reg.
                memaddr_o = opr1_i + opr3_i;
                memwr_o = 1;
                memcnf_o = 2'b11;
            end
            default: begin
                logicout = 0;
            end
            endcase
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            wd_o = 0;
            wreg_o = 0;
            wdata_o = 0;
            ex_stall = `False;
        end else begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = logicout;
            ex_stall = `False;
        end
    end

endmodule