`include "defines.v"

module regfile (
    input wire clk,
    input wire rst,

    input wire we,
    input wire[`RegAddrBus] waddr,
    input wire[`RegBus] wdata,

    input wire re1,
    input wire[`RegAddrBus] raddr1,
    output reg[`RegBus] rdata1,

    input wire re2,
    input wire[`RegAddrBus] raddr2,
    output reg[`RegBus] rdata2
);

    reg[`RegBus] regs[0 : `RegNum - 1];

    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            if ((we == `WriteEnable) && (waddr != 0))  begin
                //$display("write %h %h", waddr, wdata);
                //$display("%t write %h %h", $realtime, waddr, wdata);
                regs[waddr] <= wdata;
            end
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            rdata1 <= 0;
        end else if (raddr1 == `RegNumLog2'h0) begin
            rdata1 <= 0;
        end else if ((raddr1 == waddr) &&  (we == `WriteEnable) 
                    && (re1 == `ReadEnable)) begin
            rdata1 <= wdata;
        end else if (re1 == `ReadEnable) begin
            rdata1 <= regs[raddr1];
        end else begin
            rdata1 <= 0;
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            rdata2 <= 0;
        end else if (raddr2 == `RegNumLog2'h0) begin
            rdata2 <= 0;
        end else if ((raddr2 == waddr) && (we == `WriteEnable)
                    && (re2 == `ReadEnable)) begin
            rdata2 <= wdata;
        end else if (re2 == `ReadEnable) begin
            rdata2 <= regs[raddr2];
        end else begin 
            rdata2 <= 0;
        end
    end

endmodule