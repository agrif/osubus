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

static MKCoordinateRegion saved_region;
static NSMutableDictionary* saved_routes;
static BOOL use_saved_info = NO;

@implementation OBMapViewController

@synthesize map, instructiveView, routesButton;

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.navigationItem setTitle: @"Bus Map"];
	[self.navigationItem setRightBarButtonItem: routesButton];
	
	if (!use_saved_info)
	{
		// magick numbers -- approximate center of the oval
		CLLocationCoordinate2D center;
		center.latitude = 39.999417;
		center.longitude = -83.012639;
		map.region = MKCoordinateRegionMake(center,
											MKCoordinateSpanMake(0.01, 0.01));
	} else {
		map.region = saved_region;
	}
	
	map.mapType = MKMapTypeStandard;
	
	// setup overlay manager
	overlays = [[OBOverlayManager alloc] initWithMapView: map];
	[map addAnnotation: overlays];
		
	if (use_saved_info && saved_routes)
	{
		routes = saved_routes;
		saved_routes = nil;
		
		// now we must go through and add in all the annotations, overlays
		for (NSDictionary* data in [routes allValues])
		{
			for (OBStopAnnotation* annotation in [data objectForKey: @"annotations"])
			{
				[map addAnnotation: annotation];
			}
			
			for (UIView<OBOverlay>* overlay in [data objectForKey: @"overlays"])
			{
				[overlays addOverlay: overlay];
			}
		}
		
		if (routes.count > 0)
		{
			// we don't need the instructive view anymore, there's stuff on-screen
			[instructiveView setHidden: YES];
		}
	} else {
		// magick numbers -- approximately maximum number of routes, but not exactly
		// just a rough estimate
		routes = [[NSMutableDictionary alloc] initWithCapacity: 10];
	}
	
	requestMap = [[NSMutableDictionary alloc] initWithCapacity: 10];
	outstandingRequests = 0;
	
	NSLog(@"OBMapViewController loaded");
}

- (void) viewDidUnload
{
	saved_region = map.region;
	saved_routes = [routes retain];
	use_saved_info = YES;
	
	// bit of a hack -- shrink the saved region a bit so that the
	// nearest fit on old OS's is NOT double the original (as it sometimes is)
	// (weird bug)
	saved_region.span.latitudeDelta *= 0.99;
	saved_region.span.longitudeDelta *= 0.99;
	
	[overlays release];
	[routes release];
	[requestMap release];
	
	// reset the network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	
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
		
		// create the inner dictionary
		NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
		[data setObject: annotations forKey: @"annotations"];
		[annotations release];
		
		[routes setObject: data forKey: route];
		[data release];
		
		// start the request for route patterns
		OTRequest* req = [[OTClient sharedClient] requestPatternsWithDelegate: self forRoute: [route objectForKey: @"short"]];
		[requestMap setObject: route forKey: req];
		[req release];
		
		// hide instructive view, there's stuff on-screen now
		[instructiveView setHidden: YES];
		
		outstandingRequests++;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
	} else {
		// remove the route!
		// but first, remove the annotations
		
		for (OBStopAnnotation* annotation in [[routes objectForKey: route] objectForKey: @"annotations"])
		{
			[map removeAnnotation: annotation];
		}
		
		for (UIView<OBOverlay>* overlay in [[routes objectForKey: route] objectForKey: @"overlays"])
		{
			[overlays removeOverlay: overlay];
		}
		
		[routes removeObjectForKey: route];
	}
}

#pragma mark OTRequestDelegate

- (void) request: (OTRequest*) request hasResult: (NSDictionary*) result
{
	// array to store new overlays as they're made
	NSMutableArray* req_overlays = [[NSMutableArray alloc] initWithCapacity: [[result objectForKey: @"ptr"] count]];
	
	for (NSDictionary* pattern in [result objectForKey: @"ptr"])
	{
		// temporary array for points
		NSMutableArray* points = [[NSMutableArray alloc] initWithCapacity: [[pattern objectForKey: @"pt"] count]];
		
		for (NSDictionary* point in [pattern objectForKey: @"pt"])
		{
			CLLocation* loc = [[CLLocation alloc] initWithLatitude: [[point objectForKey: @"lat"] floatValue] longitude: [[point objectForKey: @"lon"] floatValue]];
			[points addObject: loc];
			[loc release];
		}
		
		// create the overlay
		OBPolyline* polyline = [[OBPolyline alloc] initWithPoints: points];
		[points release];
		
		// setup the route color
		polyline.polylineColor = [[[requestMap objectForKey: request] objectForKey: @"color"] colorFromHex];
		polyline.polylineAlpha = 0.8;
		polyline.polylineWidth = 6.0;
		
		// add overlay to our array, and the overlaymanager
		[req_overlays addObject: polyline];
		[overlays addOverlay: polyline];
		[polyline release];
	}
	
	// add overlays to data dict
	[[routes objectForKey: [requestMap objectForKey: request]] setObject: req_overlays forKey: @"overlays"];
	[req_overlays release];
	
	// free request
	[requestMap removeObjectForKey: request];
	
	outstandingRequests--;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: outstandingRequests > 0];
}

- (void) request: (OTRequest*) request hasError:(NSError *)error
{
	// ignore, except for a log message
	// the worst that happens is there will be no route overlay
	NSLog(@"error while requesting pattern: %@", error);
	
	// add empty overlays array
	NSArray* empty = [[NSArray alloc] init];
	[[routes objectForKey: [requestMap objectForKey: request]] setObject: empty forKey: @"overlays"];
	[empty release];
	
	// free request
	[requestMap removeObjectForKey: request];
	
	outstandingRequests--;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: outstandingRequests > 0];
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
