
#include <CoreFoundation/CoreFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
 
char* loadWAV(const char* fn, int& chan, int& samplerate, int& bps, int& size);