#include "stdafx.h"
#include "Control.h"
#include "Converter.h"

/* Function to create the minmax injection for the 2L inverter */
void Converter_2L_minmax(void)
{
    float a = var_Control_struct.Output.u_abc.a;
    float b = var_Control_struct.Output.u_abc.b;
    float c = var_Control_struct.Output.u_abc.c;

    float m_max = fmaxf(a, fmaxf(b, c));
    float m_min = fminf(a, fminf(b, c));
    float minmax = -0.5f * (m_min + m_max);

    a += minmax;
    b += minmax;
    c += minmax;

    register float div_Vdc = 1.0f / fmaxf(Meas.Vdc, 0.01f);

    conv.duty.a = fminf(fmaxf(a * div_Vdc + 0.5f, 0.0f), 1.0f);
    conv.duty.b = fminf(fmaxf(b * div_Vdc + 0.5f, 0.0f), 1.0f);
    conv.duty.c = fminf(fmaxf(c * div_Vdc + 0.5f, 0.0f), 1.0f);
}
