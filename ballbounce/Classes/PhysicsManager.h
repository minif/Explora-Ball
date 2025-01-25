//
//  PhysicsManager.h
//  ballbounce
//
//  Created by macpro on 7/16/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#import "PhysicsObject.h"
#import "CustomModel.h"
#include "simulation.h"
#include "object.h"
#include "circle.h"
#include "square.h"
#include "PVRTexture.h"
#import "SoundEffects.h"

@interface PhysicsManager : NSObject {
	Simulation sim;
	NSMutableArray* objects;
	NSMutableArray* touchAreas;
	NSMutableArray* invisObjects;
	NSMutableArray* visuals;
	int ballsLeft;
	int ballsHitGoal;
	int ballsInThisLevel;
	int triggersEnabled;
	double visualOffsetX;
	double visualOffsetY;
	
	SoundEffects* sfx;
	
	int tiltEnabled;
}

-(id)init;
-(void)drawAll;
-(void)addToSimulation:(PhysicsObject*)object;
-(void)addTouchArea:(PhysicsObject*)object;
-(void)addInvisToSimulation:(PhysicsObject*)object;
-(void)addVisual:(CustomModel*)object;
-(void)updateSimulation;
-(void)tilt:(float)angle;
-(void)drawRectangle:(PhysicsObject*)object;
-(Simulation*) getSim;

@property int ballsLeft;
@property int ballsHitGoal;
@property int tiltEnabled;
@property int ballsInThisLevel;
@property double visualOffsetX;
@property double visualOffsetY;
@property SoundEffects* sfx;
@property NSMutableArray* invisObjects;

@end
