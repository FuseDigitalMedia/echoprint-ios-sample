/*
 *  Codegen_wrapper.cpp
 *
 *  Created by Brian Whitman on 7/10/10.
 *  Copyright 2010 The Echo Nest. All rights reserved.
 *
 */

#include "Codegen.h"
#include <string>

const char* codegen_wrapper(const float*pcm, int numSamples, int offset) {
	//Codegen*c = new Codegen(pcm, (uint)numSamples, 0, false);
	Codegen*c = new Codegen(pcm, (unsigned int)numSamples, (unsigned int)offset);
	string s = c->getCodeString();
	return s.c_str();
}
