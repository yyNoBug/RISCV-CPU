`include "defines.v"

module iF(
    input wire rst,

    input wire[`InstAddrBus] pc_in, // from pc_reg
    output wire[`InstAddrBus] pc_out, // to IF/ID
    output reg[`InstBus] inst_out,

    // interation with memcontrol
    input wire addr_needed,
    input wire inst_available,
    input wire[`InstBus] inst_in,
    input wire[`InstAddrBus] pc_back,
    output reg[`InstAddrBus] pc_mem,

    output reg if_stall, 
    // if_stall is False has two meanings: 
    // 1. IF gets new addr, so PC-reg should calculate new addr. Please keep in mind what will happen at the beginning.
    // 2. IF throws an instruction out, so IF_ID should be set valid.
    // NOTE HERE: now the addr_needed and inst_out is tongbude.

    input wire branch_interception,
    input wire[1:0] memcnf,
    input wire ifid_stall // for debug use
);

    // For correctness, if IF gives out a PC address before give out the last instruction, 
    // that PC address has to be correct (i.e. go to the right branch).

    assign pc_out = pc_back;

    always @ (*) begin
        if (rst || branch_interception) begin
            inst_out = 32'h0;
        end else if (inst_available == `True) begin
            inst_out = inst_in;
            if (inst_out == 32'h00e78023) $display("What a coincidence!");
            if (ifid_stall) $display("IF inst_out MISSING!");
        end else begin
            inst_out = 32'h0; // BUG here: some instructions may miss.
        end
    end

    always @ (*) begin
        if (rst || branch_interception) begin
            pc_mem = 0;
            if_stall = `False;
        end else if (addr_needed && !memcnf) begin // BUG here: if something else blocked PC, instructions will run more than once.
            pc_mem = pc_in;
            if_stall = `False;
        end else begin
            if_stall = `True;
        end
    end

endmodule