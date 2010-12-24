// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class OBOverlayManager;

@interface OBMapViewController : UIViewController <MKMapViewDelegate>
{
	MKMapView* map;
	UIBarButtonItem* routesButton;
	OBOverlayManager* overlays;
}

@property (nonatomic, retain) IBOutlet MKMapView* map;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* routesButton;

- (IBAction) routesButtonPressed;

@end
