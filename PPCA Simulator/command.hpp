#ifndef COMMAND
#define COMMAND

#include <iostream>
#include "enum.hpp"
#include "ultility.hpp"

class _com {
	int opcode;

public:
	_com(int _opcode) :opcode(_opcode) {}

	virtual bool getreg() {
		return true;
	}
};

class _com_R : public _com {
	int funct7, rs2, rs1, funct3, rd;
	_R_type type;

public:
	_com_R(int cod, _R_type typ) : _com(get(0, 6, cod)), type(typ) {
		rd = get(7, 11, cod);
		funct3 = get(12, 14, cod);
		rs1 = get(15, 19, cod);
		rs2 = get(20, 24, cod);
		funct7 = get(25, 31, cod);
	}

	virtual bool getreg() {
		if (lock[rs1] || lock[rs2]) return false;
		DX.A = x[rs1];
		DX.B = x[rs2];
		DX.imm = 0;
		DX.type = type;
		lock[rd]++;
		return true;
	}
};

class _com_I : public _com {
	int imm, rs1, funct3, rd;
	_I_type type;

public:
	_com_I(int cod, _I_type typ) :_com(get(0, 6, cod)), type(typ) {
		rd = get(7, 11, cod);
		funct3 = get(12, 14, cod);
		rs1 = get(15, 19, cod);
		imm = get(20, 31, cod) << 20 >> 20;
	}

	virtual bool getreg() {
		if (lock[rs1]) return false;
		DX.A = x[rs1];
		DX.B = 0;
		DX.imm = imm;
		DX.type = type;
		lock[rd]++;
		return true;
	}
};

class _com_S : public _com {
	int imm, rs2, rs1, funct3;
	_S_type type;

public:
	_com_S(int cod, _S_type typ) :_com(get(0, 6, cod)), type(typ) {
		funct3 = get(12, 14, cod);
		rs1 = get(15, 19, cod);
		rs2 = get(20, 24, cod);
		imm = link(get(25, 31, cod), 7, get(7, 11, cod), 5);
	}

	virtual bool getreg() {
		if (lock[rs1] || lock[rs2]) return false;
		DX.A = x[rs1];
		DX.B = x[rs2];
		DX.imm = imm;
		DX.type = type;
		return true;
	}
};

class _com_SB : public _com {
	int imm, rs2, rs1, funct3;
	_SB_type type;

public:
	_com_SB(int cod, _SB_type typ) :_com(get(0, 6, cod)), type(typ) {
		funct3 = get(12, 14, cod);
		rs1 = get(15, 19, cod);
		rs2 = get(20, 24, cod);
		imm = link(get(31, 31, cod), 1, get(7, 7, cod), 1, get(25, 30, cod), 6, get(8, 11, cod), 4);
		imm = imm << 1;
	}

	virtual bool getreg() {
		if (lock[rs1] || lock[rs2]) return false;
		DX.A = x[rs1];
		DX.B = x[rs2];
		DX.imm = imm;
		DX.type = type;
		return true;
	}
};

class _com_U : public _com {
	int imm, rd;
	_U_type type;

public:
	_com_U(int cod, _U_type typ) :_com(get(0, 6, cod)), type(typ) {
		rd = get(7, 11, cod);
		imm = get(12, 31, cod);
		imm = imm << 12;
	}

	virtual bool getreg() {
		DX.A = 0;
		DX.B = 0;
		DX.imm = imm;
		DX.type = type;
		lock[rd]++;
		return true;
	}
};

class _com_UJ : public _com {
	int imm, rd;
	_UJ_type type;

public:
	_com_UJ(int cod, _UJ_type typ) :_com(get(0, 6, cod)), type(typ) {
		rd = get(7, 11, cod);
		imm = link(get(31, 31, cod), 1, get(12, 19, cod), 8, get(20, 20, cod), 1, get(21, 30, cod), 10);
		imm = imm << 1;
	}

	virtual bool getreg() {
		DX.A = 0;
		DX.B = 0;
		DX.imm = imm;
		DX.type = type;
		lock[rd]++;
		return true;
	}
};

#endif // !COMMAND