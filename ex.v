`include "defines.v"

module ex(
    input wire rst,

    // For calculation.
    input wire[`AluSelBus] alusel_i,
    input wire[`RegBus] opr1_i,
    input wire[`RegBus] opr2_i,
    input wire[`ImmBus] opr3_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i, //此段指令是否有写入的�??终寄存器
    
    /*
    // For data-fowarding.
    input wire reg1_re,
    input wire[`RegAddrBus] reg1_i_addr,
    input wire reg2_re,
    input wire[`RegAddrBus] reg2_i_addr,
    input wire dataf_exmem_we, //If there isn't any error here, I'm somehow confident that data-fowarding will work properly.
    input wire[`RegAddrBus] dataf_exmem_wd,
    input wire[`RegBus] dataf_exmem_data,
    input wire dataf_memwb_we,
    input wire[`RegAddrBus] dataf_memwb_wd,
    input wire[`RegBus] dataf_memwb_data,
    */

    output reg dataf_ex_we,
    output reg[`RegAddrBus] dataf_ex_wd,
    output reg[`RegBus] dataf_ex_data,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    output reg ex_stall
);

    reg[`RegBus] logicout;
    
    /*
    wire[`RegBus] reg1;
    assign reg1 = ((reg1_i_addr == dataf_exmem_wd) &&  (dataf_exmem_we == `WriteEnable)
        && reg1_re == `ReadEnable) ? dataf_exmem_data : (((reg1_i_addr == dataf_memwb_wd)
        &&  (dataf_memwb_we == `WriteEnable) && reg1_re == `ReadEnable) ? dataf_memwb_data : reg1_i);
    
    wire[`RegBus] reg2;
    assign reg2 = ((reg2_i_addr == dataf_exmem_wd) &&  (dataf_exmem_we == `WriteEnable)
        && reg2_re == `ReadEnable) ? dataf_exmem_data : (((reg2_i_addr == dataf_memwb_wd)
        &&  (dataf_memwb_we == `WriteEnable) && reg2_re == `ReadEnable) ? dataf_memwb_data : reg2_i);
    */

    always @ (*) begin
        if (rst == `RstEnable) begin
            logicout = 0;
        end else begin
            case(alusel_i)
            `SEL_OR: begin
                logicout = opr1_i | opr2_i;
            end
            `SEL_AND: begin
                logicout = opr1_i & opr2_i;
            end
            `SEL_XOR: begin
                logicout = opr1_i ^ opr2_i;
            end
            `SEL_ADD: begin
                logicout = opr1_i + opr2_i;
            end
            `SEL_SLT: begin
                if ($signed(opr1_i) < $signed(opr2_i)) 
                    logicout = opr1_i;
                else logicout = 0;
            end
            `SEL_SLTU: begin
                if (opr1_i < opr2_i) logicout <= opr1_i;
                else logicout = 0;
            end
            `SEL_SLL: begin
                logicout = opr1_i << opr2_i[4:0]; //may be wrong here
            end
            `SEL_SRL: begin
                if (opr2_i[10] == 1'b0)
                    logicout = opr1_i >>> opr2_i[4:0]; //may be wrong here
                else
                    logicout = opr1_i >> opr2_i[4:0]; //may be wrong here
            end
            `SEL_LUI: begin
                logicout = opr1_i;
            end
            `SEL_AUIPC: begin
                logicout = opr1_i + opr2_i;
            end
            default: begin
                logicout = 0;
            end
            endcase
        end
    end

    always @ (*) begin
        
        if (rst == `RstEnable) begin
            wd_o = 0;
            wreg_o = 0;
            wdata_o = 0;
            dataf_ex_wd = 0;
            dataf_ex_we = 0;
            dataf_ex_data = 0;
            ex_stall = `False;
        end else begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = logicout;
            dataf_ex_wd = wd_i;
            dataf_ex_we = wreg_i;
            dataf_ex_data = logicout;
            ex_stall = `False;
        end
    end

endmodule