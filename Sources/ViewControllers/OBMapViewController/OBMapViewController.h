// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "OTClient.h"
#import "OBRoutesViewController.h"

@class OBStopAnnotation;
@class OBVehicleAnnotation;

@protocol OBMapViewAnnotation

- (MKAnnotationView*) annotationViewForMap: (MKMapView*) mapView;
- (NSObject*) visibilityKey;

@end

@interface OBMapViewController : UIViewController <MKMapViewDelegate, OBRoutesViewDelegate, OTRequestDelegate, CLLocationManagerDelegate>
{
	MKMapView* map;
	UIView* instructiveView;
	UIBarButtonItem* routesButton;
	UIBarButtonItem* locateButton;
	UIBarButtonItem* flexibleSpace;
	UIBarButtonItem* actionButton;
	
	// maps route -> stop annotations array
	NSMutableDictionary* stopAnnotations;
	// maps route -> overlay array
	NSMutableDictionary* routeOverlays;
	// maps active requests -> route
	NSMutableDictionary* activeRequests;
	
	OBStopAnnotation* primaryStopAnnotation;
	OBVehicleAnnotation* primaryVehicleAnnotation;
	NSString* primaryVehicleId;
	NSDictionary* primaryVehicleRoute;
	
	// vehicle update timer
	NSTimer* refreshTimer;
}

@property (nonatomic, retain) IBOutlet MKMapView* map;
@property (nonatomic, retain) IBOutlet UIView* instructiveView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem* routesButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* locateButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* flexibleSpace;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* actionButton;

- (IBAction) routesButtonPressed;
- (IBAction) locateButtonPressed;
- (IBAction) actionButtonPressed;

// call this to get rid of all visible annotations, overlays, etc.
- (void) clearMap;
- (void) setRoute: (NSDictionary*) route enabled: (BOOL) enabled;
- (void) setStop: (NSDictionary*) stop;
- (void) setVehicle: (NSString*) vid onRoute: (NSDictionary*) route;

- (void) updateVehicles: (NSTimer*) timer;

@end
