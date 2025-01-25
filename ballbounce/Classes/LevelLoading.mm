//
//  LevelLoading.mm
//  ballbounce
//
//  Created by macpro on 7/19/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#define BALL_RADIUS 10
#define MAX_BALLS 10
#define BG_TEXTURE_SLOT 1
#define CAM_TRANSITION_SCROLL_X 500;
#define CAM_TRANSITION_SCROLL_Y 400;

#ifdef TOUCH_TO_RELOAD_LEVEL
#define SKIP_BG_TRANSITION
#endif

#import "LevelLoading.h"
#ifdef TOUCHHLE_WORKAROUND
#include <stdio.h>

double convertNumberToDouble (NSNumber* num) {
	//As of TouchHLE v0.2.2, the way to get a number from an NSNumber was not implemented. Therefore, 
	//This convoluted function gets a number for us. 
	//The downside is that it can only get an integer because scanf cannot get floats or doubles yet.
	//This will be kept in version 1.0 of this game, but will be deprecated for 1.1 (#define will be switched off and forgotten)
	double val;
	NSString* n = [num description];
	char nCString[128];
	[n getCString:nCString maxLength:128 encoding:NSUTF8StringEncoding];
	if ([n isEqualToString:@"0"]) {
		val = 0; //For some reason a 0 string crashes?
	} else {
		int wholePart;
		sscanf(nCString, "%i", &wholePart);
		val = wholePart; //We don't really care about the decimals, the scale involves whole numbers
	}
	return val;
}

#endif

@implementation LevelLoading

@synthesize numBallsToLoad;
@synthesize currentLevel;
@synthesize levelOffsetX;
@synthesize levelOffsetY;
@synthesize levelShouldAddBalls;
@synthesize soundObject;
@synthesize numStars;

//The object responsible for loading levels

+(int) getNearestLevelPack:(int)level {
	//Find the level pack first level given a later level. Useful for when laading from the save file.
	int nearestLevel = 0;
	NSDictionary* levelListDict = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levels" ofType:@"plist"]];
	NSArray* levelFileNames = [levelListDict objectForKey:@"Worlds"];
	
	//Search all worlds for if any of the 3 packs contain the highest level smaller than the requested level
	for (int i=0; i<[levelFileNames count]; i++) {
		NSDictionary* worldDict = [levelFileNames objectAtIndex:i];
		int packA,packB,packC;
#ifdef TOUCHHLE_WORKAROUND
		packA = convertNumberToDouble([worldDict objectForKey:@"a"]);
		packB = convertNumberToDouble([worldDict objectForKey:@"b"]);
		packC = convertNumberToDouble([worldDict objectForKey:@"c"]);
#else
		packA = [[worldDict objectForKey:@"a"] doubleValue];
		packB = [[worldDict objectForKey:@"b"] doubleValue];
		packC = [[worldDict objectForKey:@"c"] doubleValue];
#endif
		if (packA>nearestLevel&&packA<=level) nearestLevel=packA;
		if (packB>nearestLevel&&packB<=level) nearestLevel=packB;
		if (packC>nearestLevel&&packC<=level) nearestLevel=packC;
	}
	[levelListDict release];
	return nearestLevel;
}

-(id)init {
	//Configure level properties
	currentLevel = 0;
	numBallsToLoad = 0;
	bgName = @"";
	levelOffsetX=0;
	levelOffsetY=0;
	levelsSinceLastBGChange = 0;
	levelShouldAddBalls=1;
	hasSetBGPos=0;
	numStars=0;
	soundObject = NULL;
	return self;
}

-(void)loadBGList {
	//Load the plist with bg information
	NSDictionary* levelListDict = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backgrounds" ofType:@"plist"]];
	levelBGNames = [[levelListDict objectForKey:@"Backgrounds"] copy];
	/*for (int i=0; i<[levelFileNames count]; i++) {
		NSLog([levelFileNames objectAtIndex:i]);
	}*/
	
	[levelListDict release];
}

-(void)loadLevelList {
	//Load the plist with level information
	NSDictionary* levelListDict = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levels" ofType:@"plist"]];
	levelFileNames = [[levelListDict objectForKey:@"Levels"] copy];
	resultsLevel = [[levelListDict objectForKey:@"Results"] copy];
	[levelListDict release];
}

-(void)loadBG:(NSString*)backgroundName {
	//Load the background for use in the level
	if (![backgroundName isEqualToString:bgName]) {
		if (bg) {
			//Release old bg if it exists
			[bg release];
			bg = NULL;
		}
		if (bgName) {
			//Prevent memory leak with string
			[bgName release];
			bgName = NULL;
		}
		//Find filename for background
		NSDictionary* bgProperties = [levelBGNames objectForKey:backgroundName];
		bgName = [backgroundName copy];
		bg = [[CustomModel alloc] init];
		//Load the 3D model from file
		bg.verts = [CustomModel loadModelFromPath:[[NSBundle mainBundle] pathForResource:[bgProperties objectForKey:@"modelName"] ofType:@"bin"] vertCount:bg];
		bg.textCoords = [CustomModel loadTexMapFromPath:[[NSBundle mainBundle] pathForResource:[bgProperties objectForKey:@"modelName"] ofType:@"binmap"]];
		bg.textureToUse = BG_TEXTURE_SLOT; //For now this is hard coded
		
		numStars = 0;
		
		//Read 3D model offset
#ifdef TOUCHHLE_WORKAROUND
		bg.z = convertNumberToDouble([bgProperties objectForKey:@"zoffset"]);
		bg.x = convertNumberToDouble([bgProperties objectForKey:@"xoffset"]);
		bg.y = convertNumberToDouble([bgProperties objectForKey:@"yoffset"]);
		bg.width = convertNumberToDouble([bgProperties objectForKey:@"scale"]);
		if ([bgProperties objectForKey:@"stars"]) numStars = convertNumberToDouble([bgProperties objectForKey:@"stars"]);
#else
		bg.z = [[bgProperties objectForKey:@"zoffset"] doubleValue];
		bg.x = [[bgProperties objectForKey:@"xoffset"] doubleValue];
		bg.y = [[bgProperties objectForKey:@"yoffset"] doubleValue];
		bg.width =[[bgProperties objectForKey:@"scale"] doubleValue];
		if ([bgProperties objectForKey:@"stars"]) numStars =[[bgProperties objectForKey:@"stars"] doubleValue];
#endif
		//Add the randomised stars if requested
		if (numStars) {
			for (int i=0; i<STAR_COUNT; i++) {
				starXpos[i]=random()%10000-5000;
				starYpos[i]=random()%5000+350;
			}
		}
		
		//Load the textures needed
		if (fgTexture) {
			[fgTexture release];
			fgTexture = NULL;
		}
		//load fg texture
		glActiveTexture(GL_TEXTURE0);
		glEnable(GL_TEXTURE_2D);
		NSString * path = [[NSBundle mainBundle] pathForResource:[bgProperties objectForKey:@"fgTexture"] ofType:@"pvrtc"];
		fgTexture = [[PVRTexture alloc] initWithContentsOfFile: path];
		glBindTexture(GL_TEXTURE_2D, fgTexture.name);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);  //This makes everything tan for some reason?
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); 
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1.0f); 
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT); 
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT); 
		
		if (bgTexture) {
			[bgTexture release];
			bgTexture = NULL;
		}
		
		//load bg texture
		glActiveTexture(GL_TEXTURE0+BG_TEXTURE_SLOT);
		glEnable(GL_TEXTURE_2D);
		NSString * path2 = [[NSBundle mainBundle] pathForResource:[bgProperties objectForKey:@"bgTexture"] ofType:@"pvrtc"];
		bgTexture = [[PVRTexture alloc] initWithContentsOfFile: path2];
		glBindTexture(GL_TEXTURE_2D, bgTexture.name);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);  //This makes everything tan for some reason?
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); 
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1.0f); 
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT); 
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT); 
		
		glActiveTexture(GL_TEXTURE0);
		
		//Reset "scroll" position
		if (hasSetBGPos) {
			levelOffsetX=levelOffsetXSet;
			levelOffsetY=levelOffsetYSet;
			levelsSinceLastBGChange = levelsSinceLastBGChangeSet;
			hasSetBGPos = 0;
		} else {
			levelOffsetX=0;
			levelOffsetY=0;
			levelsSinceLastBGChange = 0;
		}
	}
}

-(int)levelChangesBG {
	//Check if the currently loaded level bg is different from the next one
	if (!levelFileNames) return nil;
	if (currentLevel<0||currentLevel>=[levelFileNames count]) return nil;
	NSString* levelFile = [[NSBundle mainBundle] pathForResource:[levelFileNames objectAtIndex:currentLevel] ofType:@"plist"];
	
	int state = 0;
	NSDictionary* levelDict = [[NSDictionary alloc]initWithContentsOfFile:levelFile];
	NSDictionary* propertyDict = [levelDict objectForKey:@"Properties"];
	if ([propertyDict objectForKey:@"background"]) {
		if (![[propertyDict objectForKey:@"background"] isEqualToString:bgName]) {
			state = 1;
		}
	}
	[levelDict release];
	return state;
}

-(void)jumpCamera:(int)levelNumber {
	//Kind of hacky way to jump camera if level is selected
	//Possible lookup table?
	
	levelOffsetXSet = 0;
	levelOffsetYSet = 0;
	levelsSinceLastBGChangeSet=0;
	
	for (int i=0; i<levelNumber%10; i++) {
		int cycleNumber = levelsSinceLastBGChangeSet%10;
		if (cycleNumber==4) {levelOffsetYSet-=CAM_TRANSITION_SCROLL_Y;}
		else if (cycleNumber==9) {levelOffsetYSet+=CAM_TRANSITION_SCROLL_Y;}
		else if (cycleNumber>4) {levelOffsetXSet+=CAM_TRANSITION_SCROLL_X;}
		else {levelOffsetXSet-=CAM_TRANSITION_SCROLL_X;}
		levelsSinceLastBGChangeSet++;
	}
	
	hasSetBGPos=1;
}

-(PhysicsManager*)loadLevel:(NSString*)levelFile {
	//Load a level from the file path
	//First handle the camera jump transition between levels (This sets the target position)
#ifndef SKIP_BG_TRANSITION
	int cycleNumber = levelsSinceLastBGChange%10;
	if (cycleNumber==4) {levelOffsetY-=CAM_TRANSITION_SCROLL_Y;}
	else if (cycleNumber==9) {levelOffsetY+=CAM_TRANSITION_SCROLL_Y;}
	else if (cycleNumber>4) {levelOffsetX+=CAM_TRANSITION_SCROLL_X;}
	else {levelOffsetX-=CAM_TRANSITION_SCROLL_X;}
	levelsSinceLastBGChange++;
#endif
	
	//Set up the dictionary to read the level
	NSDictionary* levelDict = [[NSDictionary alloc]initWithContentsOfFile:levelFile];
	NSDictionary* propertyDict = [levelDict objectForKey:@"Properties"];
	NSArray* levelObjects = [levelDict objectForKey:@"Objects"];
	PhysicsManager* s = [[PhysicsManager alloc] init];
	
	//Handle with adding balls to the level
	if (levelShouldAddBalls) {
		if([propertyDict objectForKey:@"addBalls"]) {
#ifdef TOUCHHLE_WORKAROUND
			numBallsToLoad+=convertNumberToDouble([propertyDict objectForKey:@"addBalls"]);
#else
			numBallsToLoad+=[[propertyDict objectForKey:@"addBalls"] doubleValue];
#endif
			if (numBallsToLoad>MAX_BALLS) numBallsToLoad=MAX_BALLS;
		}
	}
	
	//Load the background requested from the level file
	if ([propertyDict objectForKey:@"background"]) {
		[self loadBG:[propertyDict objectForKey:@"background"]];
	}
	
	//numBallsToLoad = 20;
	//Find the start position and add balls to that position
	if([propertyDict objectForKey:@"startX"]&&[propertyDict objectForKey:@"startY"]) {
		double sx, sy;
#ifdef TOUCHHLE_WORKAROUND
		sx=convertNumberToDouble([propertyDict objectForKey:@"startX"]);
		sy=convertNumberToDouble([propertyDict objectForKey:@"startY"]);
#else
		sx=[[propertyDict objectForKey:@"startX"] doubleValue];
		sy=[[propertyDict objectForKey:@"startY"] doubleValue];
#endif
		PhysicsObject* o;
		double x = sx;
		double y = sy;
		for (int i=0; i<numBallsToLoad; i++) {
			o = [[PhysicsObject alloc] init:new Circle(x,y,BALL_RADIUS,0,1)];
			o.obj->isPlayer=1;
			[o configureBall];
			[s addToSimulation:o];
			[o configureVisualOffsetX:levelOffsetX OffsetY:levelOffsetY];
			[o release];
			if (i==4) {
				x = sx;
				y+=BALL_RADIUS*2 + 3;
			} else {
				x+=BALL_RADIUS*2 + 3;
			}
		}
		s.ballsLeft = numBallsToLoad;
	}
	
	//Load the rest of the objects in the level
	[self loadObjects:levelObjects simulation:s isInvisible:false];
	s.visualOffsetX = levelOffsetX;
	s.visualOffsetY = levelOffsetY;
	
	//Finished loading level, do final prep before returning
	[levelDict release];
	s.sfx = soundObject;
	[soundObject resetPitch];
	s.ballsInThisLevel = numBallsToLoad;
	return s;
}

-(void)loadObjects:(NSArray*)objArray simulation:(PhysicsManager*)s isInvisible:(BOOL)invisible {
	//Load the root set of level objects
	[self loadObjects:objArray simulation:s isInvisible:invisible xOffset:0 yOffset:0 rOffset:0];
}

-(void)loadObjects:(NSArray*)objArray simulation:(PhysicsManager*)s isInvisible:(BOOL)invisible xOffset:(double)offsetX yOffset:(double)offsetY rOffset:(double)offsetR{
	//Recursively look through plist to add objects to level
	//Recursive so that custom objects can reuse all code 
	
	//r.x = xPos;
	//r.y = yPos;
	//r.width = scale;
	//r.rotation = rotation;
	
	//Loop through given object array
	for (int i=0; i<[objArray count]; i++) {
		//Get the object looked at
		NSDictionary* objData = [objArray objectAtIndex:i];
		//Get properties for object
		NSString* objType = [objData objectForKey:@"ObjectType"];
		PhysicsObject* o = NULL;
#ifdef TOUCHHLE_WORKAROUND
		double xPos = convertNumberToDouble([objData objectForKey:@"x"]);
		double yPos = convertNumberToDouble([objData objectForKey:@"y"]);
		double rotation = convertNumberToDouble([objData objectForKey:@"rotation"]);
		double weight = convertNumberToDouble([objData objectForKey:@"weight"]);
#else
		double xPos = [[objData objectForKey:@"x"] doubleValue];
		double yPos = [[objData objectForKey:@"y"] doubleValue];
		double rotation = [[objData objectForKey:@"rotation"] doubleValue];
		double weight = [[objData objectForKey:@"weight"] doubleValue];
#endif
		double xVel = 0;
		double yVel = 0;
		double rVel = 0;
		double distToMove = 0;
		double waitTime = 0;
		double moveTrigger = 0;
		//Get optional properties
		if ([objData objectForKey:@"x_vel"]) {
#ifdef TOUCHHLE_WORKAROUND
		xVel = convertNumberToDouble([objData objectForKey:@"x_vel"])/100;
#else
		xVel = [[objData objectForKey:@"x_vel"] doubleValue]/100;
#endif
		}
		
		if ([objData objectForKey:@"y_vel"]) {
#ifdef TOUCHHLE_WORKAROUND
			yVel = convertNumberToDouble([objData objectForKey:@"y_vel"])/100;
#else
			yVel = [[objData objectForKey:@"y_vel"] doubleValue]/100;
#endif
		}
		
		if ([objData objectForKey:@"r_vel"]) {
#ifdef TOUCHHLE_WORKAROUND
			rVel = convertNumberToDouble([objData objectForKey:@"r_vel"])/100;
#else
			rVel = [[objData objectForKey:@"r_vel"] doubleValue]/100;
#endif
		}
		
		if ([objData objectForKey:@"move_distance"]) {
#ifdef TOUCHHLE_WORKAROUND
			distToMove = convertNumberToDouble([objData objectForKey:@"move_distance"]);
#else
			distToMove = [[objData objectForKey:@"move_distance"] doubleValue];
#endif
		}
		
		if ([objData objectForKey:@"move_wait"]) {
#ifdef TOUCHHLE_WORKAROUND
			waitTime = convertNumberToDouble([objData objectForKey:@"move_wait"]);
#else
			waitTime = [[objData objectForKey:@"move_wait"] doubleValue];
#endif
		}
		
		if ([objData objectForKey:@"move_trigger"]) {
#ifdef TOUCHHLE_WORKAROUND
			moveTrigger = convertNumberToDouble([objData objectForKey:@"move_trigger"]);
#else
			moveTrigger = [[objData objectForKey:@"move_trigger"] doubleValue];
#endif
		}
		
		//rotate postion based on global rotation (mostly for custom objects)
		double xprime = xPos*cos(offsetR*(3.1415926535/180))-yPos*sin(offsetR*(3.1415926535/180));
		double yprime = xPos*sin(offsetR*(3.1415926535/180))+yPos*cos(offsetR*(3.1415926535/180));
		
		xPos=xprime;
		yPos=yprime;
		
		xPos+=offsetX;
		yPos+=offsetY;
		rotation+=offsetR;
		
		//Shape specific setup
		if ([objType isEqualToString:@"circle"]) {
#ifdef TOUCHHLE_WORKAROUND
			double radius = convertNumberToDouble([objData objectForKey:@"radius"]);
#else
			double radius = [[objData objectForKey:@"radius"] doubleValue];
#endif
			o = [[PhysicsObject alloc] init:new Circle(xPos,yPos,radius,rotation,weight)];
			[o configureCircle];
			if (invisible) [s addInvisToSimulation:o];
			else [s addToSimulation:o];
			
		} else if ([objType isEqualToString:@"square"]) {
#ifdef TOUCHHLE_WORKAROUND
			double width = convertNumberToDouble([objData objectForKey:@"width"]);
			double height = convertNumberToDouble([objData objectForKey:@"height"]);
#else
			double width = [[objData objectForKey:@"width"] doubleValue];
			double height = [[objData objectForKey:@"height"] doubleValue];
#endif
			o = [[PhysicsObject alloc] init:new Square(xPos,yPos,width,height,rotation,weight)];
			[o configureSquare];
			
			//Touch area properties
			if ([objData objectForKey:@"gravityx"]) {
#ifdef TOUCHHLE_WORKAROUND
				double gravity = convertNumberToDouble([objData objectForKey:@"gravityx"]);
#else
				double gravity = [[objData objectForKey:@"gravityx"] doubleValue];
#endif
				gravity/=5000;
				o.gravityX = gravity;
			}
			
			if ([objData objectForKey:@"gravityy"]) {
#ifdef TOUCHHLE_WORKAROUND
				double gravity = convertNumberToDouble([objData objectForKey:@"gravityy"]);
#else
				double gravity = [[objData objectForKey:@"gravityy"] doubleValue];
#endif
				gravity/=5000;
				o.gravityY = gravity;
			}
			
			if ([objData objectForKey:@"telex"]) {
#ifdef TOUCHHLE_WORKAROUND
				double pos = convertNumberToDouble([objData objectForKey:@"telex"]);
#else
				double pos = [[objData objectForKey:@"telex"] doubleValue];
#endif
				o.teleX = pos;
			}
			
			if ([objData objectForKey:@"teley"]) {
#ifdef TOUCHHLE_WORKAROUND
				double pos = convertNumberToDouble([objData objectForKey:@"teley"]);
#else
				double pos = [[objData objectForKey:@"teley"] doubleValue];
#endif
				o.teleY = pos;
			}
			
			if ([objData objectForKey:@"growSpeed"]) {
#ifdef TOUCHHLE_WORKAROUND
				double speed = convertNumberToDouble([objData objectForKey:@"growSpeed"]);
#else
				double speed = [[objData objectForKey:@"growSpeed"] doubleValue];
#endif
				speed/=100;
				o.growSpeed = speed;
			}
			
			if ([objData objectForKey:@"TouchProperty"]) {
				[s addTouchArea:o];
				NSString* touchAreaType = [objData objectForKey:@"TouchProperty"];
				if ([touchAreaType isEqualToString:@"trigger"]) {
					o.areaObjectType = 1;
				} else if ([touchAreaType isEqualToString:@"gravity"]) {
					o.areaObjectType = 2;
				} else if ([touchAreaType isEqualToString:@"grow"]) {
					o.areaObjectType = 3;
				} else if ([touchAreaType isEqualToString:@"teleport"]) {
					o.areaObjectType = 4;
				} else {
					o.areaObjectType = 0;
				}
			} else {
				//Check if invisible (custom objects are invisible as they are visualised by a custom model)
				if (invisible) [s addInvisToSimulation:o];
				else [s addToSimulation:o];
			}
			
		} else if ([objType isEqualToString:@"custom"]) {
			//This is a special object that has a visual and a set of invisible objects
#ifdef TOUCHHLE_WORKAROUND
			double scale = convertNumberToDouble([objData objectForKey:@"scale"]);
#else
			double scale = [[objData objectForKey:@"scale"] doubleValue];
#endif
			//Load invisible subobjects
			NSArray* subObjects = [objData objectForKey:@"Objects"];
			[self loadObjects:subObjects simulation:s isInvisible:true xOffset:xPos yOffset:yPos rOffset:rotation];
			
			//Load 3D model for visual
			NSString* modelName = [objData objectForKey:@"Model"];
			CustomModel* r = [[CustomModel alloc] init];
			r.verts = [CustomModel loadModelFromPath:[[NSBundle mainBundle] pathForResource:modelName ofType:@"bin"] vertCount:r];
			r.textCoords = [CustomModel loadTexMapFromPath:[[NSBundle mainBundle] pathForResource:modelName ofType:@"binmap"]];
			[s addVisual:r];
			
			//Rotates the visuals based on the rotation of one object inside
			//Kind of a hacky way of doing it
			NSMutableArray* invisObj = s.invisObjects;
			PhysicsObject* b = [invisObj objectAtIndex:[invisObj count]-1];
			if (b.moveRVel) r.primaryObjectRot = &b.obj->rotation;
			
			r.x = xPos;
			r.y = yPos;
			r.width = scale;
			r.rotation = rotation;
			[r configureVisualOffsetX:levelOffsetX OffsetY:levelOffsetY];
			[r release];
		} else {
			NSLog(@"Invalid Object!");
		}
		
		if (o) {
			//If object was created, finalise visuals
			[o configureVisualOffsetX:levelOffsetX OffsetY:levelOffsetY];
			o.moveDistance = distToMove;
			o.waitTime = waitTime;
			o.moveXVel = xVel;
			o.moveYVel=yVel;
			o.moveRVel=rVel;
			o.moveTrigger = moveTrigger;
			[o configureMovement];
			
		}
		
		[o release];
	}
}

-(void)setLevelNumber:(int)levelNumber {
	currentLevel = levelNumber;
}

-(void)nextLevel {
	currentLevel++;
	//if (currentLevel+1<[levelFileNames count]) 
}

-(int)levelExists {
	return (currentLevel>=[levelFileNames count]);
}

-(PhysicsManager*)loadCurrentLevel {
	if (!levelFileNames) return nil;
	if (currentLevel<0||currentLevel>=[levelFileNames count]) return nil;
	return [self loadLevel:[[NSBundle mainBundle] pathForResource:[levelFileNames objectAtIndex:currentLevel] ofType:@"plist"]];
}

-(PhysicsManager*)loadResultsLevel {
	if (!resultsLevel) return nil;
	PhysicsManager* ret = [self loadLevel:[[NSBundle mainBundle] pathForResource:resultsLevel ofType:@"plist"]];
	ret.tiltEnabled = 0;
	return ret;
}

-(void)drawBG {
	//Draw BG
	if (bg) {
		[bg draw];
	}
	//Draw stars if they exist
	if (numStars) {
		static int starOffset = 0;
		starOffset+=3;
		for (int i=0; i<STAR_COUNT; i++) {
#define tx 0.0000f
#define ty 0.0000f
#define tx2 1.0000f
#define ty2 1.0000f
			const GLfloat squareCoords[] = {
				tx,  ty,
				tx2,  ty,
				tx, ty2,
				tx2,  ty2,
			};
			
			const GLfloat squareVertices[] = {
				-0.5f, -0.5f, 0.0f,
				0.5f,  -0.5f, 0.0f,
				-0.5f,  0.5f, 0.0f,
				0.5f,   0.5f, 0.0f,
			};
			
			
			
			glPushMatrix();
			glTranslatef((int)(starXpos[i]+starOffset/50)%8000-2500,starYpos[i] , -2000);
			glClientActiveTexture(GL_TEXTURE1);
			//glEnable(GL_TEXTURE_2D); //Disabled because we want white
			glEnableClientState(GL_VERTEX_ARRAY);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			
			glScalef(10,10,10);
			//glScalef(100,100,100);
			
			
			glTexCoordPointer(2, GL_FLOAT, 0, squareCoords);
			glVertexPointer(3, GL_FLOAT, 0, squareVertices);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			glPopMatrix();
			
		}
	}
}

@end
