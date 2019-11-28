`include "defines.v"

module iF(
    input wire rst,

    input wire[`InstAddrBus] pc_in, // from pc_reg
    //input wire[`InstAddrBus] npc_in,
    output wire[`InstAddrBus] pc_out, // to IF/ID
    //output reg[`InstAddrBus] npc_out, // to mem-control for more data
    output reg[`InstBus] inst_out,

    // interation with memcontrol
    input wire inst_almost_available,
    input wire inst_available,
    input wire[`InstBus] inst_in,
    input wire[`InstAddrBus] pc_back,
    //output wire inst_needed,
    output reg[`InstAddrBus] pc_mem,

    output reg if_stall
);

    //inst_needed = `True;
    assign pc_out = pc_back;

    always @ (*) begin
        if (rst == `RstEnable) begin
            inst_out = 32'h0;
            pc_mem = 0;
            if_stall = `False;
        end else begin
            if (inst_available == `True) begin
                inst_out = inst_in;
                if_stall = `True;
            end else if (inst_almost_available) begin
                pc_mem = pc_in;
                if_stall = `False;
            end else
                if_stall = `True;
        end
    end

endmodule