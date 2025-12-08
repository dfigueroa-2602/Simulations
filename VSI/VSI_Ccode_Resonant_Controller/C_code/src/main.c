#include "stdafx.h"
#include "stddef.h"
#include "Control.h"
#include "Converter.h"

DLLEXPORT void plecsSetSizes(struct SimulationSizes* aSizes)
{
    aSizes->numInputs     = 9; /* DLL inputs */
    aSizes->numOutputs    = 4;  /* control outputs u */
    aSizes->numStates     = 0;  /* discrete states inside DLL. Increase when you want to integrate something inside */
    aSizes->numParameters = 1;  /* user parameters that will be used inside the DLL */
}

/* Called once at the beginning of a simulation */
DLLEXPORT void plecsStart(struct SimulationState* aState)
{
    aState_global = aState;

    /* Initialization of the integrators initial constants*/
    memset(&var_Control_struct, 0, sizeof(var_Control_struct));

    /* Initialize outputs to 0 */
    for (int i = 0; i < 3; ++i)
        aState->outputs[i] = 0.0;
}

/* Called at each sample time */
DLLEXPORT void plecsOutput(struct SimulationState* aState)
{   
    /* Read inputs */
    Meas.Vdc        = aState->inputs[0];
    Meas.is.a       = (float)aState->inputs[1];
    Meas.is.b       = (float)aState->inputs[2];
    Meas.is.c       = (float)aState->inputs[3];
    Meas.vc.a       = (float)aState->inputs[4];
    Meas.vc.b       = (float)aState->inputs[5];
    Meas.vc.c       = (float)aState->inputs[6];
    float vcalpha_ref   = (float)aState->inputs[7];
    float vcbeta_ref   = (float)aState->inputs[8];

    /* Sample time from parameters */
    double Ts = aState->parameters[0];

    /* Build needed structs */
    struct alphabeta_struct if_ab;
    struct alphabeta_struct vc_ab;
    struct alphabeta_struct e_k_ab;
    struct dq_struct        if_dq;
    struct dq_struct        vc_dq;

    /* Clarke Transform */
    abc_alphabeta(if_ab, Meas.is);
    abc_alphabeta(vc_ab, Meas.vc);

    /* Error Calculation */
    e_k_ab.alpha = vcalpha_ref - vc_ab.alpha;
    e_k_ab.beta = vcbeta_ref - vc_ab.beta;

    var_Control_struct.States.e[0] = e_k_ab.alpha;
    var_Control_struct.States.e[1] = e_k_ab.beta;

    resonantSystem(var_Control_struct.States.e, var_Control_struct.States.rho_k, var_Control_struct.States.rho_k_1);

    double x[14]; double u[2];

    /* x = [ifalpha ifbeta vcalpha vcbeta vsalpha_k vsbeta_k rho_0 rho_1 rho_2 rho_3]*/

    x[0] = (double)if_ab.alpha;
    x[1] = (double)if_ab.beta;
    x[2] = (double)vc_ab.alpha;
    x[3] = (double)vc_ab.beta;
    x[4] = var_Control_struct.States.u_k[0];
    x[5] = var_Control_struct.States.u_k[1];
    x[6] = var_Control_struct.States.rho_k[0];
    x[7] = var_Control_struct.States.rho_k[1];
    x[8] = var_Control_struct.States.rho_k[2];
    x[9] = var_Control_struct.States.rho_k[3];
    x[10] = var_Control_struct.States.rho_k[4];
    x[11] = var_Control_struct.States.rho_k[5];
    x[12] = var_Control_struct.States.rho_k[6];
    x[13] = var_Control_struct.States.rho_k[7];

    /* Compute LQR control */
    lqrControl(x, u);

    var_Control_struct.Output.m_k_alphabeta.alpha = u[0];
    var_Control_struct.Output.m_k_alphabeta.beta = u[1];

    float m_alpha = var_Control_struct.Output.m_k_alphabeta.alpha;
    float m_beta  = var_Control_struct.Output.m_k_alphabeta.beta;

    float m_sat = 540.0f;
    if (m_alpha >  m_sat) m_alpha =  m_sat;
    if (m_alpha < -m_sat) m_alpha = -m_sat;
    if (m_beta  >  m_sat) m_beta  =  m_sat;
    if (m_beta  < -m_sat) m_beta  = -m_sat;

    var_Control_struct.States.u_k[0] = m_alpha;
    var_Control_struct.States.u_k[1] = m_beta;

    var_Control_struct.Output.u_alphabeta.alpha = var_Control_struct.States.u_k[0];
    var_Control_struct.Output.u_alphabeta.beta = var_Control_struct.States.u_k[1];

    alphabeta_abc(var_Control_struct.Output.u_abc, var_Control_struct.Output.u_alphabeta);

    /* With the given actuaction, create the duty cycle that will be given to the 2L inverter*/
    Converter_2L_minmax();
    
    /* Assign the duty cycle to the outputs */
    aState_global->outputs[0] = conv.duty.a;
    aState_global->outputs[1] = conv.duty.b;
    aState_global->outputs[2] = conv.duty.c;

    aState_global->outputs[3] = var_Control_struct.States.u_k[0];

    /* Store updated integrator states */
    variablesUpdate();
}

/* Called once at end of simulation */
DLLEXPORT void plecsTerminate(struct SimulationState* aState)
{
    (void)aState;
}