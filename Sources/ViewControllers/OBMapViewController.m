// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBMapViewController.h"

#import "OBOverlayManager.h"
#import "OBPolyline.h"

@implementation OBMapViewController

@synthesize map;

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.navigationItem setTitle: @"Map"];
	
	// magick numbers -- approximate center of the oval
	map.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(39.999417, -83.012639),
										MKCoordinateSpanMake(0.01, 0.01));
	map.mapType = MKMapTypeStandard;
	
	overlays = [[OBOverlayManager alloc] initWithMapView: map];
	[map addAnnotation: overlays];
	
	OBPolyline* route = [[OBPolyline alloc] initWithMapView: map];
	
	/*route.points = [NSArray arrayWithObjects:
					[[[CLLocation alloc] initWithLatitude: 0.0 longitude: 0.0] autorelease],
					[[[CLLocation alloc] initWithLatitude: 70.0 longitude: 70.0] autorelease],
					nil];*/
	
	[overlays addOverlay: route];
	[route release];
	
	NSLog(@"OBMapViewController loaded");
}

- (void) viewDidUnload
{
	[overlays release];
	
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

#pragma mark MKMapViewDelegate

- (MKAnnotationView*) mapView: (MKMapView*) mapView viewForAnnotation: (id <MKAnnotation>) annotation
{
	if (annotation == overlays)
		return overlays;
	
	return nil;
}

@end
