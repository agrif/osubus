// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

#import "OTClient.h"

@class OBTopViewController;

@interface OBBulletinsViewController : UITableViewController <OTRequestDelegate>
{
	OBTopViewController* topViewController;
	BOOL requestedCustom;
	NSMutableArray* bulletins;
	NSInteger endOfOfficialBulletins;
	NSString* updateURL;
}

@property (nonatomic, retain) NSMutableArray* bulletins;
@property (nonatomic, copy) NSString* updateURL;

- (void) loadBulletins: (OBTopViewController*) caller;

@end
