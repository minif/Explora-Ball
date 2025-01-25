//
//  ballbounceAppDelegate.h
//  ballbounce
//
//  Created by macpro on 7/15/24.
//  Copyright __MyCompanyName__ 2024. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface ballbounceAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end

