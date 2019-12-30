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
    reg[3:0] valid[0: `dCacheLine - 1];
    
    always @ (*) begin
        if (rst) begin
            data_o = 0;
        end else begin
            case(offset)
            2'b00:
                data_o = cache[index][31:0];
            2'b01:
                data_o = cache[index][31:8];
            2'b10:
                data_o = cache[index][31:16];
            2'b11:
                data_o = cache[index][31:24];
            endcase
            //data_o = cache[index][`dCacheDataBus];
        end
    end

    always @ (*) begin
        if (rst) begin
            data_needed = 0;
            data_available_o = 0;
        end else if (!memcnf_i) begin // Non-mem instruction.
            data_needed = 0;
            data_available_o = 0;
        end else if ((addr_i == 32'h30000 || addr_i == 32'h30004) && wr_i && addr_needed) begin
            data_available_o = 1;
            data_needed = 1;
        end else if ((addr_i == 32'h30000 || addr_i == 32'h30004) && wr_i && !addr_needed) begin
            data_available_o = 0;
            data_needed = 1;
        end else if (addr_i[`dAddrTagBus] != cache[index][`dCacheTagBus]) begin // miss
            data_needed = 1;
            data_available_o = 0;
        end else if (!wr_i && memcnf_i == 2'b01 && ((offset == 2'b00 && valid[index][0])
                                                 || (offset == 2'b01 && valid[index][1])
                                                 || (offset == 2'b10 && valid[index][2])
                                                 || (offset == 2'b11 && valid[index][3]))) begin // Read and hit.
            data_needed = 0;
            data_available_o = 1;
        end else if (!wr_i && memcnf_i == 2'b10 && ((offset == 2'b00 && &valid[index][1:0])
                                                 || (offset == 2'b10 && &valid[index][3:2]))) begin // Read and hit.
            data_needed = 0;
            data_available_o = 1;
        end else if (!wr_i && memcnf_i == 2'b11 && offset == 2'b00 && &valid[index][3:0]) begin // Read and hit.
            data_needed = 0;
            data_available_o = 1;
        end else if (!wr_i) begin // Read and hit but not valid.
            data_needed = 1;
            data_available_o = 0;
        end else if (memcnf_i == 2'b01 && ((offset == 2'b00 && cache[index][7:0] === data_write_i[7:0])
                                        || (offset == 2'b01 && cache[index][15:8] === data_write_i[7:0])
                                        || (offset == 2'b10 && cache[index][23:16] === data_write_i[7:0])
                                        || (offset == 2'b11 && cache[index][31:24] === data_write_i[7:0]))) begin // Write hit and written.
            data_needed = 0;
            data_available_o = 1;
        end else if (memcnf_i == 2'b10 && ((offset == 2'b00 && cache[index][15:0] === data_write_i[15:0])
                                        || (offset == 2'b10 && cache[index][31:16] === data_write_i[15:0]))) begin // Write hit and written.
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
        end else if (wr_i && (addr_i == 32'h30000 || addr_i == 32'h30004)) begin
        end else if (wr_i && addr_needed) begin
            if (memcnf_i == 2'b01 && offset == 2'b00) begin
                cache[index][7:0] <= data_write_i[7:0];
                if (cache[index][`dCacheTagBus] == addr_i[`dAddrTagBus]) begin
                    valid[index] <= valid[index] | 4'b0001;
                end else begin
                    cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                    valid[index] <= 4'b0001;
                end
            end else if (memcnf_i == 2'b01 && offset == 2'b01) begin
                cache[index][15:8] <= data_write_i[7:0];
                if (cache[index][`dCacheTagBus] == addr_i[`dAddrTagBus]) begin
                    valid[index] <= valid[index] | 4'b0010;
                end else begin
                    cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                    valid[index] <= 4'b0010;
                end
            end else if (memcnf_i == 2'b01 && offset == 2'b10) begin
                cache[index][23:16] <= data_write_i[7:0];
                if (cache[index][`dCacheTagBus] == addr_i[`dAddrTagBus]) begin
                    valid[index] <= valid[index] | 4'b0100;
                end else begin
                    cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                    valid[index] <= 4'b0100;
                end
            end else if (memcnf_i == 2'b01 && offset == 2'b11) begin
                cache[index][31:24] <= data_write_i[7:0];
                if (cache[index][`dCacheTagBus] == addr_i[`dAddrTagBus]) begin
                    valid[index] <= valid[index] | 4'b1000;
                end else begin
                    cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                    valid[index] <= 4'b1000;
                end
            end else if (memcnf_i == 2'b10 && offset == 2'b00) begin
                cache[index][15:0] <= data_write_i[15:0];
                if (cache[index][`dCacheTagBus] == addr_i[`dAddrTagBus]) begin
                    valid[index] <= valid[index] | 4'b0011;
                end else begin
                    cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                    valid[index] <= 4'b0011;
                end
            end else if (memcnf_i == 2'b10 && offset == 2'b10) begin
                cache[index][31:16] <= data_write_i[15:0];
                if (cache[index][`dCacheTagBus] == addr_i[`dAddrTagBus]) begin
                    valid[index] <= valid[index] | 4'b1100;
                end else begin
                    cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                    valid[index] <= 4'b1100;
                end
            end else if (memcnf_i == 2'b11 && offset == 2'b00) begin
                cache[index][`dCacheDataBus] <= data_write_i;
                cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                valid[index] <= 4'b1111;
            end
        end else if (data_available_i) begin //BUG here: written data will come back
            if (memcnf_i == 2'b01 && offset == 2'b00) begin
                cache[index][7:0] <= data_i[7:0];
                cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                valid[index] <= 4'b0001;
            end else if (memcnf_i == 2'b01 && offset == 2'b01) begin
                cache[index][15:8] <= data_i[7:0];
                cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                valid[index] <= 4'b0010;
            end else if (memcnf_i == 2'b01 && offset == 2'b10) begin
                cache[index][23:16] <= data_i[7:0];
                cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                valid[index] <= 4'b0100;
            end else if (memcnf_i == 2'b01 && offset == 2'b11) begin
                cache[index][31:24] <= data_i[7:0];
                cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                valid[index] <= 4'b1000;
            end else if (memcnf_i == 2'b10 && offset == 2'b00) begin
                cache[index][15:0] <= data_i[15:0];
                cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                valid[index] <= 4'b0011;
            end else if (memcnf_i == 2'b10 && offset == 2'b10) begin
                cache[index][31:16] <= data_i[15:0];
                cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                valid[index] <= 4'b1100;
            end else if (memcnf_i == 2'b11 && offset == 2'b00) begin
                cache[index][`dCacheDataBus] <= data_i;
                cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];
                valid[index] <= 4'b1111;
            end
            /*
            cache[index][`dCacheDataBus] <= data_i;
            cache[index][`dCacheTagBus] <= addr_i[`dAddrTagBus];*/
        end
    end

endmodule