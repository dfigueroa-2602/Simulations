#include "stdafx.h"
#include "Control.h"

#define ConstMATH_PI        3.1415926535897932384626433832795
#define ConstMATH_SQRT3     1.7320508075688772935274463415059
#define ConstMATH_SQRT2     1.4142135623730950488016887242097

const float MATH_PI = ConstMATH_PI;
const float MATH_2PI = ConstMATH_PI * 2.0;
const float MATH_2PI_3 = ConstMATH_PI * 2.0 / 3.0;
const float MATH_PI_3 = ConstMATH_PI / 3.0;
const float MATH_1_2PI = 1.0 / (ConstMATH_PI * 2.0);
const float MATH_1_PI = 1.0 / ConstMATH_PI;
const float MATH_1_3 = 1.0 / 3.0;
const float MATH_1_SQRT3 = 1.0 / ConstMATH_SQRT3;
const float MATH_1_SQRT2 = 1.0 / ConstMATH_SQRT2;
const float MATH_SQRT2_3 = ConstMATH_SQRT2 / 3.0;
const float MATH_SQRT3_2 = ConstMATH_SQRT3 / 2.0;
const float MATH_SQRT2 = ConstMATH_SQRT2;
const float MATH_SQRT3 = ConstMATH_SQRT3;
const float MATH_1_2 = 1.0 / 2.0;
const float MATH_2_3 = 2.0 / 3.0;

/* Definition of the LQR controller void lqrControl(const double x[n. states], double u[n. inputs]) */
void lqrControl(const double x[14], double u[2])
{
    /* u = -K * x */
    u[0] = 0.0;
    u[1] = 0.0;
    
    /* For each state, assign each input as the multiplication of the column of that state times the state*/
    for (int j = 0; j < 14; ++j) {
        u[0] -= K_LQR[0][j] * x[j];
        u[1] -= K_LQR[1][j] * x[j];
    }
}

void resonantSystem(const float e[2],
                    float rho_k[8],
                    float rho_k_1[8])
{
    rho_k_1[0] = Ard[0][0] * rho_k[0] + Ard[0][1] * rho_k[1] + Ard[0][2] * rho_k[2] + Ard[0][3] * rho_k[3] + Ard[0][4] * rho_k[4] + Ard[0][5] * rho_k[5] + Ard[0][6] * rho_k[6] + Ard[0][7] * rho_k[7] + Brd[0][0] * e[0] + Brd[0][1] * e[1];
    rho_k_1[1] = Ard[1][0] * rho_k[0] + Ard[1][1] * rho_k[1] + Ard[1][2] * rho_k[2] + Ard[1][3] * rho_k[3] + Ard[1][4] * rho_k[4] + Ard[1][5] * rho_k[5] + Ard[1][6] * rho_k[6] + Ard[1][7] * rho_k[7] + Brd[1][0] * e[0] + Brd[1][1] * e[1];
    rho_k_1[2] = Ard[2][0] * rho_k[0] + Ard[2][1] * rho_k[1] + Ard[2][2] * rho_k[2] + Ard[2][3] * rho_k[3] + Ard[2][4] * rho_k[4] + Ard[2][5] * rho_k[5] + Ard[2][6] * rho_k[6] + Ard[2][7] * rho_k[7] + Brd[2][0] * e[0] + Brd[2][1] * e[1];
    rho_k_1[3] = Ard[3][0] * rho_k[0] + Ard[3][1] * rho_k[1] + Ard[3][2] * rho_k[2] + Ard[3][3] * rho_k[3] + Ard[3][4] * rho_k[4] + Ard[3][5] * rho_k[5] + Ard[3][6] * rho_k[6] + Ard[3][7] * rho_k[7] + Brd[3][0] * e[0] + Brd[3][1] * e[1];
    rho_k_1[4] = Ard[4][0] * rho_k[0] + Ard[4][1] * rho_k[1] + Ard[4][2] * rho_k[2] + Ard[4][3] * rho_k[3] + Ard[4][4] * rho_k[4] + Ard[4][5] * rho_k[5] + Ard[4][6] * rho_k[6] + Ard[4][7] * rho_k[7] + Brd[4][0] * e[0] + Brd[4][1] * e[1];
    rho_k_1[5] = Ard[5][0] * rho_k[0] + Ard[5][1] * rho_k[1] + Ard[5][2] * rho_k[2] + Ard[5][3] * rho_k[3] + Ard[5][4] * rho_k[4] + Ard[5][5] * rho_k[5] + Ard[5][6] * rho_k[6] + Ard[5][7] * rho_k[7] + Brd[5][0] * e[0] + Brd[5][1] * e[1];
    rho_k_1[6] = Ard[6][0] * rho_k[0] + Ard[6][1] * rho_k[1] + Ard[6][2] * rho_k[2] + Ard[6][3] * rho_k[3] + Ard[6][4] * rho_k[4] + Ard[6][5] * rho_k[5] + Ard[6][6] * rho_k[6] + Ard[6][7] * rho_k[7] + Brd[6][0] * e[0] + Brd[6][1] * e[1];
    rho_k_1[7] = Ard[7][0] * rho_k[0] + Ard[7][1] * rho_k[1] + Ard[7][2] * rho_k[2] + Ard[7][3] * rho_k[3] + Ard[7][4] * rho_k[4] + Ard[7][5] * rho_k[5] + Ard[7][6] * rho_k[6] + Ard[7][7] * rho_k[7] + Brd[7][0] * e[0] + Brd[7][1] * e[1];
}

/* At the end of the Output loop, save the actual value as the last value*/
void variablesUpdate()
{
    var_Control_struct.States.u_k[0] = var_Control_struct.Output.m_k_alphabeta.alpha;
    var_Control_struct.States.u_k[1] = var_Control_struct.Output.m_k_alphabeta.beta;

    var_Control_struct.States.rho_k[0] = var_Control_struct.States.rho_k_1[0];
    var_Control_struct.States.rho_k[1] = var_Control_struct.States.rho_k_1[1];
    var_Control_struct.States.rho_k[2] = var_Control_struct.States.rho_k_1[2];
    var_Control_struct.States.rho_k[3] = var_Control_struct.States.rho_k_1[3];
    var_Control_struct.States.rho_k[4] = var_Control_struct.States.rho_k_1[4];
    var_Control_struct.States.rho_k[5] = var_Control_struct.States.rho_k_1[5];
    var_Control_struct.States.rho_k[6] = var_Control_struct.States.rho_k_1[6];
    var_Control_struct.States.rho_k[7] = var_Control_struct.States.rho_k_1[7];
}