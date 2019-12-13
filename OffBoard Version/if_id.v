`include "defines.v"

module if_id(
    input wire clk,
    input wire rst,
    input wire branch_interception,
    input wire ifid_stall,
    input wire[`InstAddrBus] if_pc,
    input wire[`InstBus] if_inst,
    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus] id_inst
);

    always @ (posedge clk) begin
        if (rst || branch_interception) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else if (!ifid_stall) begin
            //if (if_inst != 0) $display("%h %h", if_pc, if_inst);
            id_pc <= if_pc;
            id_inst <= if_inst;
        end else if (ifid_stall) begin
            if (if_inst != 0) $display("Inst Missing in IFID!.");
        end
    end
    
endmodule