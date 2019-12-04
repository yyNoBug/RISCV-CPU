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

    // Interaction with mem-ctrl.
    input wire addr_needed,
    input wire mem_available,
    input wire mem_working,
    input wire[`InstBus] data_in,
    output reg[`InstAddrBus] addr_mem,
    output reg wr_mem,
    output reg[`MemDataBus] data_mem,
    output reg[1:0] cnf_mem,

    // Items to give out.
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,
    output reg[1:0] memcnf_o,

    output reg mem_stall
);

    reg[`RegAddrBus] wd_mem;
    reg wreg_mem;
    reg signed_mem;

    always @ (*) begin
        if (rst == `RstEnable) begin
            wd_o = 0;
            wreg_o = 0;
            wdata_o = 0;
            memcnf_o = 0;
        end else if (mem_working) begin // For correctness, maybe NOP should be given out.
        end else if (mem_available) begin
            // Note here: Please make sure the items below will not be refreshed by almost_available signal.
            // Warning: Please make sure the following things will work properly even if blocked.
            wd_o = wd_mem;
            wreg_o = wreg_mem;
            wdata_o = data_mem;
            memcnf_o = cnf_mem;
            if (wr_mem == 0) begin
                wdata_o = data_in;
            end
            if (signed_mem) begin
                case(cnf_mem)
                2'b01: begin
                    wdata_o = {{24{wdata_o[7]}}, wdata_o[7:0]};
                end
                2'b10: begin
                    wdata_o = {{12{wdata_o[11]}}, wdata_o[11:0]};
                end
                default: begin
                end
                endcase
            end else begin
                case(cnf_mem)
                2'b01: begin
                    wdata_o = {{24{1'b0}}, wdata_o[7:0]};
                end
                2'b10: begin
                    wdata_o = {{12{1'b0}}, wdata_o[11:0]};
                end
                default: begin
                end
                endcase
            end
        end else if (!mem_working && !memcnf_i) begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = wdata_i;
            memcnf_o = 0;
        end else if (!mem_working && memcnf_i) begin
        end

        // Interaction with mem-control.
        if (rst) begin
            addr_mem = 0;
            wr_mem = 0;
            data_mem = 0;
            cnf_mem = 0;
            wd_mem = 0;
            wreg_mem = 0;
            mem_stall = 0;
        end else if (mem_working) begin
            mem_stall = 1;
        end else if (addr_needed && memcnf_i) begin // Warning: if 2 mem instructions block, mem will run forever!
            addr_mem = memaddr_i;
            wr_mem = memwr_i;
            data_mem = wdata_i;
            cnf_mem = memcnf_i;
            wd_mem = wd_i;
            wreg_mem = wreg_i;
            signed_mem = memsigned_i;
            mem_stall = 0;
        end else if (memcnf_i) begin
            mem_stall = 1;
        end else begin
            cnf_mem = 0;
            mem_stall = 0;
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