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
	MKAnnotationView* ret = [polylines mapView: mapView viewForAnnotation: annotation];
	if (ret)
		return ret;
	
	return nil;
}

@end
