// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBMapViewController.h"

#import "OTClient.h"
#import "NSString+HexColor.h"
#import "OBStopAnnotation.h"
#import "OBOverlayManager.h"
#import "OBPolyline.h"

@implementation OBMapViewController

@synthesize map, instructiveView, routesButton;

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.navigationItem setTitle: @"Bus Map"];
	[self.navigationItem setRightBarButtonItem: routesButton];
	
	// magick numbers -- approximate center of the oval
	CLLocationCoordinate2D center;
	center.latitude = 39.999417;
	center.longitude = -83.012639;
	map.region = MKCoordinateRegionMake(center,
										MKCoordinateSpanMake(0.01, 0.01));
	
	// SETUP for map zoom hack
	/*hasZoomedIn = NO;
	finalRegion = map.region;
	MKCoordinateRegion outerRegion = finalRegion;
	outerRegion.span.latitudeDelta *= 1.2;
	outerRegion.span.longitudeDelta *= 1.2;
	map.region = outerRegion;*/
	
	// setup overlay manager
	overlayManager = [[OBOverlayManager alloc] initWithMapView: map];
	[map addAnnotation: overlayManager];
	
	// just a rough estimate of the number of routes to be displayed
	stopAnnotations = [[NSMutableDictionary alloc] initWithCapacity: 5];
	routeOverlays = [[NSMutableDictionary alloc] initWithCapacity: 5];
	activeRequests = [[NSMutableDictionary alloc] initWithCapacity: 5];
		
	NSLog(@"OBMapViewController loaded");
}

- (void) viewDidUnload
{
	NSDictionary* route = nil;
	while (route = [[stopAnnotations allKeys] objectAtIndex: 0])
	{
		[self setRoute: route enabled: NO];
	}
	
	[stopAnnotations release];
	[routeOverlays release];
	[activeRequests release];

	[map removeAnnotation: overlayManager];
	[overlayManager release];
	
	NSLog(@"OBMapViewController unloaded");
    [super viewDidUnload];
}

- (void) viewDidAppear: (BOOL) animated
{
	// this block is a HACK that prevents a draw bug on iOS3.1
	// but it doesn't look *too* bad... I guess
	/*if (hasZoomedIn)
		return;
	[map setRegion: finalRegion animated: animated];
	hasZoomedIn = YES;*/
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
	return [stopAnnotations objectForKey: route] != nil;
}

- (void) setRoute: (NSDictionary*) route enabled: (BOOL) enabled
{
	if (enabled)
	{
		// add in stops, start route request
		
		NSArray* stops = [[OTClient sharedClient] stopsWithRoute: [route objectForKey: @"id"]];
		NSMutableArray* annotations = [[NSMutableArray alloc] initWithCapacity: stops.count];
		
		for (NSDictionary* stop in stops)
		{
			OBStopAnnotation* annotation = [[OBStopAnnotation alloc] initWithMapViewController: self route: route stop: stop];
			[annotations addObject: annotation];
			[map addAnnotation: annotation];
			[annotation release];
		}
		
		[stops release];
		[stopAnnotations setObject: annotations forKey: route];
		[annotations release];
		
		// we don't need the instructive view any more
		[instructiveView setHidden: YES];
	} else {
		// remove stops, overlays, request
		
		for (OBStopAnnotation* annotation in [stopAnnotations objectForKey: route])
		{
			[map removeAnnotation: annotation];
		}
		[stopAnnotations removeObjectForKey: route];
		
		for (OBOverlay* overlay in [routeOverlays objectForKey: route])
		{
			[overlayManager removeOverlay: overlay];
		}
		[routeOverlays removeObjectForKey: route];
		
		for (OTRequest* req in [activeRequests allKeysForObject: route])
		{
			[activeRequests removeObjectForKey: req];
		}
	}
}

#pragma mark OTRequestDelegate

- (void) request: (OTRequest*) request hasResult: (NSDictionary*) result
{
	[request release];
}

- (void) request: (OTRequest*) request hasError:(NSError *)error
{
	// ignore, except for a log message
	// the worst that happens is there will be no route overlay
	NSLog(@"error while requesting pattern: %@", error);
	
	[request release];
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView*) mapView: (MKMapView*) mapView viewForAnnotation: (id <MKAnnotation>) annotation
{
	if (annotation == overlayManager)
		return [overlayManager autorelease];
	
	if ([annotation isKindOfClass: [OBStopAnnotation class]])
		return [(OBStopAnnotation*)annotation annotationViewForMap: map];
	
	return nil;
}

@end
