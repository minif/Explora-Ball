//
//  LevelLoading.h
//  ballbounce
//
//  Created by macpro on 7/19/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#import "PhysicsObject.h"
#import "PhysicsManager.h"
#import "CustomModel.h"
#import "SoundEffects.h"

#define STAR_COUNT 64

@interface LevelLoading : NSObject {
	//Level properties
	NSArray* levelFileNames;
	int currentLevel;
	int numBallsToLoad;
	NSDictionary* levelBGNames;
	NSString* bgName; 
	NSString* resultsLevel;
	CustomModel* bg;
	int numStars;
	
	//Background textures
	PVRTexture* fgTexture;
	PVRTexture* bgTexture;
	PVRTexture* btnTexture;
	
	int levelShouldAddBalls;
	
	//Level 5 star positions
	float starXpos[STAR_COUNT];
	float starYpos[STAR_COUNT];
	
	double levelOffsetX;
	double levelOffsetY;
	int levelsSinceLastBGChange;
	
	int hasSetBGPos;
	double levelOffsetXSet;
	double levelOffsetYSet;
	int levelsSinceLastBGChangeSet;
	
	SoundEffects* soundObject;
	
}

+(int) getNearestLevelPack:(int)level;
-(void)loadLevelList;
-(void)loadBGList;
-(PhysicsManager*)loadLevel:(NSString*)levelFile;
-(void)loadBG:(NSString*)backgroundName;
-(int)levelChangesBG;
-(void)setLevelNumber:(int)levelNumber;
-(void)nextLevel;
-(void)jumpCamera:(int)levelNumber;
-(int)levelExists;
-(PhysicsManager*)loadCurrentLevel;
-(PhysicsManager*)loadResultsLevel;
-(void)loadObjects:(NSArray*)objArray simulation:(PhysicsManager*)s isInvisible:(BOOL)visible;
-(void)loadObjects:(NSArray*)objArray simulation:(PhysicsManager*)s isInvisible:(BOOL)visible xOffset:(double)offsetX yOffset:(double)offsetY rOffset:(double)offsetR;

-(void)drawBG;

@property int numBallsToLoad;
@property int currentLevel;
@property double levelOffsetX;
@property double levelOffsetY;
@property int levelShouldAddBalls;
@property int numStars;
@property SoundEffects* soundObject;

@end
