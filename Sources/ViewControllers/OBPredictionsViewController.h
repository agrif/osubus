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
	OBPA_MAP,
	OBPA_COUNT
};

@interface OBPredictionsViewController : OBTableViewController <OTRequestDelegate, UIActionSheetDelegate>
{
	NSDictionary* stop;
	NSNumber* vehicle;
	NSString* vehicle_route;
	NSArray* predictions;
	NSArray* routes;
	NSString* error_cell_text;
	UIBarButtonItem* addButton;
	NSTimer* refreshTimer;
	
	BOOL showMapAction;
	BOOL isFavorite;
}

- (void) setStop: (NSDictionary*) stopin;
- (void) setVehicle: (NSNumber*) vehiclein onRoute: (NSString*) route;
- (void) updateTimes: (NSTimer*) timer;
- (void) toggleFavorite: (UIBarButtonItem*) button;
- (void) actionSheet: (UIActionSheet*) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex;

@end
