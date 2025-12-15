#pragma once

#include "DllHeader.h"
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <string.h>

#include "Matrices.h"
#include "Control.h"
#include "Converter.h"
#include "Coordinates.h"

typedef uint16_t Uint16;
typedef uint32_t Uint32;
typedef uint64_t Uint64;
typedef int16_t int16;
typedef int32_t int32;
typedef int64_t int64;

struct Measurements
{
	struct abc_struct ifs;
	struct abc_struct ifp;
	struct abc_struct vcs;
	struct abc_struct vcp;
	struct abc_struct iY;
	struct abc_struct vg;
	struct abc_struct iL;
	float Vdc;
};

extern float Kx[4][10];
extern float Ku[4][4];
extern float Kr[4][32];
extern float Ard[32][32];
extern float Brd[32][4];

extern struct Measurements Meas;
extern struct SimulationState *aState_global;