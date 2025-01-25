//
//  SaveManager.h
//  ballbounce
//
//  Created by macpro on 1/10/25.
//  Copyright 2025 __MyCompanyName__. All rights reserved.
//



@interface SaveManager : NSObject {
	int lastLevel;
	int unlockedLevel;
	int unlockedFreeplayMode;
	int volumeLevel;
	int touchControls;
	int sensitivity;
	NSString* saveFileLocation;
}

- (void) loadFile;
- (void) saveFile;
- (void) loadFilePlist;
- (void) saveFilePlist;

@property int lastLevel;
@property int unlockedLevel;
@property int volumeLevel;
@property int touchControls;
@property int sensitivity;
@property int unlockedFreeplayMode;

@end

