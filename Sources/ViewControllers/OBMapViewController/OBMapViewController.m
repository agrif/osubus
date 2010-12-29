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

static MKCoordinateRegion saved_region;
static BOOL use_saved_region = NO;

@implementation OBMapViewController

@synthesize map;

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.navigationItem setTitle: @"Bus Map"];
	
	if (!use_saved_region)
	{
		// magick numbers -- approximate center of the oval
		CLLocationCoordinate2D center;
		center.latitude = 39.999417;
		center.longitude = -83.012639;
		saved_region = MKCoordinateRegionMake(center,
											  MKCoordinateSpanMake(0.01, 0.01));
		use_saved_region = YES;
	}
	
	map.region = saved_region;
	map.mapType = MKMapTypeStandard;
	
	// setup overlay manager
	overlays = [[OBOverlayManager alloc] initWithMapView: map];
	[map addAnnotation: overlays];
	
	// temporary test route
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
	saved_region = map.region;
	use_saved_region = YES;
	
	// bit of a hack -- shrink the saved region a bit so that the
	// nearest fit on old OS's is NOT double the original (as it sometimes is)
	// (weird bug)
	saved_region.span.latitudeDelta *= 0.99;
	saved_region.span.longitudeDelta *= 0.99;
	
	[overlays release];
	[routes release];
	
	NSLog(@"OBMapViewController unloaded");
    [super viewDidUnload];
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
			OBStopAnnotation* annotation = [[OBStopAnnotation alloc] initWithMapViewController: self route: route stop: stop];
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
