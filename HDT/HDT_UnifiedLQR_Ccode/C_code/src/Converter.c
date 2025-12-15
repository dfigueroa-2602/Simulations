#include "stdafx.h"
#include "Control.h"
#include "Converter.h"

/* Function to create the minmax injection for the 2L inverter */
void Converter_2L_minmax(const struct abc_struct *u_abc, float Vdc, struct abc_struct *duty_abc)
{
    float a = u_abc->a;
    float b = u_abc->b;
    float c = u_abc->c;

    float m_max = fmaxf(a, fmaxf(b, c));
    float m_min = fminf(a, fminf(b, c));
    float minmax = -0.5f * (m_min + m_max);

    a += minmax;
    b += minmax;
    c += minmax;

    register float div_Vdc = 1.0f / fmaxf(Vdc, 0.01f);

    duty_abc->a = fminf(fmaxf(a * div_Vdc + 0.5f, 0.0f), 1.0f);
    duty_abc->b = fminf(fmaxf(b * div_Vdc + 0.5f, 0.0f), 1.0f);
    duty_abc->c = fminf(fmaxf(c * div_Vdc + 0.5f, 0.0f), 1.0f);
}
