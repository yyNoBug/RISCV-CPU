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
    //output wire inst_needed,
    output reg[`InstAddrBus] pc_mem,

    output reg if_stall
);

    // For correctness, if IF gives out a PC address before give out the last instruction, 
    // that PC address has to be correct (i.e. go to the right branch).

    assign pc_out = pc_back;

    always @ (*) begin
        if (rst == `RstEnable) begin
            inst_out = 32'h0;
        end else begin
            if (inst_available == `True) begin
                inst_out = inst_in;
            end
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            pc_mem = 0;
            if_stall = `False;
        end else begin
            if_stall = `True;
            if (addr_needed) begin
                pc_mem = pc_in;
                if_stall = `False;
            end else
                if_stall = `True;
        end
    end

endmodule