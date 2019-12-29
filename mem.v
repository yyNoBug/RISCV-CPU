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

    // Interaction with dcache
    input wire[`InstBus] data_c,
    input wire data_available_c,
    output wire[`InstAddrBus] addr_c,
    output wire wr_c,
    output wire[`MemDataBus] data_write_c,
    output wire[1:0] memcnf_c,
    
    // Items to give out.
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    output reg mem_stall
);

    assign addr_c = memaddr_i;
    assign wr_c = memwr_i;
    assign memcnf_c = memcnf_i;
    assign data_write_c = wdata_i;

    always @ (*) begin
        if (rst) begin
            wd_o = 0;
            wreg_o = 0;
            wdata_o = 0;
            mem_stall = `True;
        end else if (!memcnf_i) begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = wdata_i;
            mem_stall = `False;
        end else if (data_available_c) begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = data_c;
            mem_stall = `False;
            if (memsigned_i) begin
                case(memcnf_i)
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
                case(memcnf_i)
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
        end else begin
            wd_o = 0;
            wreg_o = 0;
            wdata_o = 0;
            mem_stall = `True;
        end
    end

endmodule