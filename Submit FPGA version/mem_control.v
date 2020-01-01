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
    output reg[`InstBus] inst, // It's just a name. Data also use this reg.

    // interaction with i_cache
    input wire inst_needed,
    input wire[`InstAddrBus] inst_addr_i,
    //input wire ifid_stall,
    output reg inst_available,

    // interaction with mem
    input wire datawr_i,
    input wire[`MemAddrBus] data_addr_i,
    input wire[`MemDataBus] data_i,
    input wire[1:0] data_cnf_i,
    output reg busy_data,
    output reg data_available,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire signed_i,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg signed_o,
    output reg[1:0] cnf_o
);

    reg[2:0] cnt;
    //reg[1:0] cnf;
    reg busy_inst;
    
    reg[`InstAddrBus] addr;
    reg[`MemDataBus] data;
    reg wr;
    
    reg[31:0] buffer;

    /*
    always @ (posedge clk) begin
        if (wr_ram) begin
            $display("mem_write %h $h", addr, data);
        end
    end
    */

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
            
        end else begin
            if (branch_interception && busy_inst) begin // here IF has a higher priority than mem, causing bug.
                busy_inst <= 0;
                almost_available <= 1;
                cnt <= 0;
            end else if (cnt == 3'b000) begin
                buffer[15:8] <= din_ram; // NOTE HERE: This may cause problem.
                almost_available <= `False;
                inst_available <= `False;
                data_available <= `False;
                cnf_o <= data_cnf_i;
                if (data_cnf_i == 2'b00) begin // For IF.
                    if (!inst_needed || branch_interception) begin
                        almost_available <= 1;
                        wr_ram <= 0;
                    end else if (addr_ram == inst_addr_i + 2) begin
                        addr_ram <= addr + 7;
                        addr <= inst_addr_i;
                        wr <= 0;
                        wr_ram <= 0;
                        inst[15:0] <= buffer;
                        busy_inst <= `True;
                        cnt <= 3'b100;
                    end else begin
                        addr <= inst_addr_i;
                        addr_ram <= inst_addr_i;
                        wr <= 0;
                        wr_ram <= 0;
                        busy_inst <= `True;
                        cnt <= cnt + 1;
                    end
                end else begin // For MEM.
                    addr <= data_addr_i;
                    addr_ram <= data_addr_i;
                    data <= data_i;
                    dout_ram <= data_i[7:0];
                    wr <= datawr_i;
                    wr_ram <= datawr_i;
                    wd_o <= wd_i;
                    wreg_o <= wreg_i;
                    signed_o <= signed_i;
                    if (datawr_i == 1 && (data_addr_i == 32'h30000 || data_addr_i == 32'h30004)) begin
                        busy_data <= `True;
                        cnt <= cnt + 1;
                    end else if (datawr_i == 1 && data_cnf_i == 2'b01) begin
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
                if (wr == 1 && cnf_o == 2'b10) begin
                    data_available <= `True;
                    almost_available <= `True;
                    busy_data <= `False;
                    cnt <= 0;
                end else if (wr == 1 && (addr == 32'h30000 || addr == 32'h30004)) begin
                    wr_ram <= 0;
                    addr_ram <= 0;
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
                if (wr == 0 && cnf_o == 2'b01) begin
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
                if (wr == 1 && cnf_o == 2'b11) begin
                    data_available <= `True;
                    almost_available <= `True;
                    busy_data <= `False;
                    cnt <= 0;
                end else if (wr == 0 && cnf_o == 2'b10) begin
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
                addr_ram <= addr + 4;

            end else if (cnt == 3'b101) begin
                inst[31:24] <= din_ram;
                addr_ram <= addr + 5;
                if (busy_inst) begin
                    inst_available <= 1;
                    busy_inst <= `False;
                    almost_available <= 0;
                    cnt <= 3'b110;
                end else if (busy_data) begin
                    data_available <= 1;
                    busy_data <= `False;
                    almost_available <= 1;
                    cnt <= 0;
                end else begin
                    $display("BOOMSHAKALAKA!");
                end

            end else if (cnt == 3'b110) begin
                buffer[7:0] <= din_ram;
                addr_ram <= addr + 6;
                almost_available <= 1;
                inst_available <= 0;
                cnt <= 0;
            end
        end
    end

endmodule