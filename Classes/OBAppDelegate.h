// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

@interface OBAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow* window;
	UINavigationController* navigation;
}

@property (nonatomic, retain) IBOutlet UIWindow* window;
@property (nonatomic, retain) IBOutlet UINavigationController* navigation;

@end

