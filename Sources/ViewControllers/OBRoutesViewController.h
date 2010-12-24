// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

#import "OBTableViewController.h"

@interface OBRoutesViewController : OBTableViewController
{
	NSArray* routes;
}

@property (nonatomic, readonly) NSArray* routes;

- (IBAction) dismissModal;

@end
