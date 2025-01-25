//
//  PhysicsObject.mm
//  ballbounce
//
//  Created by macpro on 7/17/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#import "PhysicsObject.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "EAGLView.h"

#define Z_DEPTH 0

@implementation PhysicsObject
@synthesize obj;

@synthesize moveDistance;
@synthesize waitTime;
@synthesize moveXVel;
@synthesize moveYVel;
@synthesize moveRVel;
@synthesize areaObjectType;
@synthesize moveTrigger;
@synthesize gravityX;
@synthesize gravityY;
@synthesize teleX;
@synthesize teleY;
@synthesize growSpeed;

- (id)init:(Object*)object {
	//This is a wrapper to the physics object.
	//Note that wrapped objects are also present in the physics manager
	//Initialise all values
	obj = object;
	shapeType = 0;
	direction=0;
	areaObjectType = 0;
	moveTrigger=0;
	visualOffsetX = 0;
	visualOffsetY = 0;
	visualOffsetZ = 0;
	shouldOffsetR = 0;
	gravityX = 0;
	gravityY = 0;
	teleX = 0;
	teleY = 0;
	growSpeed = 0;
	return self;
}

- (void)dealloc {
	delete obj;
	[super dealloc];
}

- (double)getX {
	return obj->getX();
	//return NULL;
}

- (double)getY {
	return obj->getY();
	//return NULL;
}

- (double)getRotation {
	return obj->getRotation();
	//return NULL;
}

- (double)getWidth {
	return obj->width;
}

- (double)getHeight {
	return obj->height;
}

- (void)configureCircle {
	shapeType = 1;
}

- (void)configureSquare {
	shapeType = 0;
}

- (void)configureCustom {
	shapeType = 2;
}

- (void)configureBall {
	shapeType = 3;
}

- (void)configureVisualOffsetX:(double) offsetX OffsetY:(double) offsetY {
	visualOffsetX = offsetX;
	visualOffsetY = offsetY;
}

- (void)configureVisualOffsetZ:(double) offsetZ {
	visualOffsetZ = offsetZ;
}

- (void)configureVisualOffsetR:(double) offsetR {
	visualOffsetR = offsetR;
	shouldOffsetR = 1;
}

- (void)resizeObject:(double) s {
	obj->changeSize(1); //UNFINISHED!!!
	//resising is dealt with by the object itself now, therefore this method is unused and not reccomended
}

- (void)configureMovement {
	//Set up movement (moving platforms)
	//This converts the the distance into initial and final positions
	xInitialPos = [self getX];
	yInitialPos = [self getY];
	if (moveXVel<0) xFinalPos = xInitialPos - moveDistance;
	else xFinalPos = xInitialPos + moveDistance;
	
	if (moveYVel<0) yFinalPos = yInitialPos - moveDistance;
	else yFinalPos = yInitialPos + moveDistance;
	
	if (xInitialPos<xFinalPos) {
		moveXSmaller = xInitialPos;
		moveXBigger = xFinalPos;
	} else {
		moveXSmaller = xFinalPos;
		moveXBigger = xInitialPos;
	}
	
	if (yInitialPos<yFinalPos) {
		moveYSmaller = yInitialPos;
		moveYBigger = yFinalPos;
	} else {
		moveYSmaller = yFinalPos;
		moveYBigger = yInitialPos;
	}
	
	waitTimer=0;
	direction=1;
}

- (void)updateMovement:(int)triggers {
	//Handle movement for moving platforms
	//Moving platforms are assumed static and use static velocities
	if (direction==0) return;
	if (waitTimer>0) {
		//If waiting, don't move
		obj->xvel_static = 0;
		obj->yvel_static = 0;
		obj->rvel_static = 0;
		if (moveTrigger!=0) {
			//If triggered, end waiting
			if (triggers!=0) {
				if (direction==-1) waitTimer=0;
			} else {
				if (direction==1) waitTimer=0;
			}
		} else waitTimer--;
	} else {
		if (moveTrigger!=0) {
			//If triggered, enable movement
			if (triggers!=0) {
				direction = 1;
			} else {
				direction = -1;
			}
		}
		
		//Perform movement
		double absDirectionX = moveXVel*direction;
		double absDirectionY = moveYVel*direction;
		
		obj->xvel_static = absDirectionX;
		obj->yvel_static = absDirectionY;
		obj->rvel_static = moveRVel;
		
		//check if movement is done
		if ((xInitialPos!=xFinalPos || yInitialPos!=yFinalPos)) {
			if ((obj->x<=moveXSmaller&&absDirectionX<0)||(obj->x>=moveXBigger&&absDirectionX>0)||(obj->y<=moveYSmaller&&absDirectionY<0)||(obj->y>=moveYBigger&&absDirectionY>0)) {
				//Stop movement
				if (obj->x<moveXSmaller) obj->x = moveXSmaller;
				else if (obj->x>moveXBigger) obj->x = moveXBigger;
				if (obj->y<moveYSmaller) obj->y = moveYSmaller;
				else if (obj->y>moveYBigger) obj->y = moveYBigger;
				
				obj->xvel_static = 0;
				obj->yvel_static = 0;
				obj->rvel_static = 0;
				
				if(moveTrigger!=0) {
					waitTimer = 1;
				} else {
					waitTimer = waitTime;
					direction*=-1;
				}
			}
		}
	}
}

- (void)draw {
	//Draw the physics object, depending on the shape
	//Hard coded verts and texture coords
	//TODO: Move to its own .h file
	const GLfloat squareVertices[] = {
		+0.5f, +0.5f, +0.5f, 
        -0.5f, +0.5f, +0.5f, 
        +0.5f, -0.5f, +0.5f, 
        -0.5f, -0.5f, +0.5f, 
    };
	
	const GLfloat squareVertices2[] = {
        -0.5f, -0.5f, -0.5f, 
        -0.5f, -0.5f, +0.5f, 
        -0.5f, +0.5f, -0.5f, 
		-0.5f, +0.5f, +0.5f, 
		+0.5f, +0.5f, -0.5f, 
        +0.5f, +0.5f, +0.5f, 
    };
	
	const GLfloat squareVertices3[] = {
		+0.5f, +0.5f, -0.5f, 
        +0.5f, +0.5f, +0.5f, 
        +0.5f, -0.5f, -0.5f, 
        +0.5f, -0.5f, +0.5f, 
        -0.5f, -0.5f, -0.5f, 
        -0.5f, -0.5f, +0.5f, 
    };
	const GLfloat squareCoords[] = {
		0.5000f,  0.0000,
		0.1250f,  0.0000,
		0.5000f,  0.1230,
		0.1250f,  0.1230,
	};
	const GLfloat squareCoords2[] = {
		0.0000,  0.1230,
		0.0000,  0.0000,
		0.1250f,  0.1230,
		0.1250f,  0.0000,
		0.5000f,  0.1230,
		0.5000f,  0.0000,
	};
	const GLfloat circleVerticesOuter[] = {
		0.499924,0.008726,0.000000,
		0.432947,0.007557,0.250000,
		0.359670,-0.347329,0.000000,
		0.311483,-0.300796,0.250000,
		0.008726,-0.499924,0.000000,
		0.007557,-0.432947,0.250000,
		-0.347329,-0.359670,0.000000,
		-0.300796,-0.311483,0.250000,
		-0.499924,-0.008726,0.000000,
		-0.432947,-0.007557,0.250000,
		-0.359670,0.347329,0.000000,
		-0.311483,0.300796,0.250000,
		-0.008726,0.499924,0.000000,
		-0.007557,0.432947,0.250000,
		0.347329,0.359670,0.000000,
		0.300796,0.311483,0.250000,
		0.499924,0.008726,0.000000,
		0.432947,0.007557,0.250000,
	};
	const GLfloat circleVerticesBack[] = {
		0.432947,0.007557,-0.250000,
		0.499924,0.008726,0.000000,
		0.311483,-0.300796,-0.250000,
		0.359670,-0.347329,0.000000,
		0.007557,-0.432947,-0.250000,
		0.008726,-0.499924,0.000000,
		-0.300796,-0.311483,-0.250000,
		-0.347329,-0.359670,0.000000,
		-0.432947,-0.007557,-0.250000,
		-0.499924,-0.008726,0.000000,
		-0.311483,0.300796,-0.250000,
		-0.359670,0.347329,0.000000,
		-0.007557,0.432947,-0.250000,
		-0.008726,0.499924,0.000000,
		0.300796,0.311483,-0.250000,
		0.347329,0.359670,0.000000,
		0.432947,0.007557,-0.250000,
		0.499924,0.008726,0.000000,
	};
	const GLfloat circleVerticesMiddle[] = {
		0.432947,0.007557,0.250000,
		0.249962,0.004363,0.433013,
		0.311483,-0.300796,0.250000,
		0.179835,-0.173664,0.433013,
		0.007557,-0.432947,0.250000,
		0.004363,-0.249962,0.433013,
		-0.300796,-0.311483,0.250000,
		-0.173664,-0.179835,0.433013,
		-0.432947,-0.007557,0.250000,
		-0.249962,-0.004363,0.433013,
		-0.311483,0.300796,0.250000,
		-0.179835,0.173665,0.433013,
		-0.007557,0.432947,0.250000,
		-0.004363,0.249962,0.433013,
		0.300796,0.311483,0.250000,
		0.173665,0.179835,0.433013,
		0.432947,0.007557,0.250000,
		0.249962,0.004363,0.433013,
	};
	const GLfloat circleVerticesInner[] = {
		0.000000,0.000000,0.500000,
		0.249962,0.004363,0.433013,
		0.173665,0.179835,0.433013,
		-0.004363,0.249962,0.433013,
		-0.179835,0.173665,0.433013,
		-0.249962,-0.004363,0.433013,
		-0.173664,-0.179835,0.433013,
		0.004363,-0.249962,0.433013,
		0.179835,-0.173664,0.433013,
		0.249962,0.004363,0.433013,
	};
	
	const GLfloat circleCoordsBack[] = {
		0.116619f,  0.188445f, 
		0.124991f,  0.188591f,  
		0.101436f,  0.149901f,
		0.107459f,  0.144084f,  
		0.063445f,  0.133382f,  
		0.063591f,  0.125010f,  
		0.024901f,  0.148565f, 
		0.019084f,  0.142542f,  
		0.008382f,  0.186556f,
		0.000010f,  0.186410f,  
		0.023565f,  0.225100f,  
		0.017542f,  0.230916f,  
		0.061556f,  0.241619f,
		0.061410f,  0.249991f,  
		0.100100f,  0.226436f,
		0.105916f,  0.232459f,  
		0.116619f,  0.188445f,
		0.124991f,  0.188591f,  
	};
	
	const GLfloat circleCoordsOuter[] = {
		0.124991f,  0.188591f,  
		0.116619f,  0.188445f,  
		0.107459f,  0.144084f,  
		0.101436f,  0.149901f,  
		0.063591f,  0.125010f,  
		0.063445f,  0.133382f,  
		0.019084f,  0.142542f,  
		0.024901f,  0.148565f,  
		0.000010f,  0.186410f,  
		0.008382f,  0.186556f,  
		0.017542f,  0.230916f,  
		0.023565f,  0.225100f,  
		0.061410f,  0.249991f,  
		0.061556f,  0.241619f,  
		0.105916f,  0.232459f,  
		0.100100f,  0.226436f,  
		0.124991f,  0.188591f,  
		0.116619f,  0.188445f,
	};
	
	const GLfloat circleCoordsMiddle[] = {
		0.1166185f,  0.1884445f,  
		0.0937455f,  0.1880455f,  
		0.1014355f,  0.1499005f,  
		0.0849795f,  0.1657920f,  
		0.0634445f,  0.1333815f,  
		0.0630455f,  0.1562550f,  
		0.0249005f,  0.1485645f,  
		0.0407920f,  0.1650205f,  
		0.0083815f,  0.1865555f,  
		0.0312550f,  0.1869545f,  
		0.0235645f,  0.2250995f,  
		0.0400205f,  0.2092080f,  
		0.0615555f,  0.2416185f,  
		0.0619545f,  0.2187455f,  
		0.1000995f,  0.2264355f,  
		0.0842080f,  0.2099795f,  
		0.1166185f,  0.1884445f,  
		0.0937455f,  0.1880455f,  
	};
	
	const GLfloat circleCoordsInner[] = {
		0.0625000f,  0.1875000f,  
		0.0937455f,  0.1880455f,  
		0.0842080f,  0.2099795f,  
		0.0619545f,  0.2187455f,  
		0.0400205f,  0.2092080f,  
		0.0312550f,  0.1869545f,  
		0.0407920f,  0.1650205f,  
		0.0630455f,  0.1562550f,  
		0.0849795f,  0.1657920f,  
		0.0937455f,  0.1880455f, 
	};
	
	const GLfloat cylVerticesCircle[] = {
		0.000000,0.000000,0.500000,
		-0.499924,0.008726,0.500000,
		-0.359670,-0.347329,0.500000,
		-0.008726,-0.499924,0.500000,
		0.347329,-0.359670,0.500000,
		0.499924,-0.008726,0.500000,
		0.359670,0.347329,0.500000,
		0.008726,0.499924,0.500000,
		-0.347329,0.359670,0.500000,
		-0.499924,0.008726,0.500000,
	};
	
	const GLfloat cylVerticesTube[] = {
		-0.499924,0.008726,0.500000,
		-0.499924,0.008726,-0.500000,
		-0.359670,-0.347329,0.500000,
		-0.359670,-0.347329,-0.500000,
		-0.008726,-0.499924,0.500000,
		-0.008726,-0.499924,-0.500000,
		0.347329,-0.359670,0.500000,
		0.347329,-0.359670,-0.500000,
		0.499924,-0.008726,0.500000,
		0.499924,-0.008726,-0.500000,
		0.359670,0.347329,0.500000,
		0.359670,0.347329,-0.500000,
		0.008726,0.499924,0.500000,
		0.008726,0.499924,-0.500000,
		-0.347329,0.359670,0.500000,
		-0.347329,0.359670,-0.500000,
		-0.499924,0.008726,0.500000,
		-0.499924,0.008726,-0.500000,
	};
	
	const GLfloat cylCoordsCircle[] = {
		0.0625000f,  0.0625000f,  
		0.0000095f,  0.0635910f,  
		0.0175415f,  0.0190840f,  
		0.0614095f,  0.0000095f,  
		0.1059160f,  0.0175415f,  
		0.1249905f,  0.0614095f,  
		0.1074590f,  0.1059160f,  
		0.0635910f,  0.1249905f,  
		0.0190840f,  0.1074590f,  
		0.0000095f,  0.0635910f,  
	};
	
	const GLfloat cylCoordsTube[] = {
		0.1250000f,  0.0000000f,  
		0.1250000f,  0.1250000f,  
		0.1718750f,  0.0000000f,  
		0.1718750f,  0.1250000f,  
		0.2187500f,  0.0000000f,  
		0.2187500f,  0.1250000f,  
		0.2656250f,  0.0000000f,  
		0.2656250f,  0.1250000f,  
		0.3125000f,  0.0000000f,  
		0.3125000f,  0.1250000f,  
		0.3593750f,  0.0000000f,  
		0.3593750f,  0.1250000f,  
		0.4062500f,  0.0000000f,  
		0.4062500f,  0.1250000f,  
		0.4531250f,  0.0000000f,  
		0.4531250f,  0.1250000f,  
		0.5000000f,  0.0000000f,  
		0.5000000f,  0.1250000,
	};
	
	glActiveTexture(GL_TEXTURE0);
	glEnable(GL_TEXTURE_2D);
	glPushMatrix();
	glTranslatef(-visualOffsetX, -visualOffsetY, visualOffsetZ);
	//Draw visual depending on the current shape
	switch(shapeType) {
		case 0://Square
			glClientActiveTexture(GL_TEXTURE0);
			glEnableClientState(GL_VERTEX_ARRAY);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			
			glTranslatef([self getX], [self getY], Z_DEPTH); //Position
			glRotatef([self getRotation], 0, 0, 1);
			glScalef([self getWidth], [self getHeight], 20);
			
			
			glTexCoordPointer(2, GL_FLOAT, 0, squareCoords);
			glVertexPointer(3, GL_FLOAT, 0, squareVertices);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			glTexCoordPointer(2, GL_FLOAT, 0, squareCoords2);
			glVertexPointer(3, GL_FLOAT, 0, squareVertices2);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 6);
			
			glTexCoordPointer(2, GL_FLOAT, 0, squareCoords2);
			glVertexPointer(3, GL_FLOAT, 0, squareVertices3);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 6);
			
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			break;
		case 1://Circle
			glClientActiveTexture(GL_TEXTURE0);
			glEnableClientState(GL_VERTEX_ARRAY);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			
			glTranslatef([self getX], [self getY], Z_DEPTH); //Position
			glRotatef([self getRotation], 0, 0, 1);
			if (obj->weight) glRotatef(-[self getX]*2*(180/3.1415926535)/[self getWidth], 0, 0, 1);
			glScalef([self getWidth], [self getHeight], 20);
			
			glTexCoordPointer(2, GL_FLOAT, 0, cylCoordsCircle);
			glVertexPointer(3, GL_FLOAT, 0, cylVerticesCircle);
			glDrawArrays(GL_TRIANGLE_FAN, 0, 10);
			
			glTexCoordPointer(2, GL_FLOAT, 0, cylCoordsTube);
			glVertexPointer(3, GL_FLOAT, 0, cylVerticesTube);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 18);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			break;
		case 3://Ball (aka player)
			glClientActiveTexture(GL_TEXTURE0);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			glEnableClientState(GL_VERTEX_ARRAY);

			glTranslatef([self getX], [self getY], Z_DEPTH); //Position
			//Hacky way of "rolling"
			if (shouldOffsetR) glRotatef(visualOffsetR, 0, 0, 1);
			else glRotatef(-[self getX]*2*(180/3.1415926535)/[self getWidth], 0, 0, 1);
			glScalef([self getWidth], [self getHeight], [self getHeight]);
			
			glTexCoordPointer(2, GL_FLOAT, 0, circleCoordsOuter);
			glVertexPointer(3, GL_FLOAT, 0, circleVerticesOuter);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 18);
			
			glTexCoordPointer(2, GL_FLOAT, 0, circleCoordsBack);
			glVertexPointer(3, GL_FLOAT, 0, circleVerticesBack);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 18);
			
			glTexCoordPointer(2, GL_FLOAT, 0, circleCoordsMiddle);
			glVertexPointer(3, GL_FLOAT, 0, circleVerticesMiddle);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 18);
			
			glTexCoordPointer(2, GL_FLOAT, 0, circleCoordsInner);
			glVertexPointer(3, GL_FLOAT, 0, circleVerticesInner);
			glDrawArrays(GL_TRIANGLE_FAN, 0, 10);
			
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			break;
	}
	
	glPopMatrix();
}

@end
