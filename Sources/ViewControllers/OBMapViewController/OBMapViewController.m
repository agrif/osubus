// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBMapViewController.h"

#import "OTClient.h"
#import "OBStopAnnotation.h"
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

- (BOOL) isRouteEnabled: (NSDictionary*) route
{
	return [routes objectForKey: route] != nil;
}

- (void) setRoute: (NSDictionary*) route enabled: (BOOL) enabled
{
	if (enabled)
	{
		// add in the route
		// create an array of stop annotations
		
		NSMutableArray* annotations = [[NSMutableArray alloc] init];
		
		NSArray* stops = [[OTClient sharedClient] stopsWithRoute: [route objectForKey: @"id"]];
		for (NSDictionary* stop in stops)
		{
			OBStopAnnotation* annotation = [[OBStopAnnotation alloc] initWithRoute: route stop: stop];
			[annotations addObject: annotation];
			[map addAnnotation: annotation];
			[annotation release];
		}
		[stops release];
		
		[routes setObject: annotations forKey: route];
		[annotations release];
	} else {
		// remove the route!
		// but first, remove the annotations
		
		for (OBStopAnnotation* annotation in [routes objectForKey: route])
		{
			[map removeAnnotation: annotation];
		}
		
		[routes removeObjectForKey: route];
	}
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView*) mapView: (MKMapView*) mapView viewForAnnotation: (id <MKAnnotation>) annotation
{
	if (annotation == overlays)
		return overlays;
	
	if ([annotation isKindOfClass: [OBStopAnnotation class]])
		return [(OBStopAnnotation*)annotation annotationViewForMap: map];
	
	return nil;
}

@end
