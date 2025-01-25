//
//  SoundEffects.mm
//  ballbounce
//
//  Created by macpro on 8/13/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#import "SoundEffects.h"
#include <time.h>
#include <stdlib.h>

@implementation SoundEffects

float cMajorScale[] = {1.00000, 1.12247, 1.25993, 1.33485, 1.49831, 1.68180, 1.88776, 2.00000, 2.24493, 2.51985};
float gMajorScale[] = {0.74916, 0.84090, 0.94387, 1.00000, 1.12247, 1.25993, 1.41422, 1.49831, 1.68180, 1.88776};
float bMajorScale[] = {0.94387, 1.05947, 1.18920, 1.25993, 1.41422, 1.58741, 1.78181, 1.88776, 2.11893, 2.37842};
float eflatMinorScale[] = {1.18920, 1.33485, 1.41422, 1.58741, 1.78181, 1.88776, 2.11893, 2.37842, 2.11893, 2.37842};
float cMajorBrokenTriads[] = {1.00000, 1.25993, 1.49831, 1.25993, 1.49831, 2.00000, 1.49831, 2.00000, 2.51985, 2.00000};
float cChromaticScale[] = {1.00000, 1.05947, 1.12247, 1.18920, 1.25993, 1.33485, 1.41422, 1.49831, 1.58741, 1.68180};
float aMajorScale[] = {0.84090, 0.94387, 1.05947, 1.12247, 1.25993, 1.41422, 1.58741, 1.68180, 1.88776, 2.11894};
float cMinorHarmonicScale[] = {1.00000, 1.12247, 1.18920, 1.33485, 1.49831, 1.58741, 1.88776, 2.00000, 2.24493, 2.37842};

//Sound effect system. Use various music scales to enhance the game

- (id)init{ 
	//OpenAL setup
	lastUsedIndex=1;
	audioLevel = 2;
	audioVolume = 1.0f;
    openALDevice = alcOpenDevice(NULL);
	openALContext = alcCreateContext(openALDevice, 0);
	alcMakeContextCurrent(openALContext);
	
	[self addSFX:@"sfx_firstball" toBuffer:&firstballOutputBuffer] ;
	[self addSFX:@"sfx_ball" toBuffer:&ballOutputBuffer] ;
	[self addSFX:@"sfx_lastball" toBuffer:&lastballOutputBuffer] ;
	[self addSFX:@"sfx_miss" toBuffer:&missOutputBuffer];
	[self addSFX:@"sfx_click" toBuffer:&menuOutputBuffer];
	
	for (int i=0; i<SFX_SLOTS; i++) alGenSources(1, &SFXSource[i]);
	curSFXSlot=0;
	audioDisabled = 0;
	
	//Random scale setup
	srand(time(NULL));
	positionOnScale = 0;
	currentScale = cMajorScale;
	
	[self resetPitch];
	
	//audioDisabled = 1;
	audioVolume = 1.0f;
	return self;
}

-(void) disableAudio {
	audioDisabled = 1;
	NSLog(@"Audio Disbale");
}

-(void) playSFX {
	//Play the SFX when the ball enters the goal
	if (audioDisabled) return;
	alSourcei(SFXSource[curSFXSlot],AL_BUFFER,ballOutputBuffer);
	alSourcef(SFXSource[curSFXSlot],AL_GAIN, audioVolume);
	alSourcef(SFXSource[curSFXSlot],AL_PITCH, currentScale[positionOnScale]);
	alSourcePlay(SFXSource[curSFXSlot]);
	
	if (positionOnScale<10) positionOnScale++;
	curSFXSlot++;
	curSFXSlot=curSFXSlot%SFX_SLOTS;
}

-(void) playLastSFX {
	//Play the SFX when the ball enters the goal for the last time 
	if (audioDisabled) return;
	alSourcei(SFXSource[curSFXSlot],AL_BUFFER,lastballOutputBuffer);
	alSourcef(SFXSource[curSFXSlot],AL_GAIN, audioVolume);
	alSourcef(SFXSource[curSFXSlot],AL_PITCH, currentScale[positionOnScale]);
	alSourcePlay(SFXSource[curSFXSlot]);
	curSFXSlot++;
	curSFXSlot=curSFXSlot%SFX_SLOTS;
}

-(void) playFirstSFX {
	//Play the SFX when the ball enters the goal for the first time
	if (audioDisabled) return;
	alSourcei(SFXSource[curSFXSlot],AL_BUFFER,firstballOutputBuffer);
	alSourcef(SFXSource[curSFXSlot],AL_GAIN, audioVolume);
	alSourcef(SFXSource[curSFXSlot],AL_PITCH, currentScale[positionOnScale]);
	alSourcePlay(SFXSource[curSFXSlot]);
	
	if (positionOnScale<10) positionOnScale++;
	curSFXSlot++;
	curSFXSlot=curSFXSlot%SFX_SLOTS;
}

-(void) missSFX {
	//Play the SFX when the ball falls off the stage
	if (audioDisabled) return;
	alSourcei(SFXSource[curSFXSlot],AL_BUFFER,missOutputBuffer);
	alSourcef(SFXSource[curSFXSlot],AL_GAIN, audioVolume);
	alSourcef(SFXSource[curSFXSlot],AL_PITCH, 1.0f);
	alSourcePlay(SFXSource[curSFXSlot]);
	curSFXSlot++;
	curSFXSlot=curSFXSlot%SFX_SLOTS;
}

-(void) menuSFX {
	//Play SFX for when a menu option is tapped
	if (audioDisabled) return;
	alSourcei(SFXSource[curSFXSlot],AL_BUFFER,menuOutputBuffer);
	alSourcef(SFXSource[curSFXSlot],AL_GAIN, audioVolume);
	alSourcef(SFXSource[curSFXSlot],AL_PITCH, 1.0f);
	alSourcePlay(SFXSource[curSFXSlot]);
	curSFXSlot++;
	curSFXSlot=curSFXSlot%SFX_SLOTS;
}

-(void) addSFX:(NSString*)sfxName toBuffer:(ALuint*)outputBuffer  {
	//Quickly add an SFX from the file to the buffer
	//alGenSources(lastUsedIndex,outputSource);
	
	alGenBuffers(1,outputBuffer);
	
	ALsizei dataSize;
	ALenum alFormat = AL_FORMAT_STEREO16;
	ALsizei sampleRate;
	
	NSString* fileUrl = [[NSBundle mainBundle] pathForResource:sfxName ofType:@"wav"];
	char fileURLCString[512];
	[fileUrl getCString:fileURLCString maxLength:512 encoding:NSUTF8StringEncoding];
	int chan,bps;
	char* sfxPCMData = loadWAV(fileURLCString, chan, sampleRate, bps, dataSize);
	
	if (sfxPCMData==NULL) return;
	
	//NSLog(@"SFX Uses %i %i",chan,bps);
	
	alBufferData(*outputBuffer, alFormat, sfxPCMData, dataSize, sampleRate);
	delete sfxPCMData;
}

-(void) resetPitch {
	//Pick a new scale and reset the pitch to the first note
	positionOnScale = 0;
	
	int scaleToUse = random()%100;
	
	if (scaleToUse==0) currentScale = eflatMinorScale;
	else if (scaleToUse<14) currentScale = gMajorScale;
	else if (scaleToUse<28) currentScale = cMinorHarmonicScale;
	else if (scaleToUse<42) currentScale = aMajorScale;
	else if (scaleToUse<56) currentScale = cChromaticScale;
	else if (scaleToUse<70) currentScale = cMajorBrokenTriads;
	else if (scaleToUse<84) currentScale = bMajorScale;
	else currentScale = cMajorScale;
}

-(void)dealloc {
	//Stop OpenAL 
	for (int i=0; i<SFX_SLOTS; i++) {
		alSourceStop(SFXSource[i]);
		alDeleteSources(1, &SFXSource[i]);
	}
	alDeleteBuffers(1, &firstballOutputBuffer);
	alDeleteBuffers(1, &ballOutputBuffer);
	alDeleteBuffers(1, &lastballOutputBuffer);
	alDeleteBuffers(1, &missOutputBuffer);
	alDeleteBuffers(1, &menuOutputBuffer);
	alcMakeContextCurrent(NULL);
	alcDestroyContext(openALContext);
	alcCloseDevice(openALDevice);
	[super dealloc];
}

-(int) toggleAudio {
	//Menu option to make volume quieter
	if (audioLevel>2) audioLevel=2;
	audioLevel--;
	if (audioLevel<0) audioLevel=2;
	[self setAudioLevel:audioLevel];
	return audioLevel;
}

-(void) setAudioLevel:(int) level {
	//Set the audio volume from the level
	audioLevel = level;
	if (level==2) audioVolume = 1.0f;
	else if (level==1) audioVolume = 0.1f;
	else audioVolume = 0.0000f;
}

@end
