//
//  TouchArea.h
//  ballbounce
//
//  Created by macpro on 7/20/24.
//  Copyright 2024 __MyCompanyName__. All rights reserved.
//

#import "PhysicsManager.h"
#import "PhysicsObject.h"


@interface PhysicsTouchArea : PhysicsObject {

}

- (int)objectsTouching:(PhysicsManager*)m;

@end
