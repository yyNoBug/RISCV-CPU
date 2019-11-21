#ifndef STORAGE
#define STORAGE
#include <algorithm>
#include "ultility.hpp"

unsigned char memory[0x20000];

int x[32], pc;

struct predictor {
	short data[4096];
	int all, corr;
	bool judge(int addr) {
		int tmp = get(0, 11, addr);
		if (data[tmp] >= 2) return 1;
		else return 0;
	}

	void update(int addr, bool jump) {
		int tmp = get(0, 11, addr);
		++all;
		if (jump == judge(addr))
			++corr;
		if (jump) data[tmp] = std::min(3, data[tmp] + 1);
		else data[tmp] = std::max(0, data[tmp] - 1);
	}
	void ACC() {
		printf("%d %d %.7lf\n", all, corr, 1.0 * corr / all);
	}

} pred;


short lock[32];

struct regFD {
	int IR, NPC, jump;
} FD;

struct regDX {
	int IR, NPC, A, B, imm, type, jump;
} DX;

struct regXM {
	int IR, NPC, B, AluOutput, cond, type, jump;
} XM;

struct regMB {
	int IR, NPC, AluOutput, cond, type, LMD;
} MB;



#endif // !STORAGE
