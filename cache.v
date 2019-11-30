`include "defines.v"

module inst_cache(
    //Interaction with IF
    input reg[`InstAddrBus] inst_addr,
    output reg[`InstBus] inst,
    output reg[`InstAddrBus] inst_addr_o,
    output reg addr_needed,

    //Interaction with mem-control
    input wire inst_available,
    input wire[`InstBus] inst_from_mem,
    output reg inst_needed,
    output reg[`InstAddrBus] addr_to_mem,
    output reg[`InstAddrBus] 
);

    reg[`CacheBus] cache[0 : `CacheSize - 1];
    
    always @ (*) begin
        if (rst == `True) begin
            inst = 0;
            addr_needed = 0;
            inst_addr_o = 0;
            inst_needed = 0;
            addr_to_mem = 0;
        end else if (inst_addr[:2] == cache[inst_addr[:]]) begin // hit
            inst = cache[inst_addr[:]];
            inst_addr_o = inst_addr;
            inst_needed = 0;
            addr_needed = 1;
        end else if (inst_available) begin // miss
            inst = inst_from_mem;
            inst_addr_o = inst_addr;
            inst_needed = 0;
            addr_needed = 1;

        end else if (!inst_available) begin
            inst_needed = 1;
            addr_needed = 0;
            addr_to_mem = inst_addr;
        end
    end

endmodule