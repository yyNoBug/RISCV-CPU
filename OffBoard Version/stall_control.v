`include "defines.v"

module stall_control(
    input wire if_stall,
    input wire id_stall,
    input wire ex_stall,
    input wire mem_stall,

    output wire pcreg_stall,
    output wire ifid_stall,
    output wire idex_stall,
    output wire exmem_stall
);

    assign pcreg_stall = if_stall | id_stall | ex_stall | mem_stall;
    assign ifid_stall = id_stall | ex_stall | mem_stall;
    assign idex_stall = ex_stall | mem_stall;
    assign exmem_stall = mem_stall;

endmodule