//全局的宏定义
`define RstEnable           1'b1
`define RstDisable          1'b0
`define ZeroWord            32'h00000000
`define WriteEnable         1'b1
`define WriteDisable        1'b0
`define ReadEnable          1'b1
`define ReadDisable         1'b0
`define AluOpBus            7:0
`define AluFunBus           2:0
`define InstValid           1'b0     
`define InstInvalid         1'b1
`define True_v              1'b1
`define False_v             1'b0
`define ChipEnable          1'b1
`define ChipDisable         1'b0
`define Busy                1'b1
`define NotBusy             1'b0
`define Avl                 1'b1
`define NotAvl              1'b0
`define True                1'b1
`define False               1'b0
`define Read                1'b0
`define Write               1'b1

//与指令有关具体宏的含义
`define EXE_ORI             7'b0010011 //指令ORI等的指令码
`define EXE_OR              7'b0110011 //指令OR等的指令码
`define EXE_JAL             7'b1101111 //指令JAL的指令码
`define EXE_JALR            7'b1100111 //指令JALR的指令码
`define EXE_BEQ             7'b1100011 //分支指令的指令码
`define EXE_NOP             7'b0000000

`define EXE_OR_OP           8'b00100101
`define EXE_NOP_OP          8'b00000000

`define FUN_ADDI            3'b000
`define FUN_SLTI            3'b010
`define FUN_SLTIU           3'b011
`define FUN_XORI            3'b100
`define FUN_ORI             3'b110
`define FUN_ANDI            3'b111
`define FUN_SLLI            3'b001
`define FUN_SRLI            3'b101
`define FUN_SRAI            3'b101

`define FUN_ADD             3'b000
`define FUN_SUB             3'b000
`define FUN_SLL             3'b001
`define FUN_SLT             3'b010
`define FUN_SLTU            3'b011
`define FUN_XOR             3'b100
`define FUN_SRL             3'b101
`define FUN_SRA             3'b101
`define FUN_OR              3'b110
`define FUN_AND             3'b111

`define FUN_NOP             3'b000

//与指令储存器ROM有关的宏定义
`define InstAddrBus         31:0
`define InstBus             31:0
`define InstMemNum          16384 //128Kb一共有16384个字节
`define InstMemNumLog2      14


//与通用寄存器Regfile有关的宏定义
`define RegAddrBus          4:0 //Regfile模块的地址线宽度
`define RegBus              31:0 //Regfile模块的数据线宽度
`define RegWidth            32
`define DoubleRegWidth      64
`define DoubleRegBus        63:0
`define RegNum              32
`define RegNumLog2          5
`define NOPRegAddr          5'b00000

`define ImmBus              31:0