`include "defines.v"

module iF(
    input wire rst,

    input wire[`InstAddrBus] pc_in, // from pc_reg
    output reg[`InstAddrBus] pc_out, // to IF/ID
    output reg[`InstBus] inst_out,

    //interaction with cache
    input wire inst_available,
    input wire[`InstBus] inst_c,
    output wire[`InstAddrBus] pc_c,

    output reg if_stall
    // if_stall is False has two meanings: 
    // 1. IF gets new addr, so PC-reg should calculate new addr. Please keep in mind what will happen at the beginning.
    // 2. IF throws an instruction out, so IF_ID should be set valid.
    // NOTE HERE: now the addr_needed and inst_out is tongbude.

    //input wire branch_interception
);

    // For correctness, if IF gives out a PC address before give out the last instruction, 
    // that PC address has to be correct (i.e. go to the right branch).

    assign pc_c = pc_in;

    always @ (*) begin
        if (rst) begin
            inst_out = 32'h0;
            pc_out = 0;
            if_stall = `False;
        end else if (inst_available == `True) begin
            inst_out = inst_c;
            pc_out = pc_in;
            if_stall = `False;
        end else begin
            inst_out = 32'h0;
            pc_out = 0;
            if_stall = `True;
        end
    end

endmodule