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
            inst_o = cache[addr_i[6:0]][31:0];
        end
    end

    always @ (*) begin
        if (rst) begin
            inst_needed = 0;
            inst_available_o = 0;
            addr_i[56] = 1;
        end else if (addr_i[31:7] == cache[addr_i[6:0]][56:32]) begin // hit
            inst_needed = 0;
            inst_available_o = 1;
        end else if (inst_available_i) begin // miss
            inst_needed = 0;
            inst_available_o = 1; // Not necessarily needed, since it will hit after rewriting cache!
            cache[addr_i[6:0]][31:0] = inst_i; // For correctness, addr_i must remain unchanged.
            cache[addr_i[6:0]][56:32] = addr_i[31:7];
        end else if (!inst_available_i) begin
            inst_needed = 1;
            inst_available_o = 0;
        end
    end

endmodule