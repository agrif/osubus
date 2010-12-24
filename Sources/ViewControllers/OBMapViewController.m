// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBMapViewController.h"

#import "OBOverlayManager.h"
#import "OBPolyline.h"

@implementation OBMapViewController

@synthesize map, routesButton;

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.navigationItem setTitle: @"Map"];
	[self.navigationItem setRightBarButtonItem: routesButton];
	
	// magick numbers -- approximate center of the oval
	map.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(39.999417, -83.012639),
										MKCoordinateSpanMake(0.01, 0.01));
	map.mapType = MKMapTypeStandard;
	
	// setup overlay manager
	overlays = [[OBOverlayManager alloc] initWithMapView: map];
	[map addAnnotation: overlays];
	
	/*OBPolyline* route = [[OBPolyline alloc] initWithMapView: map];
	
	route.points = [NSArray arrayWithObjects:
					[[[CLLocation alloc] initWithLatitude: 0.0 longitude: 0.0] autorelease],
					[[[CLLocation alloc] initWithLatitude: 70.0 longitude: 70.0] autorelease],
					nil];
	
	[overlays addOverlay: route];
	[route release];*/
	
	// FIXME magick number -- approximately maximum number of routes, but not exactly
	// just a rough estimate
	routes = [[NSMutableDictionary alloc] initWithCapacity: 10];
	
	NSLog(@"OBMapViewController loaded");
}

- (void) viewDidUnload
{
	[overlays release];
	[routes release];
	
	NSLog(@"OBMapViewController unloaded");
    [super viewDidUnload];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
	return YES;
}

#pragma mark routes selector stuff

- (IBAction) routesButtonPressed
{
	OBRoutesViewController* routesController = [[OBRoutesViewController alloc] initWithNibName: @"OBRoutesViewControllerModal" bundle: nil];
	routesController.routesDelegate = self;
	[self.navigationController presentModalViewController: routesController animated: YES];
	[routesController release];
}

- (BOOL) isRouteEnabled: (NSString*) route
{
	return [routes objectForKey: route] != nil;
}

- (void) setRoute: (NSString*) route enabled: (BOOL) enabled
{
	if (enabled)
	{
		// add in the route
		// for now, use a dummy object
		NSArray* data = [[NSArray alloc] init];
		[routes setObject: data forKey: route];
		[data release];
	} else {
		// remove the route!
		// for now, remove dummy object
		[routes removeObjectForKey: route];
	}
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView*) mapView: (MKMapView*) mapView viewForAnnotation: (id <MKAnnotation>) annotation
{
	if (annotation == overlays)
		return overlays;
	
	return nil;
}

@end
