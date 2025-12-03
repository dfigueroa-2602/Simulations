#include "stdafx.h"
#include "Converter.h"

float K_LQR[2][8] = K_LQR_Values;

struct PLL_struct var_PLL_struct;
struct Control_struct var_Control_struct;
struct Converter_struct conv;
struct Measurements Meas;

struct SimulationState *aState_global;