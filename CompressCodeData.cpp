//
//  CompressCodeData.cpp
//  echoprint
//
//  Created by James O'Reilly on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include <string.h>
#include "CAStreamBasicDescription.h"
#include "Codegen.h"

extern "C" {
    
    extern void NSLog(CFStringRef format, ...); 
    
    char * CompressCodeData(const char * strToCompress) {
        const string s(strToCompress);
        char *r = strdup(Codegen::compress(s).c_str());
        //NSLog(CFSTR("In Compress %s"), r);
        return r;
    }

}