#pragma once

#include "DllHeader.h"
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <string.h>

#include "Gain.h"
#include "Control.h"

typedef uint16_t Uint16;
typedef uint32_t Uint32;
typedef uint64_t Uint64;
typedef int16_t int16;
typedef int32_t int32;
typedef int64_t int64;

struct abc_struct {
	float a;
	float b;
	float c;
};

struct alphabeta_struct {
	float alpha;
	float beta;
};

struct dq_struct {
	float d;
	float q;
};

struct Converter_struct {
	float _placeholder;
};

struct Measurements
{
	struct abc_struct I_filter;
	struct abc_struct V_capacitor;
};

extern struct Measurements Meas;
extern struct SimulationState *aState_global;