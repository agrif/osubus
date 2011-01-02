// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "OTClient.h"
#import "OBRoutesViewController.h"

@class OBOverlayManager;

@interface OBMapViewController : UIViewController <MKMapViewDelegate, OBRoutesViewDelegate, OTRequestDelegate>
{
	MKMapView* map;
	UIView* instructiveView;
	UIBarButtonItem* routesButton;
	OBOverlayManager* overlays;
	
	// maps routes -> {@"annotations" : [...], @"overlays" : [...]}
	NSMutableDictionary* routes;
	// maps active requests -> routes
	NSMutableDictionary* requestMap;
	
	// counts how many requests have yet to return
	NSInteger outstandingRequests;
	
	// for initial zoom in hack
	BOOL hasZoomedIn;
	MKCoordinateRegion finalRegion;
}

@property (nonatomic, retain) IBOutlet MKMapView* map;
@property (nonatomic, retain) IBOutlet UIView* instructiveView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* routesButton;

- (IBAction) routesButtonPressed;

@end
