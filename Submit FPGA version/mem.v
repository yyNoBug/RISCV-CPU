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
    input wire[`InstBus] inst_i,

    // Interaction with mem-ctrl.
    input wire addr_needed,
    input wire mem_available,
    input wire mem_working,
    input wire[`InstBus] data_in,
    output reg[`InstAddrBus] addr_mem,
    output reg wr_mem,
    output reg[`MemDataBus] data_mem,
    output reg[1:0] cnf_mem,

    input wire[`RegAddrBus] wd_back,
    input wire wreg_back,
    input wire signed_back,
    input wire[1:0] cnf_back,
    output reg[`RegAddrBus] wd_mem,
    output reg wreg_mem,
    output reg signed_mem,

    // Items to give out.
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    output reg mem_stall
);


    // Warning: mem may run extremely slow.
    always @ (*) begin
        if (rst) begin
            wd_o = 0;
            wreg_o = 0;
            wdata_o = 0;
        end else if (mem_working) begin
            wd_o = 0;
            wreg_o = 0;
            wdata_o = 0;
        end else if (mem_available) begin
            // Note here: Please make sure the items below will not be refreshed by almost_available signal.
            // Warning: Please make sure the following things will work properly even if blocked.
            wd_o = wd_back;
            wreg_o = wreg_back;
            //wdata_o = data_mem;
            /*if (wr_mem == 0) begin
                wdata_o = data_in;
            end*/
            wdata_o = data_in;

            if (signed_back) begin
                case(cnf_back)
                2'b01: begin
                    wdata_o = {{24{wdata_o[7]}}, wdata_o[7:0]};
                end
                2'b10: begin
                    wdata_o = {{16{wdata_o[15]}}, wdata_o[15:0]};
                end
                default: begin
                end
                endcase
            end else begin
                case(cnf_back)
                2'b01: begin
                    wdata_o = {{24{1'b0}}, wdata_o[7:0]};
                end
                2'b10: begin
                    wdata_o = {{16{1'b0}}, wdata_o[15:0]};
                end
                default: begin
                end
                endcase
            end

        end else if (!memcnf_i) begin // Nothing left in memctrl and new inst is non-mem-operation.
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = wdata_i;
        end else begin // Nothing left in memctrl and new inst is mem-opration.
            wd_o = 0;
            wreg_o = 0;
            wdata_o = 0;
        end
    end

    always @ (*) begin
        // Interaction with mem-control.
        if (rst) begin
            mem_stall = 0;
            addr_mem = 0;
            wr_mem = 0;
            data_mem = 0;
            cnf_mem = 0;
            wd_mem = 0;
            wreg_mem = 0;
            signed_mem = 0;
        end else if (mem_working) begin
            mem_stall = 1;
            addr_mem = 0; // Correctness unsure.
            wr_mem = 0;
            data_mem = 0;
            cnf_mem = 0;
            wd_mem = 0;
            wreg_mem = 0;
            signed_mem = 0;
        end else if (addr_needed && memcnf_i) begin
            mem_stall = 0;
            addr_mem = memaddr_i;
            wr_mem = memwr_i;
            data_mem = wdata_i;
            cnf_mem = memcnf_i;
            wd_mem = wd_i;
            wreg_mem = wreg_i;
            signed_mem = memsigned_i;
        end else if (memcnf_i) begin
            mem_stall = 1;
            addr_mem = 0; // Correctness unsure.
            wr_mem = 0;
            data_mem = 0;
            cnf_mem = 0;
            wd_mem = 0;
            wreg_mem = 0;
            signed_mem = 0;
        end else if (mem_available && !memcnf_i) begin
            mem_stall = 1;
            addr_mem = 0;
            wr_mem = 0;
            data_mem = 0;
            cnf_mem = 0;
            wd_mem = 0;
            wreg_mem = 0;
            signed_mem = 0;
        end else begin
            mem_stall = 0;
            addr_mem = 0;
            wr_mem = 0;
            data_mem = 0;
            cnf_mem = 0;
            wd_mem = 0;
            wreg_mem = 0;
            signed_mem = 0;
        end
    end

endmodule