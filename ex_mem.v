`include "defines.v"

module ex_mem(
    input wire clk,
    input wire rst,
    input wire exmem_stall,
    
    input wire[`RegAddrBus] ex_wd,
    input wire ex_wreg,
    input wire [`RegBus] ex_wdata,
    input wire[`MemAddrBus] ex_memaddr,
    input wire ex_memwr, // 0 for load, 1 for store.
    input wire[1:0] ex_memcnf, // 0 for not using mem, 1 for B, 2 for H, 3 for W. 
    input wire ex_memsigned,

    output reg[`RegAddrBus] mem_wd,
    output reg mem_wreg,
    output reg[`RegBus] mem_wdata,
    output reg[`MemAddrBus] mem_memaddr,
    output reg mem_memwr, // 0 for load, 1 for store.
    output reg[1:0] mem_memcnf, // 0 for not using mem, 1 for B, 2 for H, 3 for W. 
    output reg mem_memsigned
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            mem_wd <= 0;
            mem_wreg <= 0;
            mem_wdata <= 0;
            mem_memaddr <= 0;
            mem_memcnf <= 0;
            mem_memsigned <= 0;
            mem_memwr <= 0;
        end else if (!exmem_stall) begin 
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
            mem_memaddr <= ex_memaddr;
            mem_memcnf <= ex_memcnf;
            mem_memsigned <= ex_memsigned;
            mem_memwr <= ex_memwr;
        end
    end

endmodule