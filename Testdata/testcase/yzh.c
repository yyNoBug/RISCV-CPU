#include "io.h"

int f(int x, int y) {
	if (y == 1) return x;
	if (y == 0) return 1;
	return f(x, y / 2) * f(x, (y + 1) / 2);
}

int main() {
	outl(f(2, 15));
}