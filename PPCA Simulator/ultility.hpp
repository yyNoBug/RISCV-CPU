#ifndef ULTILITY
#define ULTILITY

#include <iostream>
#include <cstring>
#include <vector>

int get(int l, int r, int num) {   //0-base
	return (num >> l) & ((1 << (r - l + 1)) - 1);
}

int link(int a, int la, int b, int lb) {
	return (((a << lb) | b) << (32 - la - lb)) >> (32 - la - lb);
}

int ulink(int a, int la, int b, int lb) {
	return ((a << lb) | b);
}

int link(int a, int la, int b, int lb, int c, int lc) {
	return (((((a << lb) | b ) << lc) | c) << (32 - la - lb - lc)) >> (32 - la - lb - lc);
}

int link(int a, int la, int b, int lb, int c, int lc, int d, int ld) {
	return (((((((a << lb) | b) << lc) | c) << ld) | d) << (32 - la - lb - lc - ld)) >> (32 - la - lb - lc - ld);
}

/*
struct binaryString {

	int val;

	binaryString(int _val) {
		val = _val;
	}

	binaryString(char* a) { //从16进制转换
		int len = strlen(a);
		char* p = new char[len + 3];
		p[0] = '0'; p[1] = 'x';
		for (int i = 0; i < len; ++i) {
			p[i + 2] = a[i];
		}
		p[len + 2] = '\0';
		sscanf(p, "%x", &val);
	}

	binaryString(bool* str, int size) {  //从2进制转换
		val = 0;
		for (int i = 0; i < size; ++i) {
			val *= 2;
			val += str[i];
		}
	}

	operator char* () const {
		int cur = 0;
		int len = log(val) + 1;
		char* ans = new char[len] + 1;
		for (int i = 0; i < 5; ++i) {

		}
	}

	bool operator == (const binaryString& other) {
		return val == other.val;
	}

	binaryString operator+ (const binaryString& other) {
		return binaryString(val + other.val);
	}
};

int convertBinary(bool* str, int size) {
	int s = 0;
	for (int i = 0; i < size; ++i) {
		s *= 2;
		s += str[i];
	}
	return s;
}
*/


#endif // !ULTILITY