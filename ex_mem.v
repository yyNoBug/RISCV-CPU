`include "defines.v"

module ex_mem(
    input wire clk,
    input wire rst,
    input wire mem_stall,
    
    input wire[`RegAddrBus] ex_wd,
    input wire ex_wreg,
    input wire [`RegBus] ex_wdata,

    output reg[`RegAddrBus] mem_wd,
    output reg mem_wreg,
    output reg[`RegBus] mem_wdata
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            mem_wd <= 0;
            mem_wreg <= 0;
            mem_wdata <= 0;
        end else begin 
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
        end
    end

endmodule