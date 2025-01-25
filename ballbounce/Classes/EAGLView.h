//
//  EAGLView.h
//  ballbounce
//
//  Created by macpro on 7/15/24.
//  Copyright __MyCompanyName__ 2024. All rights reserved.
//

#import "PhysicsObject.h"
#import "PhysicsManager.h"
#import "LevelLoading.h"
#import "MenuButton.h"
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "SaveManager.h"
#import "SoundEffects.h"


/*
This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
The view content is basically an EAGL surface you render your OpenGL scene into.
Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
*/
@interface EAGLView : UIView<UIAccelerometerDelegate> {
    
@private
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;
    
    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint depthRenderbuffer;
	
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;
	
	//Objects for managing game behaivour
	PhysicsManager* m;
	LevelLoading *levels;
	SoundEffects* sfx;
	SaveManager* save;
	
	//Various game states
	int gamestate;
	int difficulty;
	int haltPhysics;
	int paused;
	int menuPosition;
	int nextLevelFreeplayRange;
	int enableInput;	//Allow menu button taps
	int fadeTimer;
	
	//Touch states
	int touchedButton;
	double lastTouchX;
	double lastTouchY;
	
	//View camera
	double camX;
	double camY;
	
	//Gane states
	int showGameOver;
	int showResults;
	
	//Arrays for each set of menu buttons
	NSMutableArray* activeTouchButtons;
	NSMutableArray* mainMenuButtons;
	NSMutableArray* arcadeMenuButtons;
	NSMutableArray* continueOrLevelMenuButtons;
	NSMutableArray* levelSelectionMenuButtons;
	NSMutableArray* freePlaySelectionMenuButtons;
	NSMutableArray* gameOverScreen;
	NSMutableArray* resultsScreen;
	NSMutableArray* pauseScreen;
	
	//Hardcoded menu elements
	MenuButton* playtestLabel;
	MenuButton* pauseButton;
	
	//Accelerometer controls
	UIAccelerometer* tilt;
	double sensitivity;
	int touchControls;
	double manualTiltLeft;
	double manualTiltRight;
	
	//Game over text and other hard coded menu elements
	int initialCount;	//Time wasting variable
	double gameOverLetterVel[8];
	NSMutableArray* mainMenuBalls;
}

@property NSTimeInterval animationInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;
- (void)drawBlack:(double)alpha;
- (void)handleMenus;

@end
