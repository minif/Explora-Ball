//
//  PhysicsObject.h
//  ballbounce
//
//  Created by macpro on 7/17/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#include "simulation.h"
#include "object.h"
#include "circle.h"
#include "square.h"

@interface PhysicsObject : NSObject {
	//Wrapped physic object
	Object* obj;
	//Define what shape this is
	int shapeType;
	
	//All parameters for visualisation
	double moveDistance;
	int waitTime;
	double moveXVel;
	double moveYVel;
	double moveRVel;
	double xInitialPos;
	double yInitialPos;
	double xFinalPos;
	double yFinalPos;
	double moveXSmaller;
	double moveXBigger;
	double moveYSmaller;
	double moveYBigger;
	double visualOffsetX;
	double visualOffsetY;
	double visualOffsetZ;
	double visualOffsetR;
	double gravityX;
	double gravityY;
	double teleX;
	double teleY;
	double growSpeed;
	int moveTrigger;
	int areaObjectType;
	int waitTimer;
	int direction;
	int shouldOffsetR;
}

- (id)init:(Object*)object;
- (double)getX;
- (double)getY;
- (double)getRotation;
- (double)getWidth;
- (double)getHeight;
- (void)updateMovement:(int)triggers;
- (void)draw;
- (void)configureMovement;
- (void)configureCircle;
- (void)configureBall;
- (void)configureSquare;
- (void)configureCustom;
- (void)configureVisualOffsetX:(double) offsetX OffsetY:(double) offsetY;
- (void)configureVisualOffsetZ:(double) offsetZ;
- (void)configureVisualOffsetR:(double) offsetR;
- (void)resizeObject:(double) s;

@property Object* obj;

@property double moveDistance;
@property int waitTime;
@property int moveTrigger;
@property double moveXVel;
@property double moveYVel;
@property double moveRVel;
@property int areaObjectType;
@property double gravityX;
@property double gravityY;
@property double teleX;
@property double teleY;
@property double growSpeed;


@end
