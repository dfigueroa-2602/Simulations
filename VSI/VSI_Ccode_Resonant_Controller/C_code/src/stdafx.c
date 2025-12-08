#include "stdafx.h"
#include "Converter.h"

float K_LQR[2][14] = K_LQR_Values;
float Ard[8][8] = Ard_Values;
float Brd[8][2] = Brd_Values;

struct Control_struct var_Control_struct;
struct Converter_struct conv;
struct Measurements Meas;

struct SimulationState *aState_global;