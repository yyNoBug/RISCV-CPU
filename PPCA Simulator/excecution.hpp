#ifndef EXCECUTION
#define EXCECUTION

#include "storage.hpp"
#include "ultility.hpp"

void excecute(int _vala, int _valb, int imm, int npc, int typeofcode) {

	int rd = get(7, 11, DX.IR);
	int shift;

	switch (typeofcode) {
	case 0: //ADDI
		XM.AluOutput = _vala + imm;
		break;
	case 1: //SLTI
		if (_vala < imm) XM.AluOutput = 1;
		else XM.AluOutput = 0;
		break;
	case 2: //SLTIU
		if ((unsigned int)_vala < (unsigned int)imm) XM.AluOutput = 1;
		else XM.AluOutput = 0;
		break;
	case 3: //ANDI
		XM.AluOutput = imm & _vala;
		break;
	case 4: //ORI
		XM.AluOutput = imm | _vala;
		break;
	case 5: //XORI
		XM.AluOutput = imm ^ _vala;
		break;
	case 6: //SLLI
		shift = get(0, 4, imm);
		XM.AluOutput = ((unsigned int)_vala) << shift;
		break;
	case 7: //SRLI
		shift = get(0, 4, imm);
		XM.AluOutput = ((unsigned int)_vala) >> shift;
		break;
	case 8: //SRAI
		shift = get(0, 4, imm);
		XM.AluOutput = _vala >> shift;
		break;
	case 9: //JALR
		XM.AluOutput = npc;
		XM.NPC = (_vala + imm) & (-2);
		XM.cond = 1;
		break;
	case 10: //LW
		XM.AluOutput = _vala + imm;
		break;
	case 11: //LH
		XM.AluOutput = _vala + imm;
		break;
	case 12: //LHU
		XM.AluOutput = _vala + imm;
		break;
	case 13: //LB
		XM.AluOutput = _vala + imm;
		break;
	case 14: //LBU
		XM.AluOutput = _vala + imm;
		break;
	case 15: //LUI
		XM.AluOutput = imm;
		break;
	case 16: //AUIPC
		XM.AluOutput = npc - 4 + imm;
		break;
	case 17: //ADD
		XM.AluOutput = _vala + _valb;
		break;
	case 18: //SLT
		if (_vala < _valb) XM.AluOutput = 1;
		else XM.AluOutput = 0;
		break;
	case 19: //SLTU
		if ((unsigned int)_vala < (unsigned int)_valb) XM.AluOutput = 1;
		else XM.AluOutput = 0;
		break;
	case 20: //AND
		XM.AluOutput = _vala & _valb;
		break;
	case 21: //OR
		XM.AluOutput = _vala | _valb;
		break;
	case 22: //XOR
		XM.AluOutput = _vala ^ _valb;
		break;
	case 23: //SLL
		XM.AluOutput = _vala << _valb;
		break;
	case 24: //SRL
		XM.AluOutput = (unsigned int)_vala >> (unsigned int)_valb;
		break;
	case 25: //SUB
		XM.AluOutput = _vala - _valb;
		break;
	case 26: //SRA
		XM.AluOutput = _vala >> _valb;
		break;
	case 27: //JAL
		XM.AluOutput = npc;
		XM.NPC = npc + imm - 4;
		XM.cond = 1;
		break;
	case 28: //BEQ
		if (_vala == _valb) {
			XM.NPC = npc + imm - 4;
			XM.cond = 1;
		}
		else {
			XM.NPC = npc;
			XM.cond = 0;
		}
		break;
	case 29: //BNE
		if (_vala != _valb) {
			XM.NPC = npc + imm - 4;
			XM.cond = 1;
		}
		else {
			XM.NPC = npc;
			XM.cond = 0;
		}
		break;
	case 30: //BLT
		if (_vala < _valb) {
			XM.NPC = npc + imm - 4;
			XM.cond = 1;
		}
		else {
			XM.NPC = npc;
			XM.cond = 0;
		}
		break;
	case 31: //BLTU
		if ((unsigned int)_vala < (unsigned int)_valb) {
			XM.NPC = npc + imm - 4;
			XM.cond = 1;
		}
		else {
			XM.NPC = npc;
			XM.cond = 0;
		}
		break;
	case 32: //BGE
		if (_vala >= _valb) {
			XM.NPC = npc + imm - 4;
			XM.cond = 1;
		}
		else {
			XM.NPC = npc;
			XM.cond = 0;
		}
		break;
	case 33: //BGEU
		if ((unsigned int)_vala >= (unsigned int)_valb) {
			XM.NPC = npc + imm - 4;
			XM.cond = 1;
		}
		else {
			XM.NPC = npc;
			XM.cond = 0;
		}
		break;
	case 34: //SW
		XM.AluOutput = _vala + imm;
		XM.B = _valb;
		break;
	case 35: //SH
		XM.AluOutput = _vala + imm;
		XM.B = _valb & 0b1111111111111111;
		break;
	case 36: //SB
		XM.AluOutput = _vala + imm;
		XM.B = _valb & 0b11111111;
		break;
	}
}

#endif // !EXCECUTION
