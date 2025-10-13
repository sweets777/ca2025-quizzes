#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

static bool parse_b16(const char *s, uint16_t *out){
    if (!s || strlen(s) != 16) return false;
    uint16_t v = 0;
    for (int i = 0; i < 16; i++){
        char c = s[i];
        if (c != '0' && c != '1') return false;
        v <<= 1;
        if (c == '1') v |= 1;
    *out = v;
    }
    return true;
}

static double bf16bits_to_double(uint16_t bits){
    int sign = (bits >> 15) & 1;
    int exp  = (bits >> 7)  & 0xFF;
    int mant = bits & 0x7F;

    if (exp == 0xFF){                    // Inf / NaN
        if (mant == 0) return sign ? -INFINITY : INFINITY;
        return NAN;
    }
    if (exp == 0){                       // Zero / Subnormal
        if (mant == 0) return sign ? -0.0 : 0.0;
        double frac = (double)mant / 128.0;
        double val  = ldexp(frac, 1 - 127);
        return sign ? -val : val;
    }
    double frac = 1.0 + (double)mant / 128.0;
    double val  = ldexp(frac, exp - 127);
    return sign ? -val : val;
}

static double bf16_binstr_to_double(const char *b16){
    uint16_t bits;
    if (!parse_b16(b16, &bits)) return NAN;
    return bf16bits_to_double(bits);
}

static void print_decimal(double x){
    if (isnan(x)) { printf("NaN\n"); return; }
    if (isinf(x)) { printf("%sinf\n", signbit(x) ? "-" : "+"); return; }
    if (x == 0.0 && signbit(x)) { printf("-0\n"); return; }
    printf("%.12g\n", x);
}

int main(void){
    const char *tests[3] ={
        "0011111110000000",
        "1011111110000000",
        "0000000000000001"
    };
    for(int i = 0; i < 3; i++){
        double val = bf16_binstr_to_double(tests[i]);
        printf("Case %d: %s -> ", i + 1, tests[i]);
        print_decimal(val);
    }
    return 0;
}
