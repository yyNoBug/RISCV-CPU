`include "defines.v"

module ex_mem(
    input wire clk,
    input wire rst,
    
    input wire[`RegAddrBus] ex_wd,
    input wire ex_wreg,
    input wire [`RegBus] ex_wdata,

    output wire[`RegAddrBus] mem_wd,
    output wire mem_wreg,
    output wire[`RegBus] mem_wdata
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            mem_wd = 0;
            mem_wreg = 0;
            mem_wdata = 0;
        end else begin 
            mem_wd = ex_wd;
            mem_wreg = ex_wreg;
            mem_wdata = ex_wdata;
        end
    end

endmodule