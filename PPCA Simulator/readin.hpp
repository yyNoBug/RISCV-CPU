#ifndef READIN
#define READIN
#include <iostream>
#include "storage.hpp"

int getChar() {
	while (1) {
		char c = getchar();
		if (c >= '0' && c <= '9') return c - '0';
		if (c >= 'A' && c <= 'F') return c - 'A' + 10;
		if (c == '@') return 16;
		if (c == EOF) return -1;
	}
}

int get0x() {
	int a, b;
	a = getChar(); if (a == 16) return 256; if (a == -1) return -1;
	b = getChar(); if (b == 16) throw 1; if (b == -1) throw 2;
	return (a << 4) | b;
}

void fetch() {
	int lab = get0x();

	while (1) {
		int loc; scanf("%x", &loc);
		while (1) {
			lab = get0x(); if (lab == 256) break; if (lab == -1) return;
			memory[loc++] = lab;
		}
	}
}

#endif // !READIN
