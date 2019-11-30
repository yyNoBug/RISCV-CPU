`include "defines.v"

module pc_reg(
    input wire clk,
    input wire rst,
    input wire if_stall,
    output reg[`InstAddrBus] if_pc_i
    //output reg[`InstAddrBus] if_npc_i
    //output reg ce
);

    always @ (posedge clk) begin
        if (rst == `True) begin
            if_pc_i <= 32'h00000000;
        end else if (if_stall == `False) begin
            if_pc_i <= if_pc_i + 4'h4;
        end else begin
        end
    end

endmodule