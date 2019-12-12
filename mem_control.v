`include "defines.v"

module mem_control(
    input wire clk,
    input wire rst,
    input wire branch_interception,

    // interation with ram
    input wire[7:0] din_ram,
    output reg[7:0] dout_ram,
    output reg[`InstAddrBus] addr_ram,
    output reg wr_ram,
    
    output reg almost_available,
    output reg[`InstBus] inst,

    // interaction with if
    input wire[`InstAddrBus] inst_addr_i,
    input wire ifid_stall,
    output reg inst_available,
    output reg[`InstAddrBus] inst_addr_o,

    // interaction with mem
    input wire datawr_i,
    input wire[`MemAddrBus] data_addr_i,
    input wire[`MemDataBus] data_i,
    input wire[1:0] data_cnf_i,
    output reg busy_data,
    output reg data_available
);

    reg[2:0] cnt;
    reg[`InstAddrBus] addr;
    reg[`MemDataBus] data;
    reg busy_inst;
    
    reg[1:0] cnf;
    reg wr;

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            cnt <= 3'b110;
            almost_available <= `False;
            inst_available <= `False;
            data_available <= `False;
            busy_data <= 0;
            busy_inst <= 0;
            addr <= 0;
            dout_ram <= 0;
            wr_ram <= 0;
            inst <= 0;
            inst_addr_o <= 0;
            
        end else begin
            if (branch_interception && busy_inst) begin
                busy_inst <= 0;
                almost_available <= 1;
                cnt <= 0;
            end else if (cnt == 3'b000) begin
                almost_available <= `False;
                inst_available <= `False;
                data_available <= `False;
                cnf <= data_cnf_i;
                if (data_cnf_i == 2'b00) begin
                    if (ifid_stall) begin // The awkward thing is for the stalling problem of pc_reg.
                        almost_available <= 1;
                    end else begin
                        addr <= inst_addr_i;
                        addr_ram <= inst_addr_i;
                        wr <= 0;
                        wr_ram <= 0;
                        busy_inst <= `True;
                        cnt <= cnt + 1;
                    end
                end else begin
                    addr <= data_addr_i;
                    addr_ram <= data_addr_i;
                    data <= data_i;
                    dout_ram <= data_i[7:0];
                    wr <= datawr_i;
                    wr_ram <= datawr_i;
                    if (datawr_i == 1 && data_cnf_i == 2'b01) begin
                        data_available <= `True;
                        almost_available <= `True;
                    end else begin
                        busy_data <= `True;
                        cnt <= cnt + 1;
                    end
                end
            end else if (cnt == 3'b001) begin
                addr_ram <= addr + 1;
                dout_ram <= data[15:8];
                if (wr == 1 && cnf == 2'b10) begin
                    data_available <= `True;
                    almost_available <= `True;
                    busy_data <= `False;
                    cnt <= 0;
                end else begin
                    cnt <= cnt + 1;
                end
            end else if (cnt == 3'b010) begin
                inst[7:0] <= din_ram;
                dout_ram <= data[23:16];
                addr_ram <= addr + 2;
                cnt <= cnt + 1;
                if (wr == 0 && cnf == 2'b01) begin
                    data_available <= `True;
                    almost_available <= `True;
                    busy_data <= `False;
                    cnt <= 0;
                end else begin
                    cnt <= cnt + 1;
                end
            end else if (cnt == 3'b011) begin
                inst[15:8] <= din_ram;
                dout_ram <= data[31:24];
                addr_ram <= addr + 3;
                cnt <= cnt + 1;
                if (wr == 1 && cnf == 2'b11) begin
                    data_available <= `True;
                    almost_available <= `True;
                    busy_data <= `False;
                    cnt <= 0;
                end else if (wr == 0 && cnf == 2'b10) begin
                    data_available <= `True;
                    almost_available <= `True;
                    busy_data <= `False;
                    cnt <= 0;
                end else begin
                    cnt <= cnt + 1;
                end
            end else if (cnt == 3'b100) begin
                inst[23:16] <= din_ram;
                cnt <= cnt + 1;
            end else if (cnt == 3'b101) begin
                inst[31:24] <= din_ram;
                cnt <= 0;
                almost_available <= 1;
                if (busy_inst) begin
                    inst_addr_o <= addr;
                    inst_available <= 1;
                    busy_inst <= `False;
                end else if (busy_data) begin
                    data_available <= 1;
                    busy_data <= `False;
                end else begin
                    $display("BOOMSHAKALAKA!");
                end
            end else if (cnt == 3'b110) begin
                almost_available <= 1;
                cnt <= 0;
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