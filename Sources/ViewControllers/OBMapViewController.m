// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBMapViewController.h"
#import "OBPolylineManager.h"

@implementation OBMapViewController

@synthesize map;

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.navigationItem setTitle: @"Map"];
	
	polylines = [[OBPolylineManager alloc] initWithMapView: map];
	[map addAnnotation: polylines];
	
	OBPolyline* route = [[OBPolyline alloc] initWithMapView: map];
	
	route.points = [NSArray arrayWithObjects:
					[[[CLLocation alloc] initWithLatitude: 0.0 longitude: 0.0] autorelease],
					[[[CLLocation alloc] initWithLatitude: 70.0 longitude: 70.0] autorelease],
					nil];
	
	[polylines addOverlay: route];
	[route release];
	
	NSLog(@"OBMapViewController loaded");
}

- (void) viewDidUnload
{
	[polylines release];
	
	NSLog(@"OBMapViewController unloaded");
    [super viewDidUnload];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView*) mapView: (MKMapView*) mapView viewForAnnotation: (id <MKAnnotation>) annotation
{
	if (annotation == polylines)
		return polylines;
	
	return nil;
}

@end
