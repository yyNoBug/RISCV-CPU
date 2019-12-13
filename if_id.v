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

    reg[`InstBus] buffer_inst; // It's ugly. I like it.
    reg[`InstAddrBus] buffer_pc;

    always @ (posedge clk) begin
        if (rst || branch_interception) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else if (!ifid_stall) begin
            if (buffer_inst) begin
                if (if_inst != buffer_inst) $display("Huge error in if_id.");
                id_pc <= buffer_pc;
                id_inst <= buffer_inst;
                buffer_pc <= 0;
                buffer_inst <= 0;
            end else begin
                id_pc <= if_pc;
                id_inst <= if_inst;
            end
            if (id_inst != 0) $display("%h %h", id_pc, id_inst);
        end else if (ifid_stall) begin
            if (if_inst != 0) begin 
                //$display("Inst Missing in IFID!."); // I want to delete it.
                buffer_inst = if_inst;
                buffer_pc = if_pc;
            end
        end
    end
    
endmodule