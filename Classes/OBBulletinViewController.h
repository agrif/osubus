// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

@interface OBBulletinViewController : UIViewController
{
	NSDictionary* bulletin;
}

- (void) setBulletin: (NSDictionary*) data;

@end
