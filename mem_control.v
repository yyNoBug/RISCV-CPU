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
    //input wire inst_needed,
    input wire[`InstAddrBus] inst_addr_i,
    //input wire[`InstAddrBus] inst_addr_nxt,
    output reg avalible,  //Whether the mem_control part does the right thing.
    output reg[`InstBus] inst,
    output reg[`InstAddrBus] inst_addr_o
    //output reg busy_1,
    //output reg busy_2
);

    reg[2:0] cnt;
    reg[`InstAddrBus] addr;
    reg jdg;
    //reg[`InstAddrBus] nxt_addr;

    
    always @ (*) begin
        if (rst == `RstEnable) begin
            cnt = 0;
            addr = 0;
            dout_ram = 0;
            wr_ram = 0;
        end else begin
            addr = inst_addr_i;
            addr_ram = addr;
            cnt = 2'b00;
            wr_ram = `Read;
            avalible = 0;
            //jdg = `False;
            //busy = `Busy;
        end
    end
    /*
    always @ (negedge clk) begin
        jdg = `True;
    end
    */

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            inst <= 0;
            inst_addr_o <= 0;
        end else begin
            if (cnt == 2'b00) begin
                #0.1 inst[31:24] <= din_ram;
                addr_ram <= addr + 1;
                avalible <= `False;
                cnt <= 2'b01;
            end else if (cnt == 2'b01) begin
                #0.1 inst[23:16] <= din_ram;
                addr_ram = addr + 2;
                cnt <= 2'b10;
            end else if (cnt == 2'b10) begin
                #0.1 inst[15:8] <= din_ram;
                addr_ram = addr + 3;
                cnt <= 2'b11;
            end else if (cnt == 2'b11) begin
                #0.1 inst[7:0] <= din_ram;
                inst_addr_o <= addr;
                avalible <= `True;
                //busy <= `False;
            end
        end
    end

endmodule