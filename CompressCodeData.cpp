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
    
    string CompressCodeData(const char * strToCompress) {
        const string s(strToCompress);
        //const char * cmp = Codegen::compress(s).c_str();
        string cmp = Codegen::compress(s);
        //NSLog(CFSTR("s = %s"), cmp);
        return cmp;
    }

}