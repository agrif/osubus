// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

#import "OBTableViewController.h"

// delegate for modal-view mode
@protocol OBRoutesViewDelegate
- (BOOL) isRouteEnabled: (NSDictionary*) route;
- (void) setRoute: (NSDictionary*) route enabled: (BOOL) enabled;
@end

@interface OBRoutesViewController : OBTableViewController
{
	NSArray* routes;
	id<OBRoutesViewDelegate> routesDelegate;
}

@property (nonatomic, readonly) NSArray* routes;
@property (nonatomic, retain) id<OBRoutesViewDelegate> routesDelegate;

- (void) presentModallyOn: (UIViewController*) controller withDelegate: (id<OBRoutesViewDelegate>) delegate;

@end
