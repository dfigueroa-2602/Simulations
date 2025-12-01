#include "stdafx.h"

#pragma once
#ifndef Control_H_
#define Control_H_

extern const float MATH_PI;
extern const float MATH_2PI;
extern const float MATH_1_3;
extern const float MATH_1_SQRT3;

#define abc_alphabeta(alphabeta_struct, abc_struct)                                                 \
{                                                                                                   \
    alphabeta_struct.alpha = (2.0f*abc_struct.a - abc_struct.b - abc_struct.c) * MATH_1_3;          \
    alphabeta_struct.beta = (abc_struct.b - abc_struct.c) * MATH_1_SQRT3;                           \
}                                                                                                   

#define alphabeta_dq(dq_struct, alphabeta_struct, sin, cos)                                         \
{                                                                                                   \
    register float temp_cos = cos;                                                                  \
    register float temp_sin = sin;                                                                  \
    dq_struct.d = temp_cos * alphabeta_struct.alpha + temp_sin * alphabeta_struct.beta;             \
    dq_struct.q = -temp_sin * alphabeta_struct.alpha + temp_cos * alphabeta_struct.beta;            \
}

void lqrControl(const double x[8], double u[2]);

struct PLL_struct{
    float theta_k_1;
    float theta_k;
};

struct Control_struct{
    float xd_k_1;
    float xq_k_1;
    float xd_k;
    float xq_k;
};

extern struct Control_struct var_Control_struct;
extern struct PLL_struct var_PLL_struct;

#endif /* Control_H_ */