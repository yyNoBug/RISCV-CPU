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

    //output reg[`RegAddrBus] wb_wd_df,
    //output reg wb_wreg_df,
    //output reg[`RegBus] wb_wdata_df
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin 
            wb_wd <= 0;
            wb_wreg <= 0;
            wb_wdata <= 0;
            //wb_wd_df <= 0;
            //wb_wreg_df <= 0;
            //wb_wdata_df <= 0;
        end else begin
            wb_wd <= mem_wd;
            wb_wreg <= mem_wreg;
            wb_wdata <= mem_wdata;
            //wb_wd_df <= mem_wd;
            //wb_wreg_df <= mem_wreg;
            //wb_wdata_df <= mem_wdata;
        end
    end

endmodule