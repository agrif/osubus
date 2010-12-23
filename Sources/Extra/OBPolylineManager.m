// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBPolylineManager based on <https://github.com/wlach/nvpolyline>,
// with small differences

#import "OBPolylineManager.h"

@implementation OBPolylineManager

- (id) initWithMapView: (MKMapView*) mapView
{
	if ([super init])
	{
		map = mapView;
		[map retain];
		
		return self;
	}
	
	return nil;
}

- (void) dealloc
{
	[map release];
	
	[super dealloc];
}

- (MKAnnotationView*) mapView: (MKMapView*) mapView viewForAnnotation: (id <MKAnnotation>) annotation
{
	return nil;
}

@end
