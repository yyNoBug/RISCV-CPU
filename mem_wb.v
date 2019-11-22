`include "defines.v"

module mem_wb(
    input wire clk,
    input wire rst,

    input wire[`RegAddrBus] mem_wd,
    input wire mem_wreg,
    input wire[`RegBus] mem_wdata,

    output reg[`RegAddrBus] wb_wd,
    output reg wb_wreg,
    output reg[`RegBus] wb_wdata
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin 
            wb_wd <= 0;
            wb_wreg <= 0;
            wb_wdata <= 0;
        end else begin
            wb_wd = mem_wd;
            wb_wreg = mem_wreg;
            wb_data = mem_data;
        end
    end

endmodule