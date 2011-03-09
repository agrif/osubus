// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

#import "OTRequest.h"

#import "OBTableViewController.h"

@interface OBVehicleViewController : OBTableViewController <OTRequestDelegate>
{
	NSNumber* vehicle;
	NSTimer* refreshTimer;
	
	NSString* error_cell_text;
	NSDictionary* predictions;
}

- (void) setVehicle: (NSNumber*) vehicle;
- (void) updateTimes: (NSTimer*) timer;

@end
