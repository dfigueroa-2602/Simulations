#include "stdafx.h"
#include "stddef.h"
#include "Control.h"
#include "Converter.h"

DLLEXPORT void plecsSetSizes(struct SimulationSizes* aSizes)
{
    aSizes->numInputs     = 26; /* DLL inputs */
    aSizes->numOutputs    = 7;  /* control outputs u */
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
    for (int i = 0; i < 7; ++i)
        aState->outputs[i] = 0.0;
}

/* Called at each sample time */
DLLEXPORT void plecsOutput(struct SimulationState* aState)
{   
    /* Read inputs */
    Meas.ifs.a      = (float)aState->inputs[0];
    Meas.ifs.b      = (float)aState->inputs[1];
    Meas.ifs.c      = (float)aState->inputs[2];
    Meas.vcs.a      = (float)aState->inputs[3];
    Meas.vcs.b      = (float)aState->inputs[4];
    Meas.vcs.c      = (float)aState->inputs[5];
    Meas.ifp.a      = (float)aState->inputs[6];
    Meas.ifp.b      = (float)aState->inputs[7];
    Meas.ifp.c      = (float)aState->inputs[8];
    Meas.iY.a       = (float)aState->inputs[9];
    Meas.iY.b       = (float)aState->inputs[10];
    Meas.iY.c       = (float)aState->inputs[11];
    Meas.vcp.a      = (float)aState->inputs[12];
    Meas.vcp.b      = (float)aState->inputs[13];
    Meas.vcp.c      = (float)aState->inputs[14];
    Meas.vg.a       = (float)aState->inputs[15];
    Meas.vg.b       = (float)aState->inputs[16];
    Meas.vg.c       = (float)aState->inputs[17];
    Meas.iL.a       = (float)aState->inputs[18];
    Meas.iL.b       = (float)aState->inputs[19];
    Meas.iL.c       = (float)aState->inputs[20];
    Meas.Vdc        = (float)aState->inputs[21];
    float vcsalpha_ref  = (float)aState->inputs[22];
    float vcsbeta_ref   = (float)aState->inputs[23];
    float ifpalpha_ref  = (float)aState->inputs[24];
    float ifpbeta_ref   = (float)aState->inputs[25];

    /* Sample time from parameters */
    double Ts = aState->parameters[0];

    /* Build needed structs */
    struct alphabeta_struct ifs_ab;
    struct alphabeta_struct vcs_ab;
    struct alphabeta_struct ifp_ab;
    struct alphabeta_struct iY_ab;
    struct alphabeta_struct vcp_ab;
    struct alphabeta_struct es_k_ab;
    struct alphabeta_struct ep_k_ab;

    abc_alphabeta(ifs_ab, Meas.ifs);
    abc_alphabeta(vcs_ab, Meas.vcs);
    abc_alphabeta(ifp_ab, Meas.ifp);
    abc_alphabeta(iY_ab,  Meas.iY);
    abc_alphabeta(vcp_ab, Meas.vcp);

    /* Error Calculation */
    es_k_ab.alpha = vcsalpha_ref - vcs_ab.alpha;
    es_k_ab.beta  = vcsbeta_ref  - vcs_ab.beta;
    ep_k_ab.alpha = ifpalpha_ref - ifp_ab.alpha;
    ep_k_ab.beta  = ifpbeta_ref  - ifp_ab.beta;

    var_Control_struct.States.e_k[0] = es_k_ab.alpha;
    var_Control_struct.States.e_k[1] = es_k_ab.beta;
    var_Control_struct.States.e_k[2] = ep_k_ab.alpha;
    var_Control_struct.States.e_k[3] = ep_k_ab.beta;

    resonantSystem(var_Control_struct.States.e_k, var_Control_struct.States.rho_k, var_Control_struct.States.rho_k_1);

    double x[10]; double xd[4]; double xr[32]; double u[4];

    x[0] = (double)ifs_ab.alpha;
    x[1] = (double)ifs_ab.beta;
    x[2] = (double)vcs_ab.alpha;
    x[3] = (double)vcs_ab.beta;
    x[4] = (double)ifp_ab.alpha;
    x[5] = (double)ifp_ab.beta;
    x[6] = (double)iY_ab.alpha;
    x[7] = (double)iY_ab.beta;
    x[8] = (double)vcp_ab.alpha;
    x[9] = (double)vcp_ab.beta;
    xd[0] = var_Control_struct.States.u_k[0];
    xd[1] = var_Control_struct.States.u_k[1];
    xd[2] = var_Control_struct.States.u_k[2];
    xd[3] = var_Control_struct.States.u_k[3];
    xr[0] = var_Control_struct.States.rho_k[0];
    xr[1] = var_Control_struct.States.rho_k[1];
    xr[2] = var_Control_struct.States.rho_k[2];
    xr[3] = var_Control_struct.States.rho_k[3];
    xr[4] = var_Control_struct.States.rho_k[4];
    xr[5] = var_Control_struct.States.rho_k[5];
    xr[6] = var_Control_struct.States.rho_k[6];
    xr[7] = var_Control_struct.States.rho_k[7];
    xr[8] = var_Control_struct.States.rho_k[8];
    xr[9] = var_Control_struct.States.rho_k[9];
    xr[10] = var_Control_struct.States.rho_k[10];
    xr[11] = var_Control_struct.States.rho_k[11];
    xr[12] = var_Control_struct.States.rho_k[12];
    xr[13] = var_Control_struct.States.rho_k[13];
    xr[14] = var_Control_struct.States.rho_k[14];
    xr[15] = var_Control_struct.States.rho_k[15];
    xr[16] = var_Control_struct.States.rho_k[16];
    xr[17] = var_Control_struct.States.rho_k[17];
    xr[18] = var_Control_struct.States.rho_k[18];
    xr[19] = var_Control_struct.States.rho_k[19];
    xr[20] = var_Control_struct.States.rho_k[20];
    xr[21] = var_Control_struct.States.rho_k[21];
    xr[22] = var_Control_struct.States.rho_k[22];
    xr[23] = var_Control_struct.States.rho_k[23];
    xr[24] = var_Control_struct.States.rho_k[24];
    xr[25] = var_Control_struct.States.rho_k[25];
    xr[26] = var_Control_struct.States.rho_k[26];
    xr[27] = var_Control_struct.States.rho_k[27];
    xr[28] = var_Control_struct.States.rho_k[28];
    xr[29] = var_Control_struct.States.rho_k[29];
    xr[30] = var_Control_struct.States.rho_k[30];
    xr[31] = var_Control_struct.States.rho_k[31];

    /* Compute LQR control */
    lqrControl(x, xd, xr, u);

    var_Control_struct.Output.ms_k_alphabeta.alpha = u[0];
    var_Control_struct.Output.ms_k_alphabeta.beta  = u[1];
    var_Control_struct.Output.mp_k_alphabeta.alpha = u[2];
    var_Control_struct.Output.mp_k_alphabeta.beta  = u[3];

    float ms_alpha = var_Control_struct.Output.ms_k_alphabeta.alpha;
    float ms_beta  = var_Control_struct.Output.ms_k_alphabeta.beta;
    float mp_alpha = var_Control_struct.Output.mp_k_alphabeta.alpha;
    float mp_beta  = var_Control_struct.Output.mp_k_alphabeta.beta;

    float m_sat = 700.0f;
    if (ms_alpha >  m_sat) ms_alpha =  m_sat;
    if (ms_alpha < -m_sat) ms_alpha = -m_sat;
    if (ms_beta  >  m_sat) ms_beta  =  m_sat;
    if (ms_beta  < -m_sat) ms_beta  = -m_sat;
    if (mp_alpha >  m_sat) mp_alpha =  m_sat;
    if (mp_alpha < -m_sat) mp_alpha = -m_sat;
    if (mp_beta  >  m_sat) mp_beta  =  m_sat;
    if (mp_beta  < -m_sat) mp_beta  = -m_sat;

    var_Control_struct.States.u_k[0] = ms_alpha;
    var_Control_struct.States.u_k[1] = ms_beta;
    var_Control_struct.States.u_k[2] = mp_alpha;
    var_Control_struct.States.u_k[3] = mp_beta;

    var_Control_struct.Output.us_alphabeta.alpha = var_Control_struct.States.u_k[0];
    var_Control_struct.Output.us_alphabeta.beta  = var_Control_struct.States.u_k[1];
    var_Control_struct.Output.up_alphabeta.alpha = var_Control_struct.States.u_k[2];
    var_Control_struct.Output.up_alphabeta.beta  = var_Control_struct.States.u_k[3];

    alphabeta_abc(var_Control_struct.Output.us_abc, var_Control_struct.Output.us_alphabeta);
    alphabeta_abc(var_Control_struct.Output.up_abc, var_Control_struct.Output.up_alphabeta);

    /* With the given actuaction, create the duty cycle that will be given to the 2L inverter*/
    Converter_2L_minmax(&var_Control_struct.Output.us_abc, Meas.Vdc, &conv_s.duty);
    Converter_2L_minmax(&var_Control_struct.Output.up_abc, Meas.Vdc, &conv_p.duty);
    
    /* Assign the duty cycle to the outputs */
    aState_global->outputs[0] = conv_s.duty.a;
    aState_global->outputs[1] = conv_s.duty.b;
    aState_global->outputs[2] = conv_s.duty.c;
    aState_global->outputs[3] = conv_p.duty.a;
    aState_global->outputs[4] = conv_p.duty.b;
    aState_global->outputs[5] = conv_p.duty.c;

    aState_global->outputs[6] = 0.0f;

    /* Store updated integrator states */
    variablesUpdate();
}

/* Called once at end of simulation */
DLLEXPORT void plecsTerminate(struct SimulationState* aState)
{
    (void)aState;
}