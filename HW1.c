#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

static inline int count_leading_zeros(uint32_t x){
    if(!x){
        return 32;
    }
    int n = 32;
    int c=16;
    do{
        uint32_t y = x >> c;
        if(y){
            n -= c;
            x = y;
        }
        c >>= 1;
    } while(c);
    return n - x;
}

int* countBits(int n, int* returnSize) {
    *returnSize = n + 1;
    int* ans = (int*)malloc((n + 1) * sizeof(int));
    if(!ans){
        *returnSize = 0;
        return NULL;
    }
    ans[0] = 0;
    for (int i = 1; i <= n; i++) {
        int leading_zeros = count_leading_zeros((uint32_t)i);
        int highest_power_of_2 = 1 << (31 - leading_zeros);
        ans[i] = ans[i - highest_power_of_2] + 1;
    }
    return ans;
}

// test //
void print_array(const char* title, int* arr, int size) {
    printf("%s [", title);
    for (int i = 0; i < size; i++) {
        printf("%d", arr[i]);
        if (i < size - 1) {
            printf(", ");
        }
    }
    printf("]\n");
}

int main(void) {
    int returnSize;

    // test 1
    int n1 = 5;
    int* result1 = countBits(n1, &returnSize);
    print_array("Input n=5, Output:", result1, returnSize);
    free(result1);

    // test 2
    int n2 = 8;
    int* result2 = countBits(n2, &returnSize);
    print_array("Input n=8, Output:", result2, returnSize);
    free(result2);

    // test 3
    int n3 = 0;
    int* result3 = countBits(n3, &returnSize);
    print_array("Input n=0, Output:", result3, returnSize);
    free(result3);

    return 0;
}
