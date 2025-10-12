#include <stdio.h>
#include <stdint.h>

/* 正確的 32-bit clz（不依賴內建函式） */
static inline int count_leading_zeros(uint32_t x) {
    if (x == 0) return 32;
    int n = 0;
    if ((x & 0xFFFF0000u) == 0) { n += 16; x <<= 16; }
    if ((x & 0xFF000000u) == 0) { n +=  8; x <<=  8; }
    if ((x & 0xF0000000u) == 0) { n +=  4; x <<=  4; }
    if ((x & 0xC0000000u) == 0) { n +=  2; x <<=  2; }
    if ((x & 0x80000000u) == 0) { n +=  1; }
    return n;
}

/* 由呼叫端提供緩衝區，不做動態配置 */
int countBits_fill(int n, int *ans) {
    ans[0] = 0;
    for (int i = 1; i <= n; ++i) {
        int lz  = count_leading_zeros((uint32_t)i);
        int hp2 = 1 << (31 - lz);      // 最高位的 2^k
        ans[i]  = ans[i - hp2] + 1;
    }
    return n + 1;
}

static void print_array(const char* title, const int* arr, int size) {
    printf("%s [", title);
    for (int i = 0; i < size; i++) {
        printf("%d", arr[i]);
        if (i < size - 1) printf(", ");
    }
    printf("]\n");
}

int main(void) {
    int returnSize;

    /* test 1 */
    {
        enum { N1 = 5 };
        int result1[N1 + 1];
        returnSize = countBits_fill(N1, result1);
        print_array("Input n=5, Output:", result1, returnSize);
    }

    /* test 2 */
    {
        enum { N2 = 8 };
        int result2[N2 + 1];
        returnSize = countBits_fill(N2, result2);
        print_array("Input n=8, Output:", result2, returnSize);
    }

    /* test 3 */
    {
        enum { N3 = 0 };
        int result3[N3 + 1];
        returnSize = countBits_fill(N3, result3);
        print_array("Input n=0, Output:", result3, returnSize);
    }

    return 0;
}
