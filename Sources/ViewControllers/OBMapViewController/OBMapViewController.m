// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBMapViewController.h"

#import "OTClient.h"
#import "NSString+HexColor.h"
#import "MKMapView+ZoomLevel.h"
#import "UIApplication+NiceNetworkIndicator.h"
#import "OBStopAnnotation.h"
#import "OBVehicleAnnotation.h"
#import "OBPatternOverlay.h"

@implementation OBMapViewController

@synthesize map, instructiveView;
@synthesize routesButton, locateButton, flexibleSpace, actionButton;

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.navigationItem setTitle: @"Bus Map"];
	[self.navigationItem setRightBarButtonItem: routesButton];
	
	// magick numbers -- approximate center of the oval
	CLLocationCoordinate2D center;
	center.latitude = 39.999417;
	center.longitude = -83.012639;
	map.region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.01, 0.01));
	
	// just a rough estimate of the number of routes to be displayed
	stopAnnotations = [[NSMutableDictionary alloc] initWithCapacity: 5];
	routeOverlays = [[NSMutableDictionary alloc] initWithCapacity: 5];
	activeRequests = [[NSMutableDictionary alloc] initWithCapacity: 5];
	
	// setup toolbar
	locateButton.image = [UIImage imageNamed: @"locate"];
	self.toolbarItems = [NSArray arrayWithObjects: locateButton, flexibleSpace, actionButton, nil];
		
	NSLog(@"OBMapViewController loaded");
}

- (void) viewDidUnload
{
	[self clearMap];
	[stopAnnotations release];
	[routeOverlays release];
	[activeRequests release];
	
	// primary{Stop,Vehicle}Annotation and primaryVehicle* is taken care of in clearMap
	
	self.toolbarItems = nil;
	
	NSLog(@"OBMapViewController unloaded");
    [super viewDidUnload];
}

- (void) viewDidAppear: (BOOL) animated
{
	// Start the vehicle update timer
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval: OSU_BUS_REFRESH_TIME target: self selector: @selector(updateVehicles:) userInfo: nil repeats: YES];
}

- (void) viewDidDisappear: (BOOL) animated
{
	if (refreshTimer)
	{
		[refreshTimer invalidate];
		refreshTimer = nil;
	}
}

- (void) viewWillAppear: (BOOL) animated
{
	if (self.navigationController.topViewController == self)
		[self.navigationController setToolbarHidden: NO animated: animated];
}

- (void) viewWillDisappear: (BOOL) animated
{
	if (self.navigationController.topViewController != self)
		[self.navigationController setToolbarHidden: YES animated: animated];
}

- (void) clearMap
{
	[self setStop: nil];
	[self setVehicle: nil onRoute: nil];
	while ([[stopAnnotations allKeys] count])
	{
		NSDictionary* route = [[stopAnnotations allKeys] objectAtIndex: 0];
		[self setRoute: route enabled: NO];
	}
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
	return YES;
}

// helper to reconfigure the visible annotations
// to prevent doubles
- (void) reconfigureVisibleAnnotations
{
	NSMutableArray* visibleAnnotations = [[NSMutableArray alloc] init];
	
	if (primaryStopAnnotation)
	{
		[visibleAnnotations addObject: [primaryStopAnnotation visibilityKey]];
	}
	
	if (primaryVehicleAnnotation)
	{
		[visibleAnnotations addObject: [primaryVehicleAnnotation visibilityKey]];
	}
	
	for (NSArray* annotations in [stopAnnotations allValues])
	{
		for (MKAnnotationView<OBMapViewAnnotation>* annotation in annotations)
		{
			if ([visibleAnnotations containsObject: [annotation visibilityKey]])
			{
				[annotation setHidden: YES];
				[annotation setEnabled: NO];
			} else {
				[annotation setHidden: NO];
				[annotation setEnabled: YES];
				[visibleAnnotations addObject: [annotation visibilityKey]];
			}
		}
	}
	
	[visibleAnnotations release];
}

#pragma mark IBActions

- (IBAction) locateButtonPressed
{
	if ([CLLocationManager respondsToSelector: @selector(authorizationStatus)] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
	{
		CLLocationManager* manager = [[CLLocationManager alloc] init];
		if ([manager respondsToSelector: @selector(requestWhenInUseAuthorization)])
		{
			[manager requestWhenInUseAuthorization];
			[manager setDelegate: self];
			return;
		} else {
			[manager release];
		}
	}
	map.showsUserLocation = !map.showsUserLocation;
	
	if (map.showsUserLocation)
	{
		locateButton.image = [UIImage imageNamed: @"locate-active"];
	} else {
		locateButton.image = [UIImage imageNamed: @"locate"];
	}
}

- (void) locationManager: (CLLocationManager*) manager didChangeAuthorizationStatus: (CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusNotDetermined)
		return;
	
	[manager autorelease];
	[self locateButtonPressed];
}

- (void) openMapAppAtStop: (NSDictionary*) stop
{
	// first, url-escape the name so we can have it show up on the map
	NSString* encodedName = [[stop objectForKey: @"name"] stringByReplacingOccurrencesOfString: @"(" withString: @"["];
	encodedName = [encodedName stringByReplacingOccurrencesOfString: @")" withString: @"]"];
	encodedName = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)encodedName, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
	
	NSString* url = [[NSString alloc] initWithFormat: @"http://maps.google.com/maps?ll=%f,%f&q=%@,%@+(%@)&t=m&z=%lu", map.centerCoordinate.latitude, map.centerCoordinate.longitude, [stop objectForKey: @"lat"], [stop objectForKey: @"lon"], encodedName, (unsigned long)(map.zoomLevel)];
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
	
	[url release];
	[encodedName release];
}

- (IBAction) actionButtonPressed
{
	if (map.selectedAnnotations.count > 0 && [[map.selectedAnnotations objectAtIndex: 0] isKindOfClass: [OBStopAnnotation class]])
	{
		OBStopAnnotation* annotation = (OBStopAnnotation*)[map.selectedAnnotations objectAtIndex: 0];
		[self openMapAppAtStop: annotation.stop];
	} else if (primaryStopAnnotation) {
		[self openMapAppAtStop: primaryStopAnnotation.stop];
	} else {
		// fall back to just opening the map with the pin in the center
		NSString* url = [[NSString alloc] initWithFormat: @"http://maps.google.com/maps?ll=%f,%f&t=m&z=%lu", map.region.center.latitude, map.region.center.longitude, (unsigned long)(map.zoomLevel)];
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
		[url release];
	}
}

#pragma mark routes selector stuff

- (IBAction) routesButtonPressed
{
	OBRoutesViewController* routesController = [[OBRoutesViewController alloc] initWithNibName: @"OBRoutesViewController" bundle: nil];
	[routesController presentModallyOn: self.navigationController withDelegate:self];
	[routesController release];
}

- (BOOL) isRouteEnabled: (NSDictionary*) route
{
	if (stopAnnotations == nil)
		[self view];
	
	return [stopAnnotations objectForKey: route] != nil;
}

- (void) setRoute: (NSDictionary*) route enabled: (BOOL) enabled
{
	if (stopAnnotations == nil)
		[self view];
	
	if (enabled == [self isRouteEnabled: route])
		return;
	
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
		
		// start the request
		OTRequest* req = [[OTClient sharedClient] requestPatternsWithDelegate: self forRoute: [route objectForKey: @"short"]];
		[activeRequests setObject: route forKey: req];
		[[UIApplication sharedApplication] setNetworkInUse: YES byObject: req];
		
		// update vehicles
		[self updateVehicles: nil];
		
		// we don't need the instructive view any more
		[instructiveView setHidden: YES];
	} else {
		// remove stops, overlays, request
		for (OBStopAnnotation* annotation in [stopAnnotations objectForKey: route])
		{
			[map removeAnnotation: annotation];
		}
		
		// finally, release our array of annotations
		[stopAnnotations removeObjectForKey: route];
		
		[map removeOverlays: [routeOverlays objectForKey: route]];
		[routeOverlays removeObjectForKey: route];
		
		for (OTRequest* req in [activeRequests allKeysForObject: route])
		{
			[activeRequests removeObjectForKey: req];
		}
	}
	
	[self reconfigureVisibleAnnotations];
}

#pragma mark view stop/vehicle on map stuff

- (void) setStop: (NSDictionary*) stop
{
	// we must be loaded!
	if (stopAnnotations == nil)
		[self view];
	
	if (stop)
	{
		// setup
		[self setStop: nil];
		
		primaryStopAnnotation = [[OBStopAnnotation alloc] initWithMapViewController: self route: nil stop: stop];
		[map addAnnotation: primaryStopAnnotation];
		
		// figure out if we should be animated
		BOOL animated = self.navigationController.visibleViewController == self;
		
		// set map region to be centered on new stop, and select it
		[map setCenterCoordinate: primaryStopAnnotation.coordinate animated: animated];
		[map selectAnnotation: primaryStopAnnotation animated: animated];
		
		// activate the connected routes
		for (NSDictionary* route in [stop objectForKey: @"routes"])
		{
			[self setRoute: route enabled: YES];
		}
		
		// we no longer need the instructive view
		[instructiveView setHidden: YES];
	} else {
		// remove stop annotation from map
		if (!primaryStopAnnotation)
			return;
		
		[map removeAnnotation: primaryStopAnnotation];
		[primaryStopAnnotation release];
		primaryStopAnnotation = nil;
	}
	
	[self reconfigureVisibleAnnotations];
}

- (void) setVehicle: (NSString*) vid onRoute: (NSDictionary*) route
{
	// we must be loaded!
	if (stopAnnotations == nil)
		[self view];
	
	if (vid)
	{
		// setup
		[self setVehicle: nil onRoute: nil];
		primaryVehicleId = [vid retain];
		primaryVehicleRoute = [route retain];
		
		// enable the route
		[self setRoute: route enabled: YES];
		
		// update vehicles, which fetches and creates our marker
		[self updateVehicles: nil];
		
		// we no longer need the instructive view
		[instructiveView setHidden: YES];
	} else {
		// remove vehicle annotation from map
		if (primaryVehicleAnnotation)
		{
			[map removeAnnotation: primaryVehicleAnnotation];
			[primaryVehicleAnnotation release];
			primaryVehicleAnnotation = nil;
		}
		
		if (primaryVehicleId)
		{
			[primaryVehicleId release];
			primaryVehicleId = nil;
		}
		
		if (primaryVehicleRoute)
		{
			[primaryVehicleRoute release];
			primaryVehicleRoute = nil;
		}
	}
}

#pragma mark vehicle update stuff

- (void) updateVehicles: (NSTimer*) timer
{
	NSLog(@"updating vehicles");
	
	if (primaryVehicleId)
	{
		// start the request for our main guy
		OTRequest* req = [[OTClient sharedClient] requestVehiclesWithDelegate: self withVehicleIDs: primaryVehicleId];
		[[UIApplication sharedApplication] setNetworkInUse: YES byObject: req];
	}
	
	for (NSDictionary* route in stopAnnotations)
	{
		// start the request
		OTRequest* req = [[OTClient sharedClient] requestVehiclesWithDelegate: self forRoutes: [route objectForKey: @"short"]];
		[activeRequests setObject: route forKey: req];
		[[UIApplication sharedApplication] setNetworkInUse: YES byObject: req];
	}
}

#pragma mark OTRequestDelegate

- (void) request: (OTRequest*) request hasResult: (NSDictionary*) result
{
	NSDictionary* route = [activeRequests objectForKey: request];
	NSArray* patterns = [result objectForKey: @"ptr"];
	NSArray* vehicles = [result objectForKey: @"vehicle"];
	
	if (route && patterns)
	{
		// getting patterns for a selected route
		
		NSMutableArray* overlays = [[NSMutableArray alloc] initWithCapacity: [patterns count]];
		
		for (NSDictionary* pattern in patterns)
		{
			OBPatternOverlay* polyline = [[OBPatternOverlay alloc] initWithPattern: pattern];
			
			polyline.polylineColor = [[route objectForKey: @"color"] colorFromHex];
			polyline.polylineAlpha = 1.0;
			
			[overlays addObject: polyline];
			[map addOverlay: polyline];
			[polyline release];
		}
		
		[routeOverlays setObject: overlays forKey: route];
		[overlays release];
	} else if (route && vehicles) {
		// getting vehicles for a selected route
		
		NSMutableArray* annotations = [stopAnnotations objectForKey: route];
		NSMutableArray* annotations_filtered = [[NSMutableArray alloc] initWithCapacity: [annotations count]];
		
		for (NSObject<MKAnnotation>* object in annotations)
		{
			if ([object isKindOfClass: [OBVehicleAnnotation class]])
			{
				[map removeAnnotation: object];
			} else {
				[annotations_filtered addObject: object];
			}
		}
		
		annotations = annotations_filtered;
		[stopAnnotations setObject: annotations_filtered forKey: route];
		[annotations release];
		
		// add new vehicles
		for (NSDictionary* vehicle in vehicles)
		{
			OBVehicleAnnotation* annotation = [[OBVehicleAnnotation alloc] initWithMapViewController: self route: route vehicle: vehicle primary: NO];
			[annotations addObject: annotation];
			[map addAnnotation: annotation];
			[annotation release];
		}
	} else if (route == nil && vehicles) {
		// getting primary vehicle info
		
		BOOL zoomInOnAnnotation = NO;
		if (primaryVehicleAnnotation)
		{
			[map removeAnnotation: primaryVehicleAnnotation];
			[primaryVehicleAnnotation release];
			primaryVehicleAnnotation = nil;
		} else {
			// this is the first version of the annotation, so center on it
			zoomInOnAnnotation = YES;
		}
		
		NSDictionary* vehicle = [vehicles objectAtIndex: 0];
		primaryVehicleAnnotation = [[OBVehicleAnnotation alloc] initWithMapViewController: self route: primaryVehicleRoute vehicle: vehicle primary: YES];
		[map addAnnotation: primaryVehicleAnnotation];
		
		if (zoomInOnAnnotation)
		{
			// set map region to be centered on new stop, and select it
			[map setCenterCoordinate: primaryVehicleAnnotation.coordinate animated: YES];
			[map selectAnnotation: primaryVehicleAnnotation animated: YES];
		}
	}
	
	if (route)
		[activeRequests removeObjectForKey: request];
	[[UIApplication sharedApplication] setNetworkInUse: NO byObject: request];
	[self reconfigureVisibleAnnotations];
	[request release];
}

- (void) request: (OTRequest*) request hasError:(NSError *)error
{
	// ignore, except for a log message
	// the worst that happens is there will be no route overlay
	NSLog(@"error while requesting map data: %@", error);
	
	[activeRequests removeObjectForKey: request];
	[[UIApplication sharedApplication] setNetworkInUse: NO byObject: request];
	[request release];
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView*) mapView: (MKMapView*) mapView viewForAnnotation: (id <MKAnnotation>) annotation
{
	if ([annotation conformsToProtocol: @protocol(OBMapViewAnnotation)])
		return [(id<OBMapViewAnnotation>)annotation annotationViewForMap: map];
	
	return nil;
}

- (MKOverlayView*) mapView: (MKMapView*) mapView viewForOverlay: (id <MKOverlay>) overlay
{
	return (OBPatternOverlay*)overlay;
}

@end
