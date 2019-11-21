#ifndef TRANSCODE
#define TRANSCODE

#include "enum.hpp"
#include "command.hpp"
#include "ultility.hpp"
#include "storage.hpp"

_com* transcode(int cur) {
	int opcode = get(0, 6, cur);
	int funct3, funct7;
	switch (opcode) {
	case 0b0110111: return new _com_U(cur, LUI);
	case 0b0010111: return new _com_U(cur, AUIPC);
	case 0b1101111: return new _com_UJ(cur, JAL);
	case 0b1100111: return new _com_I(cur, JALR);
	case 0b0000011:
		funct3 = get(12, 14, cur);
		switch (funct3) {
		case 0b000: return new _com_I(cur, LB);
		case 0b001: return new _com_I(cur, LH);
		case 0b010: return new _com_I(cur, LW);
		case 0b100: return new _com_I(cur, LBU);
		case 0b101: return new _com_I(cur, LHU);
		}
	case 0b1100011:
		funct3 = get(12, 14, cur);
		switch (funct3) {
		case 0b000: return new _com_SB(cur, BEQ);
		case 0b001: return new _com_SB(cur, BNE);
		case 0b100: return new _com_SB(cur, BLT);
		case 0b101: return new _com_SB(cur, BGE);
		case 0b110: return new _com_SB(cur, BLTU);
		case 0b111: return new _com_SB(cur, BGEU);
		}
	case 0b0100011:
		funct3 = get(12, 14, cur);
		switch (funct3) {
		case 0b000: return new _com_S(cur, SB);
		case 0b001: return new _com_S(cur, SH);
		case 0b010: return new _com_S(cur, SW);
		}
	case 0b0110011:
		funct3 = get(12, 14, cur);
		switch (funct3) {
		case 0b000:
			funct7 = get(25, 31, cur);
			switch (funct7) {
			case 0b0000000: return new _com_R(cur, ADD);
			case 0b0100000: return new _com_R(cur, SUB);
			}
		case 0b001: return new _com_R(cur, SLL);
		case 0b010: return new _com_R(cur, SLT);
		case 0b011: return new _com_R(cur, SLTU);
		case 0b100: return new _com_R(cur, XOR);
		case 0b101:
			funct7 = get(25, 31, cur);
			switch (funct7) {
			case 0b0000000: return new _com_R(cur, SRL);
			case 0b0100000: return new _com_R(cur, SRA);
			}
		case 0b110: return new _com_R(cur, OR);
		case 0b111: return new _com_R(cur, AND);

		}
	case 0b0010011:
		funct3 = get(12, 14, cur);
		switch (funct3) {
		case 0b000: return new _com_I(cur, ADDI);
		case 0b010: return new _com_I(cur, SLTI);
		case 0b011: return new _com_I(cur, SLTIU);
		case 0b100: return new _com_I(cur, XORI);
		case 0b110: return new _com_I(cur, ORI);
		case 0b111: return new _com_I(cur, ANDI);
		case 0b001: return new _com_I(cur, SLLI);
		case 0b101:
			funct7 = get(25, 31, cur);
			switch (funct7) {
			case 0b0000000: return new _com_I(cur, SRLI);
			case 0b0100000: return new _com_I(cur, SRAI);
			}
		}
	default:
		return new _com(0);
	}
}

bool isBranch(int command) {
	int opcode = get(0, 6, command);
	switch (opcode) {
	case 0b1100011: case 0b1101111: case 0b1100111:
		return true;
	default:
		return false;
	}
}

bool isB(int command) {
	int opcode = get(0, 6, command);
	switch (opcode) {
	case 0b1100011:
		return true;
	default:
		return false;
	}
}

bool isJ(int command) {
	int opcode = get(0, 6, command);
	switch (opcode) {
	case 0b1101111:
		return true;
	default:
		return false;
	}
}

bool isJR(int command) {
	int opcode = get(0, 6, command);
	switch (opcode) {
	case 0b1100111:
		return true;
	default:
		return false;
	}
}

bool spjdg(int command) {
    int opcode = get(0, 6, command);

    switch (opcode) {
        case 0b0110111:
        case 0b0010111:
        case 0b1101111:
        case 0b1100111:
        case 0b0000011:
        case 0b0110011:
        case 0b0010011:
            return true;
        default:
            return false;
    }
}


#endif // !TRANSCODE
