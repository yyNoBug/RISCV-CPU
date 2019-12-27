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
`define AluSelBus           4:0
`define InstValid           1'b0     
`define InstInvalid         1'b1
`define True                1'b1
`define False               1'b0
`define Read                1'b0
`define Write               1'b1

//与指令有关具体宏的含义
`define EXE_ORI             7'b0010011 //指令ORI等的指令码
`define EXE_OR              7'b0110011 //指令OR等的指令码
`define EXE_LUI             7'b0110111
`define EXE_AUIPC           7'b0010111
`define EXE_JAL             7'b1101111 //指令JAL的指令码
`define EXE_JALR            7'b1100111 //指令JALR的指令码
`define EXE_BEQ             7'b1100011 //分支指令的指令码
`define EXE_LOAD            7'b0000011
`define EXE_STORE           7'b0100011
`define EXE_NOP             7'b0000000

`define SEL_ADD             5'b00000
`define SEL_SUB             5'b00000
`define SEL_SLL             5'b00001
`define SEL_SLT             5'b00010
`define SEL_SLTU            5'b00011
`define SEL_XOR             5'b00100
`define SEL_SRL             5'b00101
`define SEL_SRA             5'b00101
`define SEL_OR              5'b00110
`define SEL_AND             5'b00111
`define SEL_LUI             5'b01100
`define SEL_AUIPC           5'b01001
`define SEL_JAL             5'b01010
`define SEL_JALR            5'b01011
`define SEL_BEQ             5'b10000
`define SEL_BNE             5'b10001
`define SEL_BLT             5'b10100
`define SEL_BGE             5'b10101
`define SEL_BLTU            5'b10110
`define SEL_BGEU            5'b10111
`define SEL_LB              5'b11000
`define SEL_LH              5'b11001
`define SEL_LW              5'b11010
`define SEL_LBU             5'b11100
`define SEL_LHU             5'b11101
`define SEL_SB              5'b11111
`define SEL_SH              5'b11110
`define SEL_SW              5'b11011

//与指令储存器ROM有关的宏定义
`define InstAddrBus         31:0
`define InstBus             31:0
`define MemAddrBus          31:0
`define MemDataBus          31:0
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

`define CacheLine           128
`define CacheBus            54:0 //56:32存Tag 31:0存指令, 54 = 32+32-log(128)-1-2
`define CacheTagBus         54:32
`define CacheInstBus        31:0
`define AddrTagBus          31:9
`define AddrIndexBus        8:2
`define IndexBus            6:0
