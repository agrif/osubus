// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBPatternOverlay.h"

@implementation OBPatternOverlay

- (id) initWithPattern: (NSDictionary*) pattern
{
	NSUInteger count = [[pattern objectForKey: @"pt"] count];
	CLLocationCoordinate2D* points = malloc(sizeof(CLLocationCoordinate2D) * count);
	
	NSUInteger i = 0;
	for (NSDictionary* point in [pattern objectForKey: @"pt"])
	{
		points[i].latitude = [[point objectForKey: @"lat"] floatValue];
		points[i].longitude = [[point objectForKey: @"lon"] floatValue];
		i++;
	}
	
	MKPolyline* polyline = [MKPolyline polylineWithCoordinates: points count: count];
	free(points);
	
	return [super initWithPolyline: polyline];
}

- (MKMapRect) boundingMapRect
{
	return self.overlay.boundingMapRect;
}

- (CLLocationCoordinate2D) coordinate
{
	return self.overlay.coordinate;
}

- (BOOL) canReplaceMapContent
{
	return NO;
}

@end
