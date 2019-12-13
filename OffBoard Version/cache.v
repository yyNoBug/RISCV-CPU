`include "defines.v"

module inst_cache(
    //Interaction with IF
    input reg[`InstAddrBus] addr_i,
    output reg[`InstBus] inst_o,
    output reg inst_available_o,

    //Interaction with mem-control
    input wire addr_needed,
    input wire inst_available_i,
    input wire[`InstBus] inst_i,
    output reg inst_needed,
    output wire[`InstAddrBus] addr_o
);

    assign addr_o = addr_i;

    reg[`CacheBus] cache[0 : `CacheSize - 1];
    
    always @ (*) begin
        if (rst) begin
            inst_o = 0;
        end else begin
            inst_o = cache[inst_addr[:]]];
        end
    end

    always @ (*) begin
        if (rst) begin
            inst_needed = 0;
            inst_available_o = 0;
        end else if (inst_addr[:] == cache[addr_i[:]]) begin // hit
            inst_needed = 0;
            inst_available_o = 1;
        end else if (inst_available_i) begin // miss
            inst_needed = 0;
            inst_available_o = 1; //not necessarily needed
            cache[addr_i[:]] = inst_i; // For correctness, addr_i must remain unchanged.
        end else if (!inst_available_i) begin
            inst_needed = 1;
            inst_available_o = 0;
        end
    end

endmodule