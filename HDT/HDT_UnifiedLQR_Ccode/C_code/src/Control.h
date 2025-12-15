#include "stdafx.h"
#include "Coordinates.h"

#pragma once
#ifndef Control_H_
#define Control_H_

extern const float MATH_PI;
extern const float MATH_2PI;
extern const float MATH_1_2;
extern const float MATH_1_3;
extern const float MATH_SQRT3;
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

#define dq_alphabeta(alphabeta_struct, dq_struct, sin, cos)                                         \
{                                                                                                   \
    register float temp_cos = cos;                                                                  \
    register float temp_sin = sin;                                                                  \
    alphabeta_struct.alpha = temp_cos * dq_struct.d - temp_sin * dq_struct.q;                       \
    alphabeta_struct.beta  = temp_sin * dq_struct.d + temp_cos * dq_struct.q;                       \
}

#define alphabeta_abc(abc_struct, alphabeta_struct)                                                 \
{                                                                                                   \
    abc_struct.a = alphabeta_struct.alpha;                                                          \
    abc_struct.b = (-alphabeta_struct.alpha + MATH_SQRT3 * alphabeta_struct.beta) * MATH_1_2;       \
    abc_struct.c = (-alphabeta_struct.alpha - MATH_SQRT3 * alphabeta_struct.beta) * MATH_1_2;       \
}

void lqrControl(const double x[10], const double xd[4], const double xr[32], double u[4]);
void resonantSystem(const float e_k[4],
                    float rho_k[32],
                    float rho_k_1[32]);
void variablesUpdate(void);

struct PLL_struct{
    float theta_k_1;
    float theta_k;
};

struct Control_struct{
    struct{
        float rho_k[32];
        float rho_k_1[32];
        float e_k[4];
        float x_k[10];
        float u_k[4];
    } States;

    struct{
        struct alphabeta_struct ms_k_alphabeta;
        struct alphabeta_struct mp_k_alphabeta;
        struct alphabeta_struct us_alphabeta;
        struct alphabeta_struct up_alphabeta;
        struct abc_struct us_abc;
        struct abc_struct up_abc;
    } Output;
};

extern struct Control_struct var_Control_struct;

#endif /* Control_H_ */