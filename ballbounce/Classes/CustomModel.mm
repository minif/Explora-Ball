//
//  CustomModel.m
//  ballbounce
//
//  Created by macpro on 7/22/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#import "CustomModel.h"
#include <fstream>

@implementation CustomModel
@synthesize verts;
@synthesize textCoords;
@synthesize vertCount;

@synthesize x;
@synthesize y;
@synthesize z;
@synthesize width;
@synthesize height;
@synthesize rotation;
@synthesize textureToUse;
@synthesize primaryObjectRot;

GLshort data[] = {
1
};

//A non-physics object that is a custom 3D model

+(GLshort*) loadModelFromPath:(NSString*)path vertCount:(CustomModel*)count{
	//Loading the verticies from a .bin file
	NSData* file = [NSData dataWithContentsOfFile:path]; //Autoreleased!
	count.vertCount = file.length/(sizeof(GLshort)*3);
	GLshort* modelData = new GLshort[count.vertCount*3];
	[file getBytes: modelData range:NSMakeRange(0, file.length)];
	return modelData;
}

+(GLfloat*) loadTexMapFromPath:(NSString*)path{
	//Loading texture coords from a .binmap
	NSData* file = [NSData dataWithContentsOfFile:path]; //Autoreleased!
	int count = file.length/(sizeof(short)*2);
	short* modelData = new GLshort[count*2];
	[file getBytes: modelData range:NSMakeRange(0, file.length)];
	GLfloat* textureData = new GLfloat[count*2];
	for (int i=0; i<count*2; i++) {
		textureData[i]=modelData[i]/256.0;
	}
	delete modelData;
	return textureData;
}

+(void) loadTextureFromPath:(NSString*)path intoSlot:(int)slot {
	//TODO: remove, unused
}

- (void)configureVisualOffsetX:(double) offsetX OffsetY:(double) offsetY {
	visualOffsetX = offsetX;
	visualOffsetY = offsetY;
}

- (id)init{
	textureToUse=0;
	z=0;
	visualOffsetX = 0;
	visualOffsetY = 0;
	primaryObjectRot=NULL;
	return self;
}

-(void)draw {
	//Draw, using loaded data
	glActiveTexture(GL_TEXTURE0+textureToUse);
	glEnable(GL_TEXTURE_2D);
	glPushMatrix();
	glClientActiveTexture(GL_TEXTURE0+textureToUse);
	glVertexPointer(3, GL_SHORT, 0, verts);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, textCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glTranslatef(-visualOffsetX, -visualOffsetY, 0.0f);
	glTranslatef(x, y, z); //Position
	glRotatef(rotation, 0, 0, 1);
	if (primaryObjectRot) glRotatef(*primaryObjectRot, 0, 0, 1);
	glScalef(0.00390625*width,0.00390625*width,0.00390625*width);
	glDrawArrays(GL_TRIANGLES, 0, vertCount);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glPopMatrix();
	glDisable(GL_TEXTURE_2D);
}

- (void)dealloc {
	delete verts;
	delete textCoords;
	[super dealloc];
}

@end
