//
//  CustomModel.h
//  ballbounce
//
//  Created by macpro on 7/22/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#include "object.h"

@interface CustomModel : NSObject {
	GLshort* verts;
	GLfloat* textCoords;
	double* primaryObjectRot;
	int triangleType;
	int vertCount;
	int textureToUse;
	double x;
	double y;
	double z;
	double width;
	double height;
	double rotation;
	double visualOffsetX;
	double visualOffsetY;
}

+(GLshort*) loadModelFromPath:(NSString*)path vertCount:(CustomModel*)count;
+(GLfloat*) loadTexMapFromPath:(NSString*)path;
+(void) loadTextureFromPath:(NSString*)path intoSlot:(int)slot;
-(void)configureVisualOffsetX:(double) offsetX OffsetY:(double) offsetY;
-(void)draw;

@property GLshort* verts;
@property GLfloat* textCoords;
@property int vertCount;
@property double x;
@property double y;
@property double z;
@property double width;
@property double height;
@property double rotation;
@property double* primaryObjectRot;
@property int textureToUse;
@end
