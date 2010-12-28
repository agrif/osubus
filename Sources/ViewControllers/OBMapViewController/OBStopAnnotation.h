// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <MapKit/MapKit.h>

#import "OBPinView.h"

@class OBMapViewController;

@interface OBStopAnnotation : OBPinView <MKAnnotation>
{
	OBMapViewController* map;
	NSDictionary* route;
	NSDictionary* stop;
}

- (id) initWithMapViewController: (OBMapViewController*) _map route: (NSDictionary*) _route stop: (NSDictionary*) _stop;
- (MKAnnotationView*) annotationViewForMap: (MKMapView*) mapView;

@end