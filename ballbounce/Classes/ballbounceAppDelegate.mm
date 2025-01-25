//
//  ballbounceAppDelegate.m
//  ballbounce
//
//  Created by macpro on 7/15/24.
//  Copyright __MyCompanyName__ 2024. All rights reserved.
//

#import "ballbounceAppDelegate.h"
#import "EAGLView.h"

@implementation ballbounceAppDelegate

@synthesize window;
@synthesize glView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[application setStatusBarOrientation: UIInterfaceOrientationLandscapeRight];
    [application setIdleTimerDisabled:true];
	glView.animationInterval = 1.0 / 60.0;
	glView.multipleTouchEnabled = YES;
	[glView startAnimation];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 5.0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 60.0;
}


- (void)dealloc {
	[window release];
	[glView release];
	[super dealloc];
}

@end
