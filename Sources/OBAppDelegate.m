// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBAppDelegate.h"

@implementation OBAppDelegate

@synthesize window;
@synthesize navigation;

- (void) applicationDidFinishLaunching: (UIApplication*) application
{
    [window addSubview: [navigation view]];
    [window makeKeyAndVisible];
}

- (void) dealloc
{
    [window release];
    [super dealloc];
}

@end
