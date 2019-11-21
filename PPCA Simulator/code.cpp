#include <iostream>
#include <stdio.h>
#include <cstring>
#include <cmath>
#include <vector>
#include "storage.hpp"
#include "ultility.hpp"
#include "transcode.hpp"
#include "excecution.hpp"
#include "readin.hpp"

using std::cout;

bool stop;
int memcnt;

void IF();
void ID();
void EX();
void MEM();
void WB();
void display();

int count;

int main() {

	fetch();

	while (!stop) {
		WB();
		MEM();
		EX();
		ID();
		IF();
		//display();
	}
	WB();
	MEM();
	EX();
	WB();
	MEM();
	WB();

	cout << ((unsigned int)x[10] & 255u);
	pred.ACC();
}

void IF() {
	int cond = XM.cond;
	int npc = XM.NPC;
	int jump = XM.jump;
	
	if (isB(XM.IR)) {
		if (!FD.IR) pred.update(XM.NPC - 4, cond);
	}
	
	if (!jump &&(cond && isBranch(XM.IR)) || (jump && (!cond && isB(XM.IR)) || isJR(XM.IR))) {
		pc = npc;
		if (spjdg(DX.IR) && FD.IR == 0) {
			int rd = get(7, 11, DX.IR);
			lock[rd]--;
		}
		FD.IR = 0;
		DX.IR = 0;
	}

	if (FD.IR) return;

	int a4 = memory[pc];
	int a3 = memory[pc + 1];
	int a2 = memory[pc + 2];
	int a1 = memory[pc + 3];
	FD.IR = link(a1, 8, a2, 8, a3, 8, a4, 8);
	if (FD.IR == 0x00c68223) stop = true;

	FD.NPC = pc + 4;

	if (pred.judge(pc)) {
		int tmp = FD.IR;
		int imm;
		if (isB(tmp)) {
			imm = link(get(31, 31, tmp), 1, get(7, 7, tmp), 1, get(25, 30, tmp), 6, get(8, 11, tmp), 4);
			imm = imm << 1;
			pc = pc + imm;
		}
		else if (isJ(tmp)) {
			imm = link(get(31, 31, tmp), 1, get(12, 19, tmp), 8, get(20, 20, tmp), 1, get(21, 30, tmp), 10);
			imm = imm << 1;
			pc = pc + imm;
		}
		else pc = pc + 4;
		FD.jump = true;
	}
	else {
		pc = pc + 4;
		FD.jump = false;
	}

}

void ID() {
	if (!FD.IR || DX.IR) return;
	int ir = FD.IR;

	_com* x = transcode(ir);
	if (!x->getreg()) {
		delete x;
		return;
	}
	delete x;

	DX.IR = FD.IR;
	DX.NPC = FD.NPC;
	DX.jump = FD.jump;

	FD.IR = 0;
}

void EX() {
	if (!DX.IR || XM.IR) return;

	int type = DX.type;
	int _vala = DX.A;
	int _valb = DX.B;
	int imm = DX.imm;
	int npc = DX.NPC;

	excecute(_vala, _valb, imm, npc, type);
	XM.IR = DX.IR;
	XM.type = DX.type;
	XM.jump = DX.jump;

	DX.IR = 0;
}

void MEM() {
	if (!XM.IR || MB.IR) return;

	switch (memcnt) {
	case 2:
		memcnt--;
		return;
	case 1:
		memcnt--;
		break;
	case 0:
		int type = XM.type;
		int ao = XM.AluOutput;

		int a1, a2, a3, a4, st;
		switch (type) {
		case 0: case 1: case 2: case 3: case 4:
		case 5: case 6: case 7: case 8: case 15: case 16:
		case 17: case 18: case 19: case 20: case 21:
		case 22: case 23: case 24: case 25: case 26:
			break;
		case 10: //LW
			a4 = memory[ao];
			a3 = memory[ao + 1];
			a2 = memory[ao + 2];
			a1 = memory[ao + 3];
			MB.LMD = link(a1, 8, a2, 8, a3, 8, a4, 8);
			memcnt = 2;
			return;
		case 11: //LH
			a4 = memory[ao];
			a3 = memory[ao + 1];
			MB.LMD = ulink(a3, 8, a4, 8) << 16 >> 16;
			memcnt = 2;
			return;
		case 12: //LHU
			a4 = memory[ao];
			a3 = memory[ao + 1];
			MB.LMD = ulink(a3, 8, a4, 8);
			memcnt = 2;
			return;
		case 13: //LB
			a4 = memory[ao];
			MB.LMD = a4 << 24 >> 24;
			memcnt = 2;
			return;
		case 14: //LBU
			a4 = memory[ao];
			MB.LMD = a4;
			memcnt = 2;
			return;
		case 34: case 35: case 36:
			st = XM.B;
			memory[ao] = get(0, 7, st);
			memory[ao + 1] = get(8, 15, st);
			memory[ao + 2] = get(16, 23, st);
			memory[ao + 3] = get(24, 31, st);
			memcnt = 2;
			return;
		case 9: case 27:
			break;
		case 28: case 29: case 30:
		case 31: case 32: case 33:
			break;
		}
	}

	MB.IR = XM.IR;
	MB.AluOutput = XM.AluOutput;
	MB.type = XM.type;

	XM.IR = 0;
}

void WB() {
	if (!MB.IR) return;

	count++;

	int type = MB.type;
	int ir = MB.IR;
	int ao = MB.AluOutput;

	int rd;
	rd = get(7, 11, ir);
	switch (type) {
	case 0: case 1: case 2: case 3: case 4:
	case 5: case 6: case 7: case 8: case 15: case 16:
	case 17: case 18: case 19: case 20: case 21:
	case 22: case 23: case 24: case 25: case 26:
		x[rd] = ao;
		lock[rd]--;
		break;
	case 10: case 11: case 12: case 13: case 14:
		x[rd] = MB.LMD;
		lock[rd]--;
		break;
	case 34: case 35: case 36:
		break;
	case 9: case 27: //JALR, JAL
		x[rd] = ao;
		lock[rd]--;
		break;
	case 28: case 29:case 30:
	case 31: case 32: case 33:
		break;
	}

	x[0] = 0;
	MB.IR = 0;
}

void display() {
	for (int i = 0; i < 32; ++i) {
		int s[32];
		unsigned int t = x[i];
		for (int j = 0; j < 32; ++j) {
			s[31 - j] = t % 2;
			t /= 2;
		}
		if (i >= 0 && i <= 9) printf("x[%d]:  ", i);
		else printf("x[%d]: ", i);
		for (int j = 0; j < 32; ++j) {
			printf("%d", s[j]);
			if (j % 4 == 3) printf(" ");
		}
		printf("\n");
	}
}
