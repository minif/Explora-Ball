//
//  MenuButton.h
//  ballbounce
//
//  Created by macpro on 7/27/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface MenuButton : NSObject {
	double xPos;
	double yPos;
	double width;
	double height;
	int buttonID;
	int prevLevelID;
	int locked;
	double textureOffsetX;
	double textureOffsetY;
	double textureOffsetX2;
	double textureOffsetY2;
	int textureNumber;
	double rotation;
	
	double visualOffsetX;
	double visualOffsetY;
	double visualOffsetZ;
}

+(NSMutableArray*) createMainMenu;
+(NSMutableArray*) createArcadeDifficultySelection;
+(NSMutableArray*) createPlayPromptSelection;
+(NSMutableArray*) createLevelSelection;
+(NSMutableArray*) createFreePlayLevelSelection:(int)levels;
+(NSMutableArray*) createGameOverScreen;
+(NSMutableArray*) createResultsScreen;
+(NSMutableArray*) createPauseScreen;
-(void)configureButton:(int)id xPosition:(double)x yPostition:(double)y buttonWidth:(double)bWidth buttonHeight:(double)bHeight;
-(void)configureVisual:(int)texNum offsetX:(double)x offsetY:(double)y;
-(void)configureVisualManual:(int)texNum offsetX:(double)x1 offsetY:(double)y1 offsetX2:(double)x2 offsetY2:(double)y2;
-(void)configureVisualOffsetX:(double)xoff OffsetY:(double)yoff;
-(void)configureVisualOffsetZ:(double)zoff;
-(void)draw;
-(int)isTouchedposX:(double)x posY:(double)y;

@property int prevLevelID;
@property double rotation;
@property double xPos;
@property double yPos;
@property int locked;
@property int buttonID;

@end
