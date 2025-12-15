#include "stdafx.h"
#include "Control.h"

#pragma once
#ifndef Converter_H_
#define Converter_H_

struct Converter_struct
{
    struct abc_struct duty;
};

extern struct Converter_struct conv_s;
extern struct Converter_struct conv_p;

void Converter_2L_minmax(const struct abc_struct *u_abc, float Vdc, struct abc_struct *duty_abc);

#endif /* Converter_H_ */