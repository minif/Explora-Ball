//
//  EAGLView.m
//  ballbounce
//
//  Created by macpro on 7/15/24.
//  Copyright __MyCompanyName__ 2024. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "EAGLView.h"
#import "PVRTexture.h"

#define USE_DEPTH_BUFFER 1

//#define TOUCH_TO_RELOAD_LEVEL

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;


// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
		
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
		
		/*
		 Beginning of our init for the game
		 */
        
        animationInterval = 1.0 / 60.0;
		
		
		//Configure game properties
		gamestate = 0;
		haltPhysics = 0;
		paused = 0;
		menuPosition = 0;
		enableInput=1;
		fadeTimer=0;
		showResults=0;
		touchControls=0;
		
		//Configure button properties
		touchedButton = 0;
		lastTouchX = -999;
		lastTouchY = -999;
		
		//Set up level loading and load the title background
		levels = [[LevelLoading alloc] init];
		[levels loadLevelList];
		[levels loadBGList];
		[levels loadBG:@"title"];
		
		//load menu button texture
		glActiveTexture(GL_TEXTURE0);
		//glDisable(GL_TEXTURE_2D);
		
		//Load the save manager
		save = [[SaveManager alloc] init];
		
		//Load and set up all the menus
		mainMenuButtons = [MenuButton createMainMenu];
		arcadeMenuButtons = [MenuButton createArcadeDifficultySelection];
		continueOrLevelMenuButtons = [MenuButton createPlayPromptSelection];
		levelSelectionMenuButtons = [MenuButton createLevelSelection];
		pauseScreen = [MenuButton createPauseScreen];
		
		pauseButton = [[MenuButton alloc] init];
		[pauseButton configureButton:0 xPosition:190 yPostition:120 buttonWidth:40 buttonHeight:40];
		[pauseButton configureVisual:0 offsetX:0 offsetY:0];
		[pauseButton configureVisualOffsetZ:40];
		
#ifdef PLAYTEST_LABEL 
		playtestLabel = [[MenuButton alloc] init];	
		[playtestLabel configureButton:0 xPosition:0 yPostition:-135 buttonWidth:256 buttonHeight:32];
		[playtestLabel configureVisualManual:0 offsetX:0.5f offsetY:0.5f offsetX2:0.99 offsetY2:0.562f];
		[playtestLabel configureVisualOffsetZ:40];
#endif
		
		gameOverScreen = [MenuButton createGameOverScreen];
		resultsScreen = [MenuButton createResultsScreen];
		
		showGameOver=0;
		
		mainMenuBalls = [[NSMutableArray alloc] init];
		
		//Set up the balls for the main menu
		for (int i=0; i<3; i++) {
			MenuButton* b = [mainMenuButtons objectAtIndex:i];
			PhysicsObject* o = [[PhysicsObject alloc] init:new Circle(b.xPos*1.1,b.yPos*1.1,40,0,0)];
			[o configureBall];
			[o configureVisualOffsetZ:-50];
			[o configureVisualOffsetR:0];
			[mainMenuBalls addObject:o];
			[o release];
		}
		
		//Set up the "time waster" count (this dictates how long to wait before fading to the title screen)
		initialCount = 10;
		
		//Audio setup
		AudioSessionInitialize(NULL, NULL, NULL, NULL);
		//iPhoneOS 2.2 stuff, we want to target 2.0
		//UInt32 sessionCategory = kAudioSessionCategory_SoloAmbientSound;
		//AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
		AudioSessionSetActive(true);
		
		sfx = [[SoundEffects alloc] init];
		levels.soundObject = sfx;
		
		//Accelerometer setup
		//TODO: Figure out how to get this to work on iOS 8+ (as of now it doesn't work)
		tilt = [UIAccelerometer sharedAccelerometer];
		tilt.delegate = self;
		
		//Load settings saved from the save file
		//Load volume level and visual
		[sfx setAudioLevel:save.volumeLevel];
		[[mainMenuButtons objectAtIndex:9] configureVisual:0 offsetX:save.volumeLevel offsetY:0];
		
		//Load touch controls and visual
		if (save.touchControls) {
			tilt.updateInterval = 0;
			[[mainMenuButtons objectAtIndex:8] configureVisual:0 offsetX:4 offsetY:1];
		} else {
			tilt.updateInterval = 1/30;
			[[mainMenuButtons objectAtIndex:8] configureVisual:0 offsetX:6 offsetY:3];
		}
		touchControls=save.touchControls;
		
		//Load increased sensitivity visual
		if (save.sensitivity) sensitivity = 2; 
		else sensitivity = 1;
		[[mainMenuButtons objectAtIndex:7] configureVisual:0 offsetX:6-save.sensitivity offsetY:2];
    }
    return self;
}

- (void)accelerometer:(UIAccelerometer*) accMet didAccelerate:(UIAcceleration*) acc {
	//Handle accelerometer input, which controls the gravity in the game.
	float rotationScalar = sqrt(acc.x*acc.x+acc.y*acc.y+acc.z*acc.z);
	//-1 Y = upright
	//+1 X = sideways home button left
	//-1 Z = on table up
	//Default position is basically 0 -1 0
	
	//float x = acc.x/rotationScalar;
	float y = acc.y/rotationScalar;
	//float z = acc.z/rotationScalar;
	if (m) [m tilt:y*sensitivity];
}

- (void)drawView {
    // Perform all game logic and drawing. This is called once every frame and is our outer loop.
    [EAGLContext setCurrentContext:context];
	
	//Handle OpenGL frame preperation
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
	
	glEnable(GL_DEPTH_TEST);//z filter
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);//Transparecy
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	glFrustumf(-20.0f, 20.0f, -30.0f, 30.0f, 30.0f, 8000.0f);
    glMatrixMode(GL_MODELVIEW);
    
    glClearColor(0.6f, 0.9f, 1.0f, 1.0f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);//z filter
	
	//Handle camera movement
	camX -= (camX-levels.levelOffsetX)/3;
	camY -= (camY-levels.levelOffsetY)/3;
	glTranslatef(camX, camY, -260.0f);
	
#ifdef SPIN_EVERYTHING
	//Janky debug that allows for a perpective shift
	static double d = 0.0;
	d+=1;
	glRotatef(d, 0, 1, 0);
#endif
	
	//Check if we are in game or in the menu
	if (gamestate) {
		enableInput = 1;
#ifdef TOUCH_TO_RELOAD_LEVEL
		m.ballsLeft=999;
#endif
		//Check if a special screen is being shown
		if (showGameOver) {
			//Game over screen
			paused=0;	//Unpause in case game is paused
			activeTouchButtons = gameOverScreen;
			if (touchedButton) {
				//Go back to main menu if x button is tapped
				gamestate = 0;
				[levels loadBG:@"title"];
				if (difficulty==1) menuPosition=2;
				touchedButton=0;
				camX = 0;
				camY = 0;
			} 
			for (int i=0; i<8; i++) {
				//Do letter falling animation
				MenuButton* b = [gameOverScreen objectAtIndex:i];
				gameOverLetterVel[i]+=1;
				b.yPos -= gameOverLetterVel[i];
				if (b.yPos<10) {
					b.yPos=10;
					gameOverLetterVel[i]*=-1;
					gameOverLetterVel[i]/=3;
				}
			}
		} else if (showResults) {
			//Show the results text 
			[m updateSimulation];
			activeTouchButtons = resultsScreen;
			if (touchedButton) {
				//Go back to main menu if button is tapped
				gamestate = 0;
				[levels loadBG:@"title"];
				touchedButton=0;
				showResults=0;
			} 
		} else if (paused) {
			//Show pause screen
			activeTouchButtons = pauseScreen;
			if (touchedButton) {
				//Exit if button is tapped
				gamestate = 0;
				[levels loadBG:@"title"];
				camX = 0;
				camY = 0;
				touchedButton=0;
				showResults=0;
			} 
		} else if (!fadeTimer) {
			//In game
			//Disable menu button inputs
			enableInput = 0;
			
			if (touchControls) {
				//Apply tilt
				[m tilt:manualTiltRight-manualTiltLeft];
			}
			
			[m updateSimulation];	//Perform game update
			if (m.ballsLeft==0) {
				//Level has ended, handle level ending checks
				levels.numBallsToLoad=m.ballsHitGoal;
				if (levels.numBallsToLoad==0) {
					//All balls have fell off the stage, so the game is over
					activeTouchButtons = gameOverScreen;
					showGameOver=1;
					int startCol = -128;
					for (int i=0; i<8; i++) {
						//Reset game over text
						MenuButton* b = [gameOverScreen objectAtIndex:i];
						b.yPos = ((i+1)*200);
						b.xPos = startCol+(i*32);
						[b configureVisualOffsetX: -camX OffsetY: -camY];
						gameOverLetterVel[i]=0;
						if (i==3) startCol+=16;
					}
					
					MenuButton* b = [gameOverScreen objectAtIndex:8];
					[b configureVisualOffsetX: -camX OffsetY: -camY];
					
					touchedButton=0;
					activeTouchButtons = gameOverScreen;
				}
				else {
					//At least one ball has survived so we can move onto the next level
					[levels nextLevel];
					if ([levels levelExists]) {
						//Load results level, as all levels have been completed
						fadeTimer=31;
					} else {
						if (difficulty ==1) {
							//In the normal difficulty, we track game progression, therefore update the save file
							if (levels.currentLevel>save.unlockedLevel) save.unlockedLevel = levels.currentLevel;
							save.lastLevel = levels.currentLevel;
							[save saveFile];
						}
						//Check if we should change the background or just jump the level
						if ([levels levelChangesBG]) fadeTimer=31;
						else {
							[m release]; 
							m = [levels loadCurrentLevel];
						}
					}
				}
			}
		}
		//Do a lot of the drawing
		[levels drawBG];
		[m drawAll];	//Draw all objects in the level
		
		//Draw pause button
		glEnable(GL_BLEND);	//Transparency for the pause button
		glPushMatrix();
		glTranslatef(-camX, -camY, 0.0f);
		glDisable(GL_DEPTH_TEST);//z filter, pause button is on top of screen so ignore depth testing
		if (!showResults) [pauseButton draw];
		glEnable(GL_DEPTH_TEST);//z filter
		glPopMatrix();
		
		//Draw pause menu
		if (paused) {
			glClear(GL_DEPTH_BUFFER_BIT);//z filter
			glPushMatrix();
			glTranslatef(-camX, -camY, 0.0f);
			for(int i=0; i<[pauseScreen count]; i++) {
				[[pauseScreen objectAtIndex:i] draw];
			}
			glPopMatrix();
		}
		
		//Draw game over text
		if (showGameOver) {
			glClear(GL_DEPTH_BUFFER_BIT);//z filter
			for(int i=0; i<[gameOverScreen count]; i++) {
				[[gameOverScreen objectAtIndex:i] draw];
			}
		} else if (showResults) {
			glClear(GL_DEPTH_BUFFER_BIT);//z filter
			for(int i=0; i<[resultsScreen count]; i++) {
				[[resultsScreen objectAtIndex:i] draw];
			}
		}
		glDisable(GL_BLEND);
	} else {
		//If we are not in game, deal with menus
		//In a seperate function to make this not too big
		[self handleMenus];
	}
	
#ifdef PLAYTEST_LABEL
	glEnable(GL_BLEND);
	glPushMatrix();
	glTranslatef(-camX, -camY, 0.0f);
	if (!showResults) [playtestLabel draw];
	glPopMatrix();
	glDisable(GL_BLEND);
#endif 
	//Draw black screen that deals with fading
	if (fadeTimer&&fadeTimer!=9999) {
		//determine how dark the screen is
		int fadeIntensity = 255-abs((fadeTimer-16)*15);
		
		//Decrement counter
		fadeTimer--;
		
		//Ensure darkness when transitioning to new level
		if (fadeTimer==17||fadeTimer==16) fadeIntensity=255;
		
		[self drawBlack:fadeIntensity];
		
		//Handle level incrementation 
		if (fadeTimer==16) {
			
			if (m) [m release]; 
			if (difficulty==0&&gamestate==0) {
				//On easy mode, number of balls should be set to 4
				levels.numBallsToLoad=4;
				levels.levelShouldAddBalls=0;
			}
			if ([levels levelExists]) {
				//We are loading the results level
				[[resultsScreen objectAtIndex:0] configureVisualManual:0 offsetX:0.5f offsetY:0.313f+(0.0625*difficulty) offsetX2:0.874f offsetY2:0.374f+(0.0625*difficulty)];
				//Adjust balls left text
				float visOffset = (0.0625*(levels.numBallsToLoad-1));
				[[resultsScreen objectAtIndex:1] configureVisualManual:0 offsetX:(0.375f+visOffset) offsetY:0.626 offsetX2:(0.437f+visOffset) offsetY2:0.687f];
				m = [levels loadResultsLevel];
				camX = 0;
				camY = 0;
				showResults = 1;
				//Handle unlocks for completing game
				save.unlockedFreeplayMode = 1;
				if (difficulty==1) save.lastLevel = 0;
				[save saveFile];
			} else {
				//Load the next level
				m = [levels loadCurrentLevel];
				camX = levels.levelOffsetX;
				camY = levels.levelOffsetY;
			}
			if (difficulty==0&&gamestate==0) levels.levelShouldAddBalls=1;
			showGameOver=0;
			gamestate=1;	
			menuPosition = 0;
			paused=0;
		}
	}
	
	if(initialCount) {
		//Waste time before fading to main menu
		initialCount--;
		if (initialCount>6) [self drawBlack:255];
		else [self drawBlack:(initialCount*42)];
	}
	
	glLoadIdentity();
	//Since the game is landscape, rotate the view by 90 degrees
	//THIS IS KIND OF A HACK (but it appears this is what people did back in the day?)
	//TODO: See if there is a better way of doing this. Particularly, a way to adapt to newer screen sizes
	glRotatef(-90, 0, 0, 1);
    
	//Render everything drawn
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)drawBlack:(double)alpha {
	//Draw black, given an alpha value.
	glPushMatrix();
	glEnable(GL_BLEND);
	const GLfloat squareVertices[] = {
		-95.5f, -95.5f,200.0f,
		95.5f,  -95.5f, 200.0f,
		-95.5f,  95.5f, 200.0f,
		95.5f,   95.5f, 200.0f,
	};
	const GLubyte squareColors[] = {
		0, 0,   0, alpha,
		0,   0, 0, alpha,
		0,  0,   0,   alpha,
		0,   0, 0, alpha,
	};
	
	glVertexPointer(3, GL_FLOAT, 0, squareVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
	glEnableClientState(GL_COLOR_ARRAY);
	
	glTranslatef(-camX, -camY, 0);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_BLEND);
	glPopMatrix();
}

- (void)handleMenus {
	//Deal with everything related to menus (except pause, game over, and results)
	//Init menu properties, mostly static ones as they should persist between frames
	static double fcount = 0.0;
	static int tapCountdown = 0;
	static int menuPositionSet = 0;
	static int ballToSpin = 0;
	static int unlockFreeplayModeClicks = 10;		//Easter egg to unlock freeplay mode
	fcount++;
	int bbdisabled;
	MenuButton* btn;	//Placed before the switch statement, used to set a certain menu button
	
	//Main menuing logic. Depends on the menu position and the button pressed
	switch (menuPosition) {
		case 0: //Main Menu
			//For all menus, we need to set the active buttons to the desired button list
			activeTouchButtons = mainMenuButtons;
			
			//Rotate the balls on the main menu
			for (int i=0; i<[mainMenuBalls count]; i++) {
				PhysicsObject* ball = [mainMenuBalls objectAtIndex:i];
				[ball configureVisualOffsetR:sin(fcount/25)*15];
			}
				
			//If the ball is tapped, spin it before loading next menu option
			if (tapCountdown) {
				touchedButton=0;
				PhysicsObject* ball = [mainMenuBalls objectAtIndex:ballToSpin];
				[ball configureVisualOffsetR:sin(fcount/25)*15-pow(tapCountdown-30,2)];
				tapCountdown--;
				//Set menu to cached position
				if (tapCountdown==0) menuPosition = menuPositionSet;
			} else {
				if (touchedButton) {
					switch (touchedButton) {
						case 1: //Play
							difficulty=1;
							menuPositionSet = 2;
							tapCountdown=30;
							ballToSpin = 0;
							//Always reset the easter egg if not fully done
							unlockFreeplayModeClicks = 10;
							break;
						case 2: //Free Play
							difficulty=0;
							if (save.unlockedFreeplayMode) {
								menuPositionSet = 3;
								tapCountdown=30;
								ballToSpin = 1;
								//Visually unlock all levels 
								for(int i=0; i<[levelSelectionMenuButtons count]; i++) {
									btn = [levelSelectionMenuButtons objectAtIndex:i];
									btn.locked=0;
								} 
							} else {
								//Do the easter egg tap decrement
								unlockFreeplayModeClicks--;
								if (unlockFreeplayModeClicks==0) {
									save.unlockedFreeplayMode = 1;
									[save saveFile];
									[sfx resetPitch];
									[sfx playLastSFX];
								}
							}
							break;
						case 3: //Arcade
							[[arcadeMenuButtons objectAtIndex:0] configureVisual:0 offsetX:0 offsetY:1];
							[[arcadeMenuButtons objectAtIndex:4] configureButton:0 xPosition:0 yPostition:47 buttonWidth:256 buttonHeight:0];
							difficulty=2;
							menuPositionSet = 1;
							tapCountdown=30;
							ballToSpin = 2;
							unlockFreeplayModeClicks = 10;
							break;
						case 9: //Sensitivity
							bbdisabled=1;
							if (sensitivity<1.5) {
								sensitivity = 2;
								bbdisabled = 0;
								[sfx resetPitch];
								[sfx playLastSFX];
							} else sensitivity = 1;
							[[mainMenuButtons objectAtIndex:7] configureVisual:0 offsetX:5+bbdisabled offsetY:2];
							save.sensitivity = !bbdisabled;
							[save saveFile];
							break;
						case 10: //Button Controls
							touchControls=!touchControls;
							if (touchControls) {
								tilt.updateInterval = 0;
								[sfx resetPitch];
								[sfx playLastSFX];
								[[mainMenuButtons objectAtIndex:8] configureVisual:0 offsetX:4 offsetY:1];
							} else {
								tilt.updateInterval = 1/30;
								[[mainMenuButtons objectAtIndex:8] configureVisual:0 offsetX:6 offsetY:3];
							}
							save.touchControls = touchControls;
							[save saveFile];
							break;
						case 20: //Change audio
							int soundimg = [sfx toggleAudio];
							[[mainMenuButtons objectAtIndex:9] configureVisual:0 offsetX:soundimg offsetY:0];
							[sfx menuSFX];
							save.volumeLevel = soundimg;
							[save saveFile];
					}
					touchedButton=0;
					
					camX = 0;
					camY = 0;
				}
			}
			break;
		case 1: //Arcade Difficulty
			activeTouchButtons = arcadeMenuButtons;
			if (touchedButton) {
				switch (touchedButton) {
					case 1: //Level Select
						if (difficulty==2) {
							//Toggle Normal/hard mode
							difficulty=3;
							[[arcadeMenuButtons objectAtIndex:0] configureVisual:0 offsetX:1 offsetY:1];
							[[arcadeMenuButtons objectAtIndex:4] configureButton:0 xPosition:0 yPostition:38 buttonWidth:256 buttonHeight:24];
						} else {
							difficulty=2;
							[[arcadeMenuButtons objectAtIndex:0] configureVisual:0 offsetX:0 offsetY:1];
							[[arcadeMenuButtons objectAtIndex:4] configureButton:0 xPosition:0 yPostition:47 buttonWidth:256 buttonHeight:0];
						}
						break;
					case 2: //Play
						levels.levelShouldAddBalls = (difficulty==2);
						if (difficulty==3) levels.numBallsToLoad = 4;
						else levels.numBallsToLoad = 0;
						[levels setLevelNumber:0];
						fadeTimer = 31;
						break;
					case 9999:
						menuPosition=0;
						break;
				}
				touchedButton=0;
				
				camX = 0;
				camY = 0;
			}
			break;
		case 2: //Prompt to either continue or select level in normal mode
			activeTouchButtons = continueOrLevelMenuButtons;
			if (touchedButton) {
				switch (touchedButton) {
					case 1: //level select
						menuPosition = 3;
						//Visually (un)lock all levels needed to be (un)locked
						for(int i=0; i<[levelSelectionMenuButtons count]; i++) {
							btn = [levelSelectionMenuButtons objectAtIndex:i];
							if (btn.buttonID-1>save.unlockedLevel&&btn.buttonID!=9999) btn.locked=1;
							else btn.locked=0;
						}
						break;
					case 2: //Play
						levels.levelShouldAddBalls=1;
						levels.numBallsToLoad = 0;
						[levels setLevelNumber:[LevelLoading getNearestLevelPack:save.lastLevel]];
						fadeTimer = 31;
						break;
					case 9999:
						menuPosition=0;
						break;
				}
				touchedButton=0;
				
				camX = 0;
				camY = 0;
			}
			break;
		case 3: // Level Selection
			activeTouchButtons = levelSelectionMenuButtons;
			if (touchedButton) {
				if (touchedButton==9999) {
					menuPosition=0;
				} else {
					int selectedLevel = touchedButton-1;
					//Make sure the level being tapped is unlocked, or if the game is in freeplay mode
					//Also have a safeguard (level 0 should always be unlocked)
					if (selectedLevel<=save.unlockedLevel||selectedLevel==0||difficulty!=1) {
						if (difficulty==1) {
							//If this is normal mode, the level should start right away
							levels.levelShouldAddBalls=1;
							levels.numBallsToLoad = 0;
							[levels setLevelNumber:selectedLevel];
							[levels jumpCamera:(selectedLevel%15)];
							
							fadeTimer = 31;
						} else {
							//If this is freeplay mode, the specific level is chosen
							int levelRange = nextLevelFreeplayRange-selectedLevel;
							[levels setLevelNumber:selectedLevel];
							if (freePlaySelectionMenuButtons) [freePlaySelectionMenuButtons release];
							freePlaySelectionMenuButtons = [MenuButton createFreePlayLevelSelection:levelRange];
							menuPosition = 4;
						}
					}
				}
				
				touchedButton = 0;
			}
			break;
		case 4: // Freeplay Level Selection
			activeTouchButtons = freePlaySelectionMenuButtons;
			if (touchedButton) {
				if (touchedButton==9999) {
					menuPosition = 3;
				} else {
					int selectedLevel = touchedButton-1;
					levels.currentLevel+=selectedLevel;
					[levels jumpCamera:(selectedLevel%15)];
					fadeTimer = 31;
				}
				
				touchedButton = 0;
			}
			break;
	}
	//Draw the background
	[levels drawBG];
	
	//Draw the main menu balls (don't draw the freeplay one if locked)
	if (menuPosition==0) {
		for(int i=0; i<[mainMenuBalls count]; i++) {
			if (save.unlockedFreeplayMode||i!=1) [[mainMenuBalls objectAtIndex:i] draw];
		}
	}
	
	//Set visual for if freeplay is locked
	btn = [mainMenuButtons objectAtIndex:1];
	btn.locked = !save.unlockedFreeplayMode;
	
	//Draw all the buttons
	glEnable(GL_BLEND);
	for(int i=0; i<[activeTouchButtons count]; i++) {
		[[activeTouchButtons objectAtIndex:i] draw];
	}
	glDisable(GL_BLEND);
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}

- (void)touchesBegan: (NSSet *)touches withEvent:(UIEvent *) event {
#ifdef TOUCH_TO_RELOAD_LEVEL
	//Debug to easily load levels
	gamestate=1;
	[m release];
	m = [levels loadCurrentLevel];
#endif
	//Menu logic, as well as logic for touch controls
	touchedButton = 0;
	for (int finger=0; finger<[[touches allObjects] count]; finger++) {
		CGPoint p = [[[touches allObjects] objectAtIndex:finger] locationInView:self];
		lastTouchX = p.x;
		lastTouchY = p.y;
		double x = (p.y-backingHeight/2)*1.06;
		double y = (p.x-backingWidth/2)*1.10;
		//Handle if pausing (it is not a traditional menu button)
		if (x>190&&y>120&&gamestate==1&&!showResults&&!showGameOver&&!fadeTimer) paused=!paused;
		else {
			//Set manual tilting depending on what side of the screen is touched
			if (x>0) manualTiltLeft = 1;
			else manualTiltRight = 1;
		}
		//Menu logic
		if (activeTouchButtons&&enableInput&&!fadeTimer) {
			//Find if the tap includes a menu button
			for(int i=0; i<[activeTouchButtons count]; i++) {
				MenuButton* b = [activeTouchButtons objectAtIndex:i];
				touchedButton = [b isTouchedposX:(double)x posY:(double)y];
				nextLevelFreeplayRange = b.prevLevelID;	//Janky method to deal with freeplay mode
				if (touchedButton) {
					[sfx menuSFX];
					return;	//A menu button has been found, therefore no more need to loop
				}
			}
		}
	}
}

- (void)touchesMoved: (NSSet *)touches withEvent:(UIEvent *) event {
	//Deal with if finger crosses moves 
	for (int finger=0; finger<[[touches allObjects] count]; finger++) {
		CGPoint p = [[[touches allObjects] objectAtIndex:finger] locationInView:self];
		CGPoint pp = [[[touches allObjects] objectAtIndex:finger] previousLocationInView:self];
		double x = (p.y-backingHeight/2)*1.06;
		double px = (pp.y-backingHeight/2)*1.06;
		//NSLog(@"%f %f",x, px);
		//Check if it crosses over and cancel
		if (px*x<0) {
			if (px>0) manualTiltLeft = 0;
			else manualTiltRight = 0;
		}
	}

}
- (void)touchesEnded: (NSSet *)touches withEvent:(UIEvent *) event {
	//End held button for touch controls
	for (int finger=0; finger<[[touches allObjects] count]; finger++) {
		CGPoint p = [[[touches allObjects] objectAtIndex:finger] locationInView:self];
		double x = (p.y-backingHeight/2)*1.06;
		if (x>0) manualTiltLeft = 0;
		else manualTiltRight = 0;
	}
}
- (void)touchesCanceled: (NSSet *)touches withEvent:(UIEvent *) event {
	//End held button for touch controls
	for (int finger=0; finger<[[touches allObjects] count]; finger++) {
		CGPoint p = [[[touches allObjects] objectAtIndex:finger] locationInView:self];
		double x = (p.y-backingHeight/2)*1.06;
		if (x>0) manualTiltLeft = 0;
		else manualTiltRight = 0;
	}
}


- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}


- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    self.animationTimer = nil;
}


- (void)setAnimationTimer:(NSTimer *)newTimer {
    [animationTimer invalidate];
    animationTimer = newTimer;
}


- (void)setAnimationInterval:(NSTimeInterval)interval {
    
    animationInterval = interval;
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}


- (void)dealloc {
    
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
}

@end
