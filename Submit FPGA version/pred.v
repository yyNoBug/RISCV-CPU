`include "defines.v"

module pred(
    input wire clk,
    input wire rst,
    
    //Interaction with IF
    input wire[`InstAddrBus] addr_i,

    //Interaction with EX
    input wire is_br,
    input wire[`InstAddrBus] addr_ex,
    input wire[`InstAddrBus] jmp_addr,
    input wire jmp,

    //Interacion with PC_REG
    output reg br_p,
    output reg[`InstAddrBus] addr_p
);

    wire[`pIndexBus] index;
    assign index = addr_i[`pAddrIndexBus];
    wire[`pIndexBus] pindex;
    assign pindex = addr_ex[`pAddrIndexBus];

    reg[`PredCacheBus] cache[0 : `pCacheLine - 1];

    always @ (*) begin
        if (rst) begin
            br_p = 0;
            addr_p = 0;
        end else if (cache[index][`PredTagBus] == addr_i[`pAddrTagBus] && 
                (cache[index][`PredCntBus] == 2'b10 || cache[index][`PredCntBus] == 2'b11)) begin
            br_p = 1;
            addr_p = cache[index][`PredAddrBus];
        end else begin
            br_p = 0;
            addr_p = 0;
        end
    end

    reg [10:0] i;
    always @ (posedge clk) begin
        if (rst) begin
            for (i = 0; i < `pCacheLine; i = i + 1) begin
                cache[i][`PredCntBus] <= 2'b00;
                cache[i][54] <= 1;
            end
        end else if (is_br && jmp) begin
            cache[pindex][`PredTagBus] <= addr_ex[`pAddrTagBus];
            cache[pindex][`PredAddrBus] <= jmp_addr;
            if (cache[pindex][`PredCntBus] != 2'b11)
                cache[pindex][`PredCntBus] <= cache[pindex][`PredCntBus] + 1;
        end else if (is_br && !jmp) begin
            cache[pindex][`PredTagBus] <= addr_ex[`pAddrTagBus];
            cache[pindex][`PredAddrBus] <= jmp_addr;
            if (cache[pindex][`PredCntBus] != 2'b00)
                cache[pindex][`PredCntBus] <= cache[pindex][`PredCntBus] - 1;
        end
    end

endmodule