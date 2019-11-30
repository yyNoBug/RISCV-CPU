`include "defines.v"

module mem_control(
    input wire clk,
    input wire rst,

    // interation with ram
    input wire[7:0] din_ram,
    output reg[7:0] dout_ram,
    output reg[`InstAddrBus] addr_ram,
    output reg wr_ram,
    
    // interaction with pc
    input wire[`InstAddrBus] inst_addr_i,
    output reg almost_available,
    output reg available,
    output reg[`InstBus] inst,
    output reg[`InstAddrBus] inst_addr_o
);

    reg[2:0] cnt;
    reg[`InstAddrBus] addr;
    //reg jdg;
    //reg[`InstAddrBus] nxt_addr;


    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            cnt <= 3'b000; //Since I begin with 0 here, the first instruction will step twice.
            almost_available <= `False;
            available <= `False;
            addr <= 0;
            dout_ram <= 0;
            wr_ram <= 0;
            inst <= 0;
            inst_addr_o <= 0;
            
        end else begin
            if (cnt == 3'b000) begin
                addr <= inst_addr_i;
                addr_ram = inst_addr_i;
                almost_available <= `False;
                available <= `False;
                cnt <= cnt + 1;
            end else if (cnt == 3'b001) begin
                addr_ram = addr + 1;
                cnt <= cnt + 1;
            end else if (cnt == 3'b010) begin
                inst[31:24] <= din_ram;
                addr_ram = addr + 2;
                cnt <= cnt + 1;
            end else if (cnt == 3'b011) begin
                inst[23:16] <= din_ram;
                addr_ram <= addr + 3;
                cnt <= cnt + 1;
            end else if (cnt == 3'b100) begin
                inst[15:8] <= din_ram;
                cnt <= cnt + 1;
            end else if (cnt == 3'b101) begin
                inst[7:0] <= din_ram;
                cnt <= 0;
                almost_available <= 1;
                available <= 1;
            end

            /*
            if (cnt == 2'b00) begin
                inst[7:0] <= din_ram;
                addr_ram <= addr + 1;
                available <= `True;
                cnt <= 2'b01;
            end else if (cnt == 2'b01) begin
                inst[31:24] <= din_ram;
                addr_ram = addr + 2;
                available = `False;
                cnt <= 2'b10;
            end else if (cnt == 2'b10) begin
                inst[23:16] <= din_ram;
                addr_ram <= addr + 3;
                almost_available <= `True;
                cnt <= 2'b11;
            end else if (cnt == 2'b11) begin
                inst[15:8] <= din_ram;
                inst_addr_o <= addr; // Give back to PC
                almost_available <= `False;
                
                addr = inst_addr_i;
                addr_ram = addr;
                cnt = 2'b00;
                wr_ram = `Read;
            end
            */

        end
    end

endmodule