`include "defines.v"

module mem(
    input wire rst,

    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`RegBus] wdata_i,

    input wire[`MemAddrBus] memaddr_i,
    input wire memwr_i, // 0 for load, 1 for store.
    input wire[1:0] memcnf_i, // 0 for not using mem, 1 for B, 2 for H, 3 for W. 
    input wire memsigned_i, // 0 for unsigned, 1 for signed, only valid in load instructions.

    input wire addr_needed,
    input wire mem_available,
    input wire[`InstBus] data_in,
    input wire[`InstAddrBus] pc_back,
    output reg[`InstAddrBus] addr_mem,
    output reg wr_mem,
    output reg[`MemDataBus] data_mem,
    output reg[1:0] conf_mem,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,
    output reg[1:0] memcnf_o,

    output reg mem_stall
);

    reg mem_working;

    always @ (*) begin
        if (rst) begin
            addr_mem = 0;
            wr_mem = 0;
            data_mem = 0;
            conf_mem = 0;
            mem_stall = 0;
        end else if (addr_needed && !memcnf_i) begin
            addr_mem = memaddr_i;
            data_mem = conf_mem;
            mem_stall = 0;
        end else if (mem_working) begin
            mem_stall = 1;
        end else begin
            mem_stall = 0;
        end
    end

    always @ (*) begin
        
        if (rst == `RstEnable) begin
            mem_working = 0;
        end else if (addr_needed && !memcnf_i) begin
            mem_working = 1;
        end

        if (rst == `RstEnable) begin
            wd_o = 0;
            wreg_o = 0;
            wdata_o = 0;
            memcnf_o = 0;

        end else if (mem_working && mem_available) begin
            mem_working = 0; //The items below are all wrong.
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = wdata_i;
            memcnf_o = memcnf_i;
            if (memwr_i == 0) begin //actually this should be memwr_o, items below are similar.
                wdata_o = data_in;
            end
            if (memsigned_i) begin
                case(memcnf_i)
                2'b01: begin
                    wdata_o = {{24{wdata_o[7]}}, wdata_o[7:0]};
                end
                2'b10: begin
                    wdata_o = {{12{wdata_o[11]}}, wdata_o[11:0]};
                end
                default: begin
                end
                endcase
            end
        end else if (mem_working) begin
            wd_o = 0;
            wreg_o = 0;
            wdata_o = 0;
        end else if (!mem_working && memcnf_i) begin
            wd_o = 0;
            wreg_o = 0;
            wdata_o = 0;
        end else if (!mem_working && !memcnf_i) begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = wdata_i;
        end
    end

/*
    always @ (*) begin
        if (rst == `RstEnable) begin
            wd_o = 0;
            wreg_o = 0;
            wdata_o = 0;
            mem_stall = `False;
        end else begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = wdata_i;
            mem_stall = `False;
        end
    end
*/  
endmodule