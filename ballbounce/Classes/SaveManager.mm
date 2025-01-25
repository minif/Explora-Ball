//
//  SaveManager.m
//  ballbounce
//
//  Created by macpro on 1/10/25.
//  Copyright 2025 __MyCompanyName__. All rights reserved.
//

#import "SaveManager.h"
#include <fstream>
#include <iostream>
using namespace std;

#ifdef TOUCHHLE_WORKAROUND
#include <stdio.h>

double convertNumberToDouble (NSNumber* num);

#endif

@implementation SaveManager
@synthesize unlockedLevel;
@synthesize lastLevel;
@synthesize volumeLevel;
@synthesize touchControls;
@synthesize sensitivity;
@synthesize unlockedFreeplayMode;

//Save file loading and saving

- (id)init{
	//Set up save file aspects tracked
	lastLevel = 0;
	volumeLevel = 2;
	touchControls = 0;
	sensitivity = 0;
	unlockedLevel = 0;
	unlockedFreeplayMode = 0;
	
	//Find save file
	NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	saveFileLocation = [documentsPath stringByAppendingPathComponent:@"save.txt"];
	[saveFileLocation retain];
	//Load save file
	[self loadFile];
	[self saveFile];
	return self;
}


- (void) loadFile {
	//touchHLE 0.2.2 doesn't support writing to plists to we gotta do good ol fashioned fstream
	ifstream in;
	char nCString[256];
	[saveFileLocation getCString:nCString maxLength:256 encoding:NSUTF8StringEncoding];
	in.open(nCString);
	if (!in.is_open()) NSLog(@"Unable to open save file");
	else {
		in >> lastLevel;
		in >> volumeLevel;
		in >> touchControls;
		in >> sensitivity;
		in >> unlockedLevel;
		in >> unlockedFreeplayMode;
	}
	in.close();
}

- (void) saveFile {
	ofstream out;
	char nCString[256];
	[saveFileLocation getCString:nCString maxLength:256 encoding:NSUTF8StringEncoding];
	out.open(nCString);
	out << lastLevel << "\n";
	out << volumeLevel << "\n";
	out << touchControls << "\n";
	out << sensitivity << "\n";
	out << unlockedLevel << "\n";
	out << unlockedFreeplayMode << "\n";
	out << 0 << "\n"; //Placeholder in case I want to change
	out << 0 << "\n";
	out << 0 << "\n";
}



- (void) loadFilePlist {
	//Unused, kept just in case 
	NSDictionary* levelListDict = [[NSDictionary alloc]initWithContentsOfFile:saveFileLocation];
	if (levelListDict) {
#ifdef TOUCHHLE_WORKAROUND
		lastLevel = convertNumberToDouble([levelListDict objectForKey:@"lastLevel"]);
		volumeLevel= convertNumberToDouble([levelListDict objectForKey:@"volumeLevel"]);
		touchControls= convertNumberToDouble([levelListDict objectForKey:@"touchControls"]);
		sensitivity= convertNumberToDouble([levelListDict objectForKey:@"sensitivity"]);
		unlockedLevel= convertNumberToDouble([levelListDict objectForKey:@"unlockedLevel"]);
		unlockedFreeplayMode= convertNumberToDouble([levelListDict objectForKey:@"unlockedFreeplayMode"]);
#else
		lastLevel = [[levelListDict objectForKey:@"lastLevel"] doubleValue];
		volumeLevel = [[levelListDict objectForKey:@"volumeLevel"] doubleValue];
		touchControls = [[levelListDict objectForKey:@"touchControls"] doubleValue];
		sensitivity = [[levelListDict objectForKey:@"sensitivity"] doubleValue];
		unlockedLevel = [[levelListDict objectForKey:@"unlockedLevel"] doubleValue];
		unlockedFreeplayMode = [[levelListDict objectForKey:@"unlockedFreeplayMode"] doubleValue];
#endif
	//NSLog(@"Successfully loaded! unlockedLevel = %i",volumeLevel);
	} 
	
	[levelListDict release];
}


- (void) saveFilePlist {
	//NSLog(@"Saving...");
	NSDictionary* saveDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:(double)lastLevel],@"lastLevel",
							  [NSNumber numberWithDouble:(double)volumeLevel],@"volumeLevel",
							  [NSNumber numberWithDouble:(double)touchControls],@"touchControls",
							  [NSNumber numberWithDouble:(double)sensitivity],@"sensitivity",
							  [NSNumber numberWithDouble:(double)unlockedLevel],@"unlockedLevel",
							  [NSNumber numberWithDouble:(double)unlockedFreeplayMode],@"unlockedFreeplayMode",
							  nil];
	[saveDict writeToFile:saveFileLocation atomically:YES];
	//NSLog(@"Saved");
	//[saveDict release];
	
}


@end