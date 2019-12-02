`include "defines.v"

module pc_reg(
    input wire clk,
    input wire rst,

    input wire branch_interception,
    input wire[`InstAddrBus] npc,

    input wire if_stall,
    output reg[`InstAddrBus] if_pc_i
);

    always @ (posedge clk) begin
        if (rst == `True) begin
            if_pc_i <= 32'h00000000;
        end else if (branch_interception) begin 
            if_pc_i <= npc; // May cause error, since it doesn't care whether if stalls.
        end else if (if_stall == `False) begin
            if_pc_i <= if_pc_i + 4'h4;
        end else begin
        end
    end

endmodule