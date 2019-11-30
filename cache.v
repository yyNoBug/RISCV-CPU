`include "defines.v"

module inst_cache(
    //Interaction with IF
    input reg[`InstAddrBus] inst_addr,
    output reg addr_needed,
    output reg inst_available,
    output reg[`InstBus] inst,
    output reg[`InstAddrBus] inst_addr_o,

    //Interaction with mem-control
    output reg[`InstAddrBus] to_mem,
    output reg[`Inst]
);

    reg[`CacheBus] cache[0 : `CacheSize - 1];
    reg inst_waiting_in_mem;
    

    always @ (*) begin
        
    end

endmodule