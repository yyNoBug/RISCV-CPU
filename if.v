`include "defines.v"

module iF(
    input wire rst,

    input wire[`InstAddrBus] pc_in, // from pc_reg
    //input wire[`InstAddrBus] npc_in,
    output wire[`InstAddrBus] pc_out, // to IF/ID
    //output reg[`InstAddrBus] npc_out, // to mem-control for more data
    output reg[`InstBus] inst_out,

    // interation with memcontrol
    input wire inst_avalible,
    input wire[`InstBus] inst_in,
    input wire[`InstAddrBus] pc_back,
    //output wire inst_needed,
    output reg[`InstAddrBus] pc_mem,

    output reg if_stall
);

    //inst_needed = `True;
    assign pc_out = pc_back;

    always @ (*) begin
        if (rst == `RstEnable) begin  // I changed chipenable here
            inst_out = 32'h0;
            pc_mem = 0;
            //npc_out = 0;
            //inst_needed = `False;
            if_stall = `False;
        end else begin
            if (inst_avalible == `True) begin
                //inst_needed = `False;
                #0.5 pc_mem = pc_in;  //I have noticed a bug here but I don't want to fix it now.
                //npc_out = npc_in;
                #0.5 inst_out = inst_in;
                #0.5 if_stall = `False;
            end else
                if_stall = `True;
        end
    end

endmodule