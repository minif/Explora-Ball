//
//  PhysicsManager.mm
//  ballbounce
//
//  Created by macpro on 7/16/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#import "PhysicsManager.h"

//#define DEBUG_DRAW_TOUCH_AREAS

@implementation PhysicsManager

@synthesize ballsLeft;
@synthesize ballsHitGoal;
@synthesize invisObjects;
@synthesize tiltEnabled;
@synthesize ballsInThisLevel;
@synthesize visualOffsetX;
@synthesize visualOffsetY;
@synthesize sfx;

-(id)init {
	//Wrapper for the physics manager
	//Contains the level, including physics objects and non-physics objects
	//Set up lists for the level objects
	objects = [[NSMutableArray alloc] init];
	touchAreas = [[NSMutableArray alloc] init];
	invisObjects = [[NSMutableArray alloc] init];
	visuals = [[NSMutableArray alloc] init];
	//Set up properties of the stage
	visualOffsetX=0;
	visualOffsetY=0;
	sim.gravityY = -0.004;
	ballsLeft = 0;
	ballsHitGoal = 0;
	triggersEnabled = 0;
	tiltEnabled=1;
	sfx = NULL;
	return self;
}

const GLfloat squareVertices[] = {
	-0.5f, -0.5f, 0.0f,
	0.5f,  -0.5f, 0.0f,
	-0.5f,  0.5f, 0.0f,
	0.5f,   0.5f, 0.0f,
};

-(void)drawAll {
	//Draw the entire level
	for (int i=0; i<[visuals count]; i++) {
		[[visuals objectAtIndex:i] draw];
	}
	
	glActiveTexture(GL_TEXTURE0);
	glEnable(GL_TEXTURE_2D);
	
	//Draw decoration (i.e. goal container)
	for (int i=0; i<[objects count]; i++) {
		[[objects objectAtIndex:i] draw];
	}
	
	//Draw the grow and gravity areas
	for (int i=0; i<[touchAreas count]; i++) {
		PhysicsObject* o = [touchAreas objectAtIndex:i];
		if (o.areaObjectType==2) {
			[self drawRectangle:o];
		} else if (o.areaObjectType==3) {
			[self drawRectangle:o];
		}
	}
	
	glDisable(GL_TEXTURE_2D);
#ifdef DEBUG_DRAW_TOUCH_AREAS
	for (int i=0; i<[touchAreas count]; i++) {
		[[touchAreas objectAtIndex:i] draw];
	}
	
	for (int i=0; i<[invisObjects count]; i++) {
		[[invisObjects objectAtIndex:i] draw];
	}
#endif
}

-(void)drawRectangle:(PhysicsObject*)object {
	//Draw a rectangle using an object (used for gravity zones)
	double angle=0;
	
	//If a gravity zone rotate the texture coordinates
	if ((object.gravityX!=0||object.gravityY!=100)&&object.areaObjectType==2) {
		double gx = object.gravityX;
		double gy = object.gravityY-0.02;
		angle = atan2(gx,-gy);
	}
	
	angle-=3.14159265/4;
	
	double SQUARE_SIZE;
	double SQUARE_X;
	double SQUARE_Y;
	//Pick correct texture for square
	if (object.areaObjectType==2) {
		SQUARE_X = 0.0625f;
		SQUARE_Y = 0.3125f;
		SQUARE_SIZE = 0.0600f;
	} else {
		SQUARE_X = 0.4375f;
		SQUARE_Y = 0.1875f;
		SQUARE_SIZE = 0.0800f;
	}
	
	//Deal with rotation of texture
	double sn = SQUARE_SIZE*sin(angle);
	double cs = SQUARE_SIZE*cos(angle);
	
	const GLfloat squareCoords[] = {
		SQUARE_X-sn,  SQUARE_Y+cs,
		SQUARE_X+cs,  SQUARE_Y+sn,
		SQUARE_X-cs,  SQUARE_Y-sn,
		SQUARE_X+sn,  SQUARE_Y-cs,
	};
	
	// Draw rectangle
	glPushMatrix();
	glTranslatef(-visualOffsetX, -visualOffsetY, 0);
	glClientActiveTexture(GL_TEXTURE0);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glTranslatef([object getX], [object getY], -10); //Position
	glRotatef([object getRotation], 0, 0, 1);
	glScalef([object getWidth], [object getHeight], 20);
	
	
	glTexCoordPointer(2, GL_FLOAT, 0, squareCoords);
	glVertexPointer(3, GL_FLOAT, 0, squareVertices);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glPopMatrix();
}

-(void)addToSimulation:(PhysicsObject*)object {
	//[object retain];
	[objects addObject:object];
	sim.addToSimulation(object.obj);
}

-(void)addTouchArea:(PhysicsObject*)object {
	//[object retain];
	[touchAreas addObject:object];
}

-(void)addInvisToSimulation:(PhysicsObject*)object {
	//[object retain];
	[invisObjects addObject:object];
	sim.addToSimulation(object.obj);
}

-(void)addVisual:(CustomModel*)object {
	//[object retain];
	[visuals addObject:object];
}

-(void)updateSimulation {
	//Update the physics
	sim.updateSimulation();
	
	//Check if any balls have fallen off
	for (int i=0; i<[objects count]; i++) {
		PhysicsObject* o = [objects objectAtIndex:i];
		if (o.obj->y<-300&&o.obj->y>-5000) {
			//Ball has fallen off
			o.obj->y = -10000;
			o.obj->weight = 0;
			if (o.obj->isPlayer) {
				ballsLeft--;	
				[sfx missSFX];
			}
		}
	}
	
	//Handle touch areas
	triggersEnabled=0;
	for (int areaIndex=0; areaIndex<[touchAreas count]; areaIndex++) {
		colisionInfo colProperties[MAXOBJECTCOLLISIONS];
		PhysicsObject* areaObj = [touchAreas objectAtIndex:areaIndex];
		double xc = areaObj.obj->x;
		double yc = areaObj.obj->y;
		//Handle collision with area object
		int cols = sim.isCollidingWithObject(areaObj.obj,colProperties);
		for (int i=0; i<cols; i++) {
			Object* otherObj = colProperties[i].other;
			switch(areaObj.areaObjectType) {
			case 1:	//Moving platform trigger
				triggersEnabled=1;
				break;
			case 2:	//Gravity zone
				otherObj->xvel+=areaObj.gravityX;
				otherObj->yvel+=areaObj.gravityY;
				break;
			case 3:	//Grow zone
				otherObj->changeSize(areaObj.growSpeed);
				break;
			case 4:	//Portal
				otherObj->teleport((areaObj.teleX-[areaObj getX]),areaObj.teleY-[areaObj getY]);
				break;
			default://Goal
				//Stop movement in directon of goal 
				otherObj->rotateAngle(areaObj.obj->rotation*(3.1415926535/180), otherObj->xvel, otherObj->yvel);
				otherObj->xvel = 0;
				otherObj->rotateAngle(-areaObj.obj->rotation*(3.1415926535/180), otherObj->xvel, otherObj->yvel);
				
				otherObj->inactiveStatus=1;
				
				//Find position to accept goal
				double collectionPointX = 0;
				double collectionPointY = -20;
				otherObj->rotateAngle(areaObj.obj->rotation*(3.1415926535/180),collectionPointX, collectionPointY);
				
				//Find distance to this point
				double xdist = xc-otherObj->x+collectionPointX;
				double ydist = yc-otherObj->y+collectionPointY;
				double dist = sqrt(xdist*xdist+ydist*ydist);
				double direction = atan2(ydist,xdist);
				//Check if goal is accepted
				if (dist<3) {
					otherObj->y=-10000;
					if (otherObj->isPlayer) {
						ballsHitGoal++;
						ballsLeft--;
						//Cheaty way of getting rid of object
						otherObj->y=-10000;
						otherObj->weight=0;
						
						if (ballsHitGoal==ballsInThisLevel) [sfx playLastSFX];
						else if (ballsHitGoal==1) [sfx playFirstSFX];
						else [sfx playSFX];
					}
				} else {
					//Push ball into goal
					otherObj->x+=3*cos(direction);
					otherObj->y+=2*sin(direction);
				}
			}
		}
	}
	
	//Handle moving objects
	for (int i=0; i<[objects count]; i++) {
		[[objects objectAtIndex:i] updateMovement:triggersEnabled];
	}
	
	for (int i=0; i<[invisObjects count]; i++) {
		[[invisObjects objectAtIndex:i] updateMovement:triggersEnabled];
	}
}

-(void)tilt:(float)angle {
	//Accept movement to control gravity
	if (tiltEnabled) {
		if (fabsf(angle)>0.15) {
			if (angle>1.0) angle=1.0;
			if (angle<-1.0) angle=-1.0;
			sim.gravityX=-angle*0.006;
		} else 
			sim.gravityX=0;
	}
}

-(void)dealloc {
	[touchAreas release];
	[invisObjects release];
	[objects release];
	[visuals release];
	[super dealloc];
}

-(Simulation*) getSim {
	return &sim;
}

@end
