#include "stdafx.h"
#include "Control.h"
#include "stddef.h"

DLLEXPORT void plecsSetSizes(struct SimulationSizes* aSizes)
{
    aSizes->numInputs     = 11; /* DLL inputs */
    aSizes->numOutputs    = 2;  /* control outputs u */
    aSizes->numStates     = 0;  /* discrete states inside DLL. Increase when you want to integrate something inside */
    aSizes->numParameters = 1;  /* user parameters that will be used inside the DLL */
}

/* Called once at the beginning of a simulation */
DLLEXPORT void plecsStart(struct SimulationState* aState)
{
    aState_global = aState;

    /* Initialization of the integrators initial constants*/
    memset(&var_PLL_struct, 0, sizeof(var_PLL_struct));
    memset(&var_Control_struct, 0, sizeof(var_Control_struct));

    var_PLL_struct.theta_k = var_PLL_struct.theta_k_1;
    var_Control_struct.xd_k = var_Control_struct.xd_k_1;
    var_Control_struct.xq_k = var_Control_struct.xq_k_1;

    /* Initialize outputs to 0 */
    for (int i = 0; i < 2; ++i)
        aState->outputs[i] = 0.0;
}

/* Called at each sample time */
DLLEXPORT void plecsOutput(struct SimulationState* aState)
{   
    /* Read inputs */
    double w  = aState->inputs[0];

    float ifa = (float)aState->inputs[1];
    float ifb = (float)aState->inputs[2];
    float ifc = (float)aState->inputs[3];
    float vca = (float)aState->inputs[4];
    float vcb = (float)aState->inputs[5];
    float vcc = (float)aState->inputs[6];
    float vsd_k = (float)aState->inputs[7];
    float vsq_k = (float)aState->inputs[8];
    float vcd_ref = (float)aState->inputs[9];
    float vcq_ref = (float)aState->inputs[10];

    /* Sample time from parameters */
    double Ts = aState->parameters[0];

    /* Integrate w to get electrical angle theta */
    var_PLL_struct.theta_k_1 = var_PLL_struct.theta_k + w * Ts;

    /* wrap angle to [-pi, pi] */
    if (var_PLL_struct.theta_k_1 > MATH_PI)
        var_PLL_struct.theta_k_1 -= 2.0 * MATH_PI;
    else if (var_PLL_struct.theta_k_1 < -MATH_PI)
        var_PLL_struct.theta_k_1 += 2.0 * MATH_PI;

    double sin_theta = sin(var_PLL_struct.theta_k);
    double cos_theta = cos(var_PLL_struct.theta_k);

    /* Build abc structs */
    struct abc_struct if_abc;
    if_abc.a = ifa;
    if_abc.b = ifb;
    if_abc.c = ifc;

    struct abc_struct vc_abc;
    vc_abc.a = vca;
    vc_abc.b = vcb;
    vc_abc.c = vcc;

    struct alphabeta_struct if_ab;
    struct alphabeta_struct vc_ab;
    struct dq_struct        if_dq;
    struct dq_struct        vc_dq;

    /* Clarke Transform */
    abc_alphabeta(if_ab, if_abc);
    abc_alphabeta(vc_ab, vc_abc);

    /* Park Transform */
    alphabeta_dq(if_dq, if_ab, sin_theta, cos_theta);
    alphabeta_dq(vc_dq, vc_ab, sin_theta, cos_theta);

    /* Error Calculation */
    double ed_k = vcd_ref - vc_dq.d;
    double eq_k = vcq_ref - vc_dq.q;

    var_Control_struct.xd_k_1 = var_Control_struct.xd_k + ed_k * Ts;
    var_Control_struct.xq_k_1 = var_Control_struct.xq_k + eq_k * Ts;

    double x[8]; double u[2];

    x[0] = (double)if_dq.d;
    x[1] = (double)if_dq.q;
    x[2] = (double)vc_dq.d;
    x[3] = (double)vc_dq.q;
    x[4] = (double)vsd_k;
    x[5] = (double)vsq_k;
    x[6] = var_Control_struct.xd_k;
    x[7] = var_Control_struct.xq_k;

    /* Compute LQR control */
    lqrControl(x, u);

    /* Write outputs */
    aState->outputs[0] = u[0]; 
    aState->outputs[1] = u[1];

    /* Store updated integrator states */
    var_PLL_struct.theta_k = var_PLL_struct.theta_k_1;
    var_Control_struct.xd_k = var_Control_struct.xd_k_1;
    var_Control_struct.xq_k = var_Control_struct.xq_k_1;
}

/* Called once at end of simulation */
DLLEXPORT void plecsTerminate(struct SimulationState* aState)
{
    (void)aState;
}