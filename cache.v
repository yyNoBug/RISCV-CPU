`include "defines.v"

module inst_cache(
    input wire rst,
    
    //Interaction with IF
    input wire[`InstAddrBus] addr_i,
    output reg[`InstBus] inst_o,
    output reg inst_available_o,

    //Interaction with mem-control
    input wire addr_needed,
    input wire inst_available_i,
    input wire[`InstBus] inst_i,
    output reg inst_needed,
    output wire[`InstAddrBus] addr_o,

    input wire branch_interception,
    input wire[1:0] memcnf
);

    wire[`IndexBus] index;

    assign addr_o = addr_i;
    assign index = addr_i[`AddrIndexBus];

    reg[`CacheBus] cache[0 : `CacheLine - 1];
    
    always @ (*) begin
        if (rst) begin
            inst_o = 0;
        end else begin
            inst_o = cache[index][`CacheInstBus];
        end
    end

    reg [10:0] i;

    always @ (*) begin
        if (rst) begin
            inst_needed = 0;
            inst_available_o = 0;
            for (i = 0; i < 128; i = i + 1) begin
                cache[i][56] = 1;
            end
        end else if (addr_i[`AddrTagBus] == cache[index][`CacheTagBus]) begin // hit
            inst_needed = 0;
            inst_available_o = 1;
        end else if (inst_available_i) begin // miss but found
            inst_needed = 0; // Not necessarily needed, since it will hit after rewriting cache.
            inst_available_o = 1; // Not necessarily needed, since it will hit after rewriting cache.
            cache[index][`CacheInstBus] = inst_i;
            cache[index][`CacheTagBus] = addr_i[`AddrTagBus];
        end else if (!inst_available_i) begin // miss and not found
            inst_needed = 1;
            inst_available_o = 0;
        end
    end

endmodule