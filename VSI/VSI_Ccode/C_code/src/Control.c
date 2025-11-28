#include "stdafx.h"

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
const float MATH_2_3 = 2.0 / 3.0;

/* Definition of the LQR controller void lqrControl(const double x[n. states], double u[n. inputs]) */
void lqrControl(const double x[6], double u[2])
{
    /* u = -K * x */
    u[0] = 0.0;
    u[1] = 0.0;
    
    /* For each state, assign each input as the multiplication of the column of that state times the state*/
    for (int j = 0; j < 6; ++j) {
        u[0] -= K_LQR[0][j] * x[j];
        u[1] -= K_LQR[1][j] * x[j];
    }
}