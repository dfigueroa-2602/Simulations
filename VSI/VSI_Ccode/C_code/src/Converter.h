#include "stdafx.h"
#include "Control.h"

#pragma once
#ifndef Converter_H_
#define Converter_H_

struct Converter_struct
{
    float Ts;
    struct abc_struct duty;
};

extern struct Converter_struct conv;

void Converter_Control(float enable);

#endif /* Converter_H_ */