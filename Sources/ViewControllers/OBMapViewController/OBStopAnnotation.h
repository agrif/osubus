// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <MapKit/MapKit.h>

@interface OBStopAnnotation : MKAnnotationView <MKAnnotation>
{
	NSDictionary* route;
	NSDictionary* stop;
}

- (id) initWithRoute: (NSDictionary*) _route stop: (NSDictionary*) _stop;
- (MKAnnotationView*) annotationViewForMap: (MKMapView*) map;

@end
