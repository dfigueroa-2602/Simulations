#include "stdafx.h"
#include "Control.h"
#include "stddef.h"

DLLEXPORT void plecsSetSizes(struct SimulationSizes* aSizes)
{
	aSizes->numInputs = 6;
	aSizes->numOutputs = 2;
	aSizes->numStates = 0;
	aSizes->numParameters = 0; //number of user parameters passed in
}