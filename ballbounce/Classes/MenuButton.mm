//
//  MenuButton.m
//  ballbounce
//
//  Created by macpro on 7/27/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#import "MenuButton.h"
#define LEVELSELECT_BUTTON_SIZE 65
#define LEVELSELECT_BUTTON_SPACING 70
#define LEVELSELECT_BUTTON_YOFFSET -65

#define LEVELMENU_Z_OFFSET 20

#ifdef TOUCHHLE_WORKAROUND
#include <stdio.h>

double convertNumberToDouble (NSNumber* num);

#endif

@implementation MenuButton

@synthesize prevLevelID;
@synthesize rotation;
@synthesize xPos;
@synthesize yPos;
@synthesize locked;
@synthesize buttonID;

//Menu button creation and logic

+(NSMutableArray*) createMainMenu {
	NSMutableArray* menu = [[NSMutableArray alloc] init];
	
	MenuButton* playB = [[MenuButton alloc] init];
	[playB configureButton:1 xPosition:0 yPostition:-50 buttonWidth:80 buttonHeight:80];
	[playB configureVisual:0 offsetX:6 offsetY:1];
	[menu addObject:playB];
	
	MenuButton* freePlayB = [[MenuButton alloc] init];
	[freePlayB configureButton:2 xPosition:-128 yPostition:-50 buttonWidth:80 buttonHeight:80];
	[freePlayB configureVisual:0 offsetX:6 offsetY:1];
	[menu addObject:freePlayB];
	
	MenuButton* arcadePlayB = [[MenuButton alloc] init];
	[arcadePlayB configureButton:3 xPosition:128 yPostition:-50 buttonWidth:80 buttonHeight:80];
	[arcadePlayB configureVisual:0 offsetX:6 offsetY:1];
	[menu addObject:arcadePlayB];
	
	MenuButton* titleText = [[MenuButton alloc] init];
	[titleText configureButton:0 xPosition:0 yPostition:80 buttonWidth:256 buttonHeight:96];
	[titleText configureVisualManual:1 offsetX:0.0f offsetY:0.8125f offsetX2:0.499f offsetY2:0.999f];
	[menu addObject:titleText];
	
	MenuButton* playText = [[MenuButton alloc] init];
	[playText configureButton:0 xPosition:0 yPostition:-100 buttonWidth:48 buttonHeight:24];
	[playText configureVisualManual:0 offsetX:0.5f offsetY:0.0f offsetX2:0.593f offsetY2:0.046f];
	[menu addObject:playText];
	
	MenuButton* freePlayText = [[MenuButton alloc] init];
	[freePlayText configureButton:0 xPosition:-128 yPostition:-100 buttonWidth:96 buttonHeight:24];
	[freePlayText configureVisualManual:0 offsetX:0.593f offsetY:0.0f offsetX2:0.781f offsetY2:0.046f];
	[menu addObject:freePlayText];
	
	MenuButton* arcadeText = [[MenuButton alloc] init];
	[arcadeText configureButton:0 xPosition:128 yPostition:-100 buttonWidth:72 buttonHeight:24];
	[arcadeText configureVisualManual:0 offsetX:0.5f offsetY:0.047f offsetX2:0.640f offsetY2:0.093f];
	[menu addObject:arcadeText];
	
	MenuButton* debugb = [[MenuButton alloc] init];
	[debugb configureButton:9 xPosition:200 yPostition:-130 buttonWidth:40 buttonHeight:40];
	[debugb configureVisual:0 offsetX:6 offsetY:2];
	[menu addObject:debugb];
	
	MenuButton* debugb2 = [[MenuButton alloc] init];
	[debugb2 configureButton:10 xPosition:200 yPostition:-70 buttonWidth:40 buttonHeight:40];
	[debugb2 configureVisual:0 offsetX:6 offsetY:3];
	[menu addObject:debugb2];
	
	MenuButton* debugb3 = [[MenuButton alloc] init];
	[debugb3 configureButton:20 xPosition:200 yPostition:-10 buttonWidth:40 buttonHeight:40];
	[debugb3 configureVisual:0 offsetX:2 offsetY:0];
	[menu addObject:debugb3];
	
	MenuButton* volumeText = [[MenuButton alloc] init];
	[volumeText configureButton:0 xPosition:200 yPostition:-40 buttonWidth:48 buttonHeight:12];
	[volumeText configureVisualManual:0 offsetX:0.502f offsetY:0.1563 offsetX2:0.623f offsetY2:0.1875];
	[menu addObject:volumeText];
	
	
	MenuButton* buttonCtrText = [[MenuButton alloc] init];
	[buttonCtrText configureButton:0 xPosition:210 yPostition:-100 buttonWidth:96 buttonHeight:12];
	[buttonCtrText configureVisualManual:0 offsetX:0.6878f offsetY:0.1563 offsetX2:0.9873f offsetY2:0.1875];
	[menu addObject:buttonCtrText];
	
	MenuButton* buttonSensText = [[MenuButton alloc] init];
	[buttonSensText configureButton:0 xPosition:200 yPostition:-160 buttonWidth:96 buttonHeight:12];
	[buttonSensText configureVisualManual:0 offsetX:0.7505f offsetY:0.1253 offsetX2:0.9997f offsetY2:0.1563];
	[menu addObject:buttonSensText];
	
	return menu;
}

+(NSMutableArray*) createArcadeDifficultySelection {
	NSMutableArray* menu = [[NSMutableArray alloc] init];
	
	MenuButton* diffic = [[MenuButton alloc] init];
	[diffic configureButton:1 xPosition:-64 yPostition:-50 buttonWidth:80 buttonHeight:80];
	[diffic configureVisual:0 offsetX:0 offsetY:1];
	[menu addObject:diffic];
	
	MenuButton* confirm = [[MenuButton alloc] init];
	[confirm configureButton:2 xPosition:64 yPostition:-50 buttonWidth:80 buttonHeight:80];
	[confirm configureVisual:0 offsetX:3 offsetY:0];
	[menu addObject:confirm];
	
	MenuButton* titleText = [[MenuButton alloc] init];
	[titleText configureButton:0 xPosition:0 yPostition:130 buttonWidth:256 buttonHeight:64];
	[titleText configureVisualManual:1 offsetX:0.5f offsetY:0.5f offsetX2:0.999f offsetY2:0.624f];
	[menu addObject:titleText];
	
	MenuButton* descText = [[MenuButton alloc] init];
	[descText configureButton:0 xPosition:0 yPostition:70 buttonWidth:256 buttonHeight:40];
	[descText configureVisualManual:0 offsetX:0.50f offsetY:0.312f offsetX2:0.999f offsetY2:0.390f];
	[menu addObject:descText];
	
	MenuButton* hardText = [[MenuButton alloc] init];
	[hardText configureButton:0 xPosition:0 yPostition:30 buttonWidth:256 buttonHeight:0];
	[hardText configureVisualManual:0 offsetX:0.50f offsetY:0.391f offsetX2:0.999f offsetY2:0.437f];
	[menu addObject:hardText];
	
	MenuButton* difficText = [[MenuButton alloc] init];
	[difficText configureButton:0 xPosition:-64 yPostition:-100 buttonWidth:96 buttonHeight:24];
	[difficText configureVisualManual:0 offsetX:0.640f offsetY:0.047f offsetX2:0.828f offsetY2:0.093f];
	[menu addObject:difficText];
	
	MenuButton* startText = [[MenuButton alloc] init];
	[startText configureButton:0 xPosition:64 yPostition:-100 buttonWidth:48 buttonHeight:24];
	[startText configureVisualManual:0 offsetX:0.781f offsetY:0.0f offsetX2:0.874f offsetY2:0.046f];
	[menu addObject:startText];
	
	
	MenuButton* back = [[MenuButton alloc] init];
	[back configureButton:9999 xPosition:-220 yPostition:140 buttonWidth:40 buttonHeight:40];
	[back configureVisual:0 offsetX:3 offsetY:2];
	[menu addObject:back];
	
	return menu;
}

+(NSMutableArray*) createPlayPromptSelection {
	NSMutableArray* menu = [[NSMutableArray alloc] init];
	
	MenuButton* select = [[MenuButton alloc] init];
	[select configureButton:1 xPosition:-64 yPostition:-50 buttonWidth:80 buttonHeight:80];
	[select configureVisual:0 offsetX:2 offsetY:1];
	[menu addObject:select];
	
	MenuButton* contin = [[MenuButton alloc] init];
	[contin configureButton:2 xPosition:64 yPostition:-50 buttonWidth:80 buttonHeight:80];
	[contin configureVisual:0 offsetX:3 offsetY:1];
	[menu addObject:contin];
	
	MenuButton* titleText = [[MenuButton alloc] init];
	[titleText configureButton:0 xPosition:0 yPostition:130 buttonWidth:256 buttonHeight:64];
	[titleText configureVisualManual:1 offsetX:0.5f offsetY:0.625f offsetX2:0.999f offsetY2:0.749f];
	[menu addObject:titleText];
	
	MenuButton* back = [[MenuButton alloc] init];
	[back configureButton:9999 xPosition:-220 yPostition:140 buttonWidth:40 buttonHeight:40];
	[back configureVisual:0 offsetX:3 offsetY:2];
	[menu addObject:back];
	
	MenuButton* levelSelectText = [[MenuButton alloc] init];
	[levelSelectText configureButton:0 xPosition:-64 yPostition:-100 buttonWidth:120 buttonHeight:24];
	[levelSelectText configureVisualManual:0 offsetX:0.50f offsetY:0.093f offsetX2:0.734f offsetY2:0.140f];
	[menu addObject:levelSelectText];
	
	MenuButton* startText = [[MenuButton alloc] init];
	[startText configureButton:0 xPosition:64 yPostition:-100 buttonWidth:48 buttonHeight:24];
	[startText configureVisualManual:0 offsetX:0.781f offsetY:0.0f offsetX2:0.874f offsetY2:0.046f];
	[menu addObject:startText];
	
	return menu;
}

+(NSMutableArray*) createLevelSelection {
	NSMutableArray* menu = [[NSMutableArray alloc] init];
	
	NSDictionary* levelListDict = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levels" ofType:@"plist"]];
	NSArray* levelFileNames = [levelListDict objectForKey:@"Worlds"];
	
	int startCol = -(LEVELSELECT_BUTTON_SPACING/2)*([levelFileNames count]-1);
	int levelCount = [[levelListDict objectForKey:@"Levels"] count];
	
	MenuButton* titleText = [[MenuButton alloc] init];
	[titleText configureButton:0 xPosition:0 yPostition:130 buttonWidth:256 buttonHeight:64];
	[titleText configureVisualManual:1 offsetX:0.5f offsetY:0.75f offsetX2:0.999f offsetY2:0.874f];
	[menu addObject:titleText];
	
	for (int i=0; i<[levelFileNames count]; i++) {
		NSDictionary* worldDict = [levelFileNames objectAtIndex:i];
		
		for (int j=0; j<3; j++) {
			int packA,packB,packC,bID;
			//Read levels from plist
#ifdef TOUCHHLE_WORKAROUND
			packA = convertNumberToDouble([worldDict objectForKey:@"a"]);
			packB = convertNumberToDouble([worldDict objectForKey:@"b"]);
			packC = convertNumberToDouble([worldDict objectForKey:@"c"]);
#else
			packA = [[worldDict objectForKey:@"a"] doubleValue];
			packB = [[worldDict objectForKey:@"b"] doubleValue];
			packC = [[worldDict objectForKey:@"c"] doubleValue];
#endif
			if (j==0) bID=packA;
			else if (j==1) bID=packB;
			else bID=packC;
			
			//Set menu button ID to that of the level number plus 1
			
			MenuButton* packSelect = [[MenuButton alloc] init];
			[packSelect configureButton:bID+1 xPosition:startCol+(LEVELSELECT_BUTTON_SPACING*i) yPostition:(LEVELSELECT_BUTTON_SPACING*-j)+LEVELSELECT_BUTTON_SPACING+LEVELSELECT_BUTTON_YOFFSET buttonWidth:LEVELSELECT_BUTTON_SIZE buttonHeight:LEVELSELECT_BUTTON_SIZE];
			[packSelect configureVisual:0 offsetX:j offsetY:2];
			packSelect.prevLevelID = levelCount;
			if ([menu count]) {
				MenuButton* prevButton = [menu objectAtIndex:[menu count]-1];
				prevButton.prevLevelID = bID;
			}
			[menu addObject:packSelect];
			[packSelect release];
		}
	}
	
	//Do the pack icons
	for (int i=0; i<[levelFileNames count]; i++) {
		MenuButton* packIcon = [[MenuButton alloc] init];
		[packIcon configureButton:0 xPosition:startCol+(LEVELSELECT_BUTTON_SPACING*i) yPostition:(LEVELSELECT_BUTTON_SPACING)+LEVELSELECT_BUTTON_SPACING+LEVELSELECT_BUTTON_YOFFSET buttonWidth:64 buttonHeight:64];
		[packIcon configureVisual:0 offsetX:i offsetY:-2];
		if (i>=4) [packIcon configureVisual:0 offsetX:i-4 offsetY:-1];
		[menu addObject:packIcon];
	}
	
	MenuButton* back = [[MenuButton alloc] init];
	[back configureButton:9999 xPosition:-220 yPostition:140 buttonWidth:40 buttonHeight:40];
	[back configureVisual:0 offsetX:3 offsetY:2];
	[menu addObject:back];
	
	[levelListDict release];
	return menu;
}

+(NSMutableArray*) createFreePlayLevelSelection:(int)levels {
	NSMutableArray* menu = [[NSMutableArray alloc] init];
	
	MenuButton* titleText = [[MenuButton alloc] init];
	[titleText configureButton:0 xPosition:0 yPostition:130 buttonWidth:256 buttonHeight:64];
	[titleText configureVisualManual:1 offsetX:0.5f offsetY:0.75f offsetX2:0.999f offsetY2:0.874f];
	[menu addObject:titleText];
	[titleText release];
	
	int startCol = -(LEVELSELECT_BUTTON_SPACING/2)*(levels-1);
	
	//Create "level adder" buttons
	for (int i=0; i<levels; i++) {
		MenuButton* select = [[MenuButton alloc] init];
		[select configureButton:i+1 xPosition:startCol+(i*LEVELSELECT_BUTTON_SPACING) yPostition:-50 buttonWidth:LEVELSELECT_BUTTON_SIZE buttonHeight:LEVELSELECT_BUTTON_SIZE];
		[select configureVisual:0 offsetX:i offsetY:3];
		[menu addObject:select];
		[select release];
	}
	
	MenuButton* back = [[MenuButton alloc] init];
	[back configureButton:9999 xPosition:-220 yPostition:140 buttonWidth:40 buttonHeight:40];
	[back configureVisual:0 offsetX:3 offsetY:2];
	[menu addObject:back];
	[back release];
	
	return menu;
}

+(NSMutableArray*) createGameOverScreen {
	NSMutableArray* menu = [[NSMutableArray alloc] init];
	int startCol = -128;
	
	for (int i=0; i<8; i++) {
		MenuButton* letter = [[MenuButton alloc] init];
		[letter configureButton:0 xPosition:startCol+(i*32) yPostition:10 buttonWidth:32 buttonHeight:64];
		[letter configureVisualManual:0 offsetX:0.502f+(i*0.0625) offsetY:0.188f offsetX2:0.562+(i*0.0625) offsetY2:0.312f];
		//[letter configureVisualOffsetZ:LEVELMENU_Z_OFFSET];
		[menu addObject:letter];
		[letter release];
		if (i==3) startCol+=16;
	}
	
	MenuButton* contin = [[MenuButton alloc] init];
	[contin configureButton:1 xPosition:0 yPostition:-80 buttonWidth:40 buttonHeight:40];
	[contin configureVisual:0 offsetX:1 offsetY:0];
	//[contin configureVisualOffsetZ:LEVELMENU_Z_OFFSET];
	[menu addObject:contin];
	
	return menu;
}

+(NSMutableArray*) createResultsScreen {
	NSMutableArray* menu = [[NSMutableArray alloc] init];
	
	MenuButton* gamemodeTextShowing = [[MenuButton alloc] init];
	[gamemodeTextShowing configureButton:0 xPosition:100 yPostition:70 buttonWidth:192 buttonHeight:32];
	[gamemodeTextShowing configureVisualManual:0 offsetX:0.5f offsetY:0.313f+(0.0625*0) offsetX2:0.874f offsetY2:0.374f+(0.0625*0)];
	[menu addObject:gamemodeTextShowing];
	
	MenuButton* ballsCollectedTextShowing = [[MenuButton alloc] init];
	[ballsCollectedTextShowing configureButton:0 xPosition:20 yPostition:30 buttonWidth:32 buttonHeight:32];
	[ballsCollectedTextShowing configureVisualManual:0 offsetX:0.375f+(0.0625f*1) offsetY:0.627 offsetX2:0.437f+(0.0625f*1) offsetY2:0.687f];
	[menu addObject:ballsCollectedTextShowing];
	
	MenuButton* titleText = [[MenuButton alloc] init];
	[titleText configureButton:0 xPosition:0 yPostition:130 buttonWidth:256 buttonHeight:64];
	[titleText configureVisualManual:0 offsetX:0.5f offsetY:0.001f offsetX2:0.999f offsetY2:0.124f];
	[menu addObject:titleText];
	
	MenuButton* thanksText = [[MenuButton alloc] init];
	[thanksText configureButton:0 xPosition:0 yPostition:-30 buttonWidth:352 buttonHeight:64];
	[thanksText configureVisualManual:0 offsetX:0.126f offsetY:0.126f offsetX2:0.8124f offsetY2:0.249f];
	[menu addObject:thanksText];
	
	MenuButton* gamemodeText = [[MenuButton alloc] init];
	[gamemodeText configureButton:0 xPosition:-100 yPostition:70 buttonWidth:160 buttonHeight:32];
	[gamemodeText configureVisualManual:0 offsetX:0.0f offsetY:0.3125f offsetX2:0.3125f offsetY2:0.374f];
	[menu addObject:gamemodeText];
	
	MenuButton* ballsCollectedText = [[MenuButton alloc] init];
	[ballsCollectedText configureButton:0 xPosition:-120 yPostition:30 buttonWidth:192 buttonHeight:32];
	[ballsCollectedText configureVisualManual:0 offsetX:0.0f offsetY:0.626 offsetX2:0.374f offsetY2:0.687f];
	[menu addObject:ballsCollectedText];
	
	MenuButton* contin = [[MenuButton alloc] init];
	[contin configureButton:1 xPosition:0 yPostition:-85 buttonWidth:40 buttonHeight:40];
	[contin configureVisual:0 offsetX:1 offsetY:0];
	[menu addObject:contin];
	
	return menu;
}

+(NSMutableArray*) createPauseScreen {
	NSMutableArray* menu = [[NSMutableArray alloc] init];
	
	MenuButton* titleText = [[MenuButton alloc] init];
	[titleText configureButton:0 xPosition:0 yPostition:130 buttonWidth:256 buttonHeight:64];
	[titleText configureVisualManual:0 offsetX:0.5f offsetY:0.0f offsetX2:0.999f offsetY2:0.124f];
	[menu addObject:titleText];
	
	
	MenuButton* contin = [[MenuButton alloc] init];
	[contin configureButton:1 xPosition:0 yPostition:-80 buttonWidth:40 buttonHeight:40];
	[contin configureVisual:0 offsetX:1 offsetY:0];
	[menu addObject:contin];
	
	return menu;
}

-(void)configureButton:(int)id xPosition:(double)x yPostition:(double)y buttonWidth:(double)bWidth buttonHeight:(double)bHeight {
	//Set placement on menu
	buttonID = id;
	xPos = x;
	yPos = y;
	width = bWidth;
	height = bHeight;
	prevLevelID = 0;
	rotation=0;
	locked=0;
}
-(void)configureVisual:(int)texNum offsetX:(double)x offsetY:(double)y {
	//Set automated visual (for buttons)
	double txox = x/8.0f;
	double txoy = y/8.0f;
	
	textureOffsetX = 0.0005f+txox;
	textureOffsetY =  0.6245f+txoy;
	textureOffsetX2 = 0.1265f+txox;
	textureOffsetY2 = 0.5005f+txoy;
	
	textureNumber = texNum;
}

-(void)configureVisualManual:(int)texNum offsetX:(double)x1 offsetY:(double)y1 offsetX2:(double)x2 offsetY2:(double)y2 {
	//Set manual visual (for icons and text)
	textureOffsetX = x1;
	textureOffsetY =  y2;
	textureOffsetX2 = x2;
	textureOffsetY2 = y1;
	
	textureNumber = texNum;
}

-(void)draw {
	const GLfloat squareVertices[] = {
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f,
        -0.5f,  0.5f, 0.0f,
        0.5f,   0.5f, 0.0f,
    };
	float tx,tx2,ty,ty2;
	if (locked) {
		//Change texture if locked
		tx = 0.0002f+5/8.0f;
		ty =  0.6245f+1/8.0f;
		tx2 = 0.1265f+5/8.0f;
		ty2 = 0.5005f+1/8.0f;	
	} else {
		tx = textureOffsetX;
		ty = textureOffsetY;
		tx2 = textureOffsetX2;
		ty2 = textureOffsetY2;
	}
	
	const GLfloat squareCoords[] = {
        tx,  ty,
		tx2,  ty,
		tx, ty2,
		tx2,  ty2,
    };
	
	//Draw button
	glActiveTexture(GL_TEXTURE0+textureNumber);
	glPushMatrix();
	glClientActiveTexture(GL_TEXTURE0+textureNumber);
	glEnable(GL_TEXTURE_2D);
	glVertexPointer(3, GL_FLOAT, 0, squareVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, squareCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glTranslatef(visualOffsetX, visualOffsetY, visualOffsetZ); //Position
	glTranslatef(xPos, yPos, 0); //Position
	glRotatef(rotation, 0, 0, 1);
	glScalef(width, height, 0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glPopMatrix();
	glDisable(GL_TEXTURE_2D);
}

-(int)isTouchedposX:(double)x posY:(double)y {
	//Check if button is pressed (base x and y pos for comparison)
	x-=xPos;
	y-=yPos;
	if (abs(x)<width/2 && abs(y)<height/2) return buttonID;
	return 0;
}

-(void)configureVisualOffsetX:(double)xoff OffsetY:(double)yoff {
	visualOffsetX = xoff;
	visualOffsetY = yoff;
}

-(void)configureVisualOffsetZ:(double)zoff {
	visualOffsetZ = zoff;
}

@end
