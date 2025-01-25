//
//  SoundEffects.h
//  ballbounce
//
//  Created by macpro on 8/13/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <OpenAL/alc.h>
#import <OpenAL/al.h>
#import "WavLoader.h"
#define SFX_SLOTS 8

@interface SoundEffects : NSObject {
	ALuint firstballOutputBuffer;
	ALuint ballOutputBuffer;
	ALuint lastballOutputBuffer;
	ALuint missOutputBuffer;
	ALuint menuOutputBuffer;
	
	ALuint SFXSource[SFX_SLOTS];
	int curSFXSlot;
	int lastUsedIndex;
	int audioLevel;
	float audioVolume;
	
	float* currentScale;
	
	int positionOnScale;
	int audioDisabled;
	ALCdevice* openALDevice;
	ALCcontext* openALContext;
}

-(void) addSFX:(NSString*)sfxName toBuffer:(ALuint*)outputBuffer;
-(void) playSFX;
-(void) playLastSFX;
-(void) playFirstSFX;
-(void) missSFX;
-(void) menuSFX;
-(void) resetPitch;
-(void) disableAudio;
-(int) toggleAudio;
-(void) setAudioLevel:(int) level;
@end
