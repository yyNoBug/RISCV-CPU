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
    input wire wreg_i, //此段指令是否有写入的寄存�?
    input wire[`InstBus] inst_i,
    input wire br_i,

    // For branch instructions.
    output reg isbranch,
    output reg jmp,
    output wire[`InstAddrBus] jmp_addr,
    output wire[`InstAddrBus] ex_pc,
    output reg branch_interception,
    output reg[`InstAddrBus] npc,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,
    output reg[`InstBus] inst_o,

    // For mem stage.
    output reg[`MemAddrBus] memaddr_o,
    output reg memwr_o, // 0 for load, 1 for store.
    output reg[1:0] memcnf_o, // 0 for not using mem, 1 for B, 2 for H, 3 for W. 
    output reg memsigned_o, // 0 for unsigned, 1 for signed, only valid in load instructions.

    output reg ex_stall
);

    assign ex_pc = opr4_i;
    assign jmp_addr = opr3_i + opr4_i;

    reg[`RegBus] logicout;

    always @ (*) begin
        if (rst == `RstEnable) begin
            branch_interception = 0;
            npc = 0;
            logicout = 0;
            memaddr_o = 0;
            memwr_o = 0;
            memcnf_o = 0;
            memsigned_o = 0;
            inst_o = 0;
            jmp = 0;
            isbranch = 0;
        end else begin
            branch_interception = 0;
            npc = 0;
            logicout = 0;
            memaddr_o = 0;
            memwr_o = 0;
            memcnf_o = 0;
            memsigned_o = 0;
            jmp = 0;
            isbranch = 0;
            inst_o = inst_i;
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
                if (opr3_i[10] == 0) logicout = opr1_i + opr2_i;
                else logicout = opr1_i - opr2_i;
            end
            `SEL_SLT: begin
                if ($signed(opr1_i) < $signed(opr2_i)) 
                    logicout = opr1_i;
                else logicout = 0;
            end
            `SEL_SLTU: begin
                if (opr1_i < opr2_i) logicout = opr1_i;
                else logicout = 0;
            end
            `SEL_SLL: begin
                logicout = opr1_i << opr2_i[4:0];
            end
            `SEL_SRL: begin
                if (opr2_i[10] == 1'b0)
                    logicout = opr1_i >> opr2_i[4:0];
                else
                    logicout = $signed(opr1_i) >>> opr2_i[4:0];
            end
            `SEL_LUI: begin
                logicout = opr1_i;
            end
            `SEL_AUIPC: begin
                logicout = opr1_i + opr4_i;
            end
            `SEL_JAL: begin
                logicout = opr4_i + 4;
                npc = opr1_i + opr4_i;
                branch_interception = `True;
            end
            `SEL_JALR: begin
                logicout = opr4_i + 4;
                npc = (opr1_i + opr2_i) & (-2);
                branch_interception = `True;
            end
            `SEL_BEQ: begin
                isbranch = 1;
                logicout = 0;
                if (opr1_i == opr2_i) begin
                    npc = opr3_i + opr4_i;
                    branch_interception = !br_i;
                    jmp = 1;
                end else begin
                    branch_interception = br_i;
                    npc = opr4_i + 4;
                end
            end
            `SEL_BNE: begin
                isbranch = 1;
                logicout = 0;
                if (opr1_i != opr2_i) begin
                    npc = opr3_i + opr4_i;
                    branch_interception = !br_i;
                    jmp = 1;
                end else begin
                    branch_interception = br_i;
                    npc = opr4_i + 4;
                end
            end
            `SEL_BLTU: begin
                isbranch = 1;
                logicout = 0;
                if (opr1_i < opr2_i) begin
                    npc = opr3_i + opr4_i;
                    branch_interception = !br_i;
                    jmp = 1;
                end else begin
                    branch_interception = br_i;
                    npc = opr4_i + 4;
                end
            end
            `SEL_BGEU: begin
                isbranch = 1;
                logicout = 0;
                if (opr1_i >= opr2_i) begin
                    npc = opr3_i + opr4_i;
                    branch_interception = !br_i;
                    jmp = 1;
                end else begin
                    branch_interception = br_i;
                    npc = opr4_i + 4;
                end
            end
            `SEL_BLT: begin
                isbranch = 1;
                logicout = 0;
                if ($signed(opr1_i) < $signed(opr2_i)) begin
                    npc = opr3_i + opr4_i;
                    branch_interception = !br_i;
                    jmp = 1;
                end else begin
                    branch_interception = br_i;
                    npc = opr4_i + 4;
                end
            end
            `SEL_BGE: begin
                isbranch = 1;
                logicout = 0;
                if ($signed(opr1_i) >= $signed(opr2_i)) begin
                    npc = opr3_i + opr4_i;
                    branch_interception = !br_i;
                    jmp = 1;
                end else begin
                    branch_interception = br_i;
                    npc = opr4_i + 4;
                end
            end
            `SEL_LB: begin
                memaddr_o = opr1_i + opr2_i;
                memwr_o = 0;
                memcnf_o = 2'b01;
                memsigned_o = 1;
            end
            `SEL_LH: begin
                memaddr_o = opr1_i + opr2_i;
                memwr_o = 0;
                memcnf_o = 2'b10;
                memsigned_o = 1;
            end
            `SEL_LW: begin
                memaddr_o = opr1_i + opr2_i;
                memwr_o = 0;
                memcnf_o = 2'b11;
                memsigned_o = 1;
            end
            `SEL_LBU: begin
                memaddr_o = opr1_i + opr2_i;
                memwr_o = 0;
                memcnf_o = 2'b01;
                memsigned_o = 0;
            end
            `SEL_LHU: begin
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