// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

#import "OBTableViewController.h"

@interface OBStopsViewController : OBTableViewController
{
	NSArray* stops;
	NSDictionary* route;
}

- (void) setRoute: (NSDictionary*) routein;

@end
