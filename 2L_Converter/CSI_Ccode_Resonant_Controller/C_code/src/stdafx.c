#include "stdafx.h"
#include "Converter.h"

float K_LQR[2][10] = K_LQR_Values;
float Ard[4][4] = Ard_Values;
float Brd[4][2] = Brd_Values;

struct Control_struct var_Control_struct;
struct Converter_struct conv;
struct Measurements Meas;

struct SimulationState *aState_global;