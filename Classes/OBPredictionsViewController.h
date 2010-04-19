// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

#import "OTRequest.h"

#import "OBTableViewController.h"

enum OBPredictionsSections
{
	OBPS_PREDICTIONS,
	OBPS_ACTIONS,
	OBPS_COUNT
};

enum OBPredictionsActions
{
	OBPA_DIRECTIONS,
	OBPA_COUNT
};

@interface OBPredictionsViewController : OBTableViewController <OTRequestDelegate, UIActionSheetDelegate>
{
	NSDictionary* stop;
	NSArray* predictions;
	NSArray* routes;
	NSString* error_cell_text;
	UIBarButtonItem* addButton;
}

- (void) setStop: (NSDictionary*) stopin;
- (void) updateTimes: (NSTimer*) timer;
- (void) addFavorite: (id) button;
- (void) actionSheet: (UIActionSheet*) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex;

@end
