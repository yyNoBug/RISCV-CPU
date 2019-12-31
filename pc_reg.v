`include "defines.v"

module pc_reg(
    input wire clk,
    input wire rst,

    input wire branch_interception,
    input wire[`InstAddrBus] npc,

    input wire br_prd,
    input wire[`InstAddrBus] npc_prd,

    input wire if_stall,
    output reg[`InstAddrBus] if_pc_i
);

    always @ (posedge clk) begin
        if (rst) begin
            if_pc_i <= 32'h00000000;
        end else if (branch_interception) begin
            if_pc_i <= npc;
        end else if (if_stall) begin
        end else if (br_prd) begin
            if_pc_i <= npc_prd;
        end else begin
            if_pc_i <= if_pc_i + 4'h4;
        end
    end

endmodule