`include "defines.v"

module data_cache(
    input wire clk,
    input wire rst,
    
    //Interaction with MEM
    input wire[`InstAddrBus] addr_i,
    input wire wr_i,
    input wire[`MemDataBus] data_write_i,
    input wire[1:0] memcnf_i,
    output reg[`InstBus] data_o,
    output reg data_available_o,

    //Interaction with mem-control
    input wire data_available_i,
    input wire[`InstBus] data_i,
    input wire addr_needed,
    output reg data_needed,
    output wire[`InstAddrBus] addr_o,
    output wire[`MemDataBus] data_write_o,
    output wire wr_o,
    output wire[1:0] memcnf_o
);

    wire[`dIndexBus] index;
    wire[`dOffsetBus] offset;

    assign addr_o = addr_i;
    assign data_write_o = data_write_i;
    assign wr_o = wr_i;
    assign memcnf_o = memcnf_i;

    assign index = addr_i[`dAddrIndexBus];
    assign offset = addr_i[`dAddrOffsetBus];

    reg[`dCacheBus] cache[0 : `dCacheLine - 1];
    
    always @ (*) begin
        if (rst) begin
            data_o = 0;
        end else begin
            /*case(offset)
            2'b00:
                data_o = cache[index][31:0];
            2'b01:
                data_o = cache[index][31:8];
            2'b10:
                data_o = cache[index][31:16];
            2'b11:
                data_o = cache[index][31:24];
            endcase*/
            data_o = cache[index][`dCacheDataBus];
        end
    end

    always @ (*) begin
        if (rst) begin
            data_needed = 0;
            data_available_o = 0;
        end else if (!memcnf_i) begin // Non-mem instruction.
            data_needed = 0;
            data_available_o = 0;
        end else if (addr_i[`dAddrTagBus] != cache[index][`dCacheTagBus]) begin // miss
            data_needed = 1;
            data_available_o = 0;
        end else if (!wr_i && memcnf_i) begin // Read and hit.
            data_needed = 0;
            data_available_o = 1;
        end else if (memcnf_i == 2'b01 && cache[index][7:0] === data_write_i[7:0]) begin // Write hit and written.
            data_needed = 0;
            data_available_o = 1;
        end else if (memcnf_i == 2'b10 && cache[index][15:0] === data_write_i[15:0]) begin // Write hit and written.
            data_needed = 0;
            data_available_o = 1;
        end else if (memcnf_i == 2'b11 && cache[index][31:0] === data_write_i) begin // Write hit and written.
            data_needed = 0;
            data_available_o = 1;
        end else begin // Write hit but unwritten.
            data_needed = 1;
            data_available_o = 0;
        end
    end

    reg [10:0] i;
    always @ (posedge clk) begin
        if (rst) begin
            for (i = 0; i < `dCacheLine; i = i + 1) begin
                cache[i][`dCacheTagFirstBit] <= 1;
            end
        end else if (wr_i && addr_needed) begin
            cache[index][`dCacheDataBus] <= data_write_i;
            cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
        end else if (data_available_i) begin
            cache[index][`dCacheDataBus] <= data_i;
            cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
        end
    end

endmodule