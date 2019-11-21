#ifndef ENUM
#define ENUM

#include <iostream>

enum _I_type {
	ADDI = 0, SLTI = 1, SLTIU = 2, ANDI = 3, ORI = 4, 
	XORI = 5, SLLI = 6, SRLI = 7, SRAI = 8, JALR = 9,
	LW = 10, LH = 11, LHU = 12, LB = 13, LBU = 14
};

enum _U_type {
	LUI = 15, AUIPC = 16
};

enum _R_type {
	ADD = 17, SLT = 18, SLTU = 19, AND = 20, OR = 21,
	XOR = 22, SLL = 23, SRL = 24, SUB = 25, SRA = 26
};

enum _UJ_type {
	JAL = 27
};

enum _SB_type {
	BEQ = 28, BNE = 29, BLT = 30, BLTU = 31, BGE = 32, BGEU = 33 
};

enum _S_type {
	SW = 34, SH = 35, SB = 36
};

#endif // !ENUM