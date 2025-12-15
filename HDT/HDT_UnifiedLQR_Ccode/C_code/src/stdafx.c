#include "stdafx.h"
#include "Converter.h"

float Kx[4][10] = Kx_val;
float Ku[4][4] = Ku_val;
float Kr[4][32] = Kr_val;
float Ard[32][32] = Ard_val;
float Brd[32][4] = Brd_val;

struct Control_struct var_Control_struct;
struct Converter_struct conv_s;
struct Converter_struct conv_p;
struct Measurements Meas;

struct SimulationState *aState_global;