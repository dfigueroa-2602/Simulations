#include "stdafx.h"
#include "Control.h"

#pragma once
#ifndef Converter_H_
#define Converter_H_

struct Converter_struct
{
    struct abc_struct duty;
};

extern struct Converter_struct conv;
void Converter_2L_minmax(void);

#endif /* Converter_H_ */