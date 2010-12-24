// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "OBRoutesViewController.h"

@class OBOverlayManager;

@interface OBMapViewController : UIViewController <MKMapViewDelegate, OBRoutesViewDelegate>
{
	MKMapView* map;
	UIBarButtonItem* routesButton;
	OBOverlayManager* overlays;
	
	NSMutableDictionary* routes;
}

@property (nonatomic, retain) IBOutlet MKMapView* map;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* routesButton;

- (IBAction) routesButtonPressed;

@end
