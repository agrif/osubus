// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBPolylineManager based on <https://github.com/wlach/nvpolyline>,
// with small differences

#include <Foundation/Foundation.h>
#include <MapKit/MapKit.h>

@interface OBPolylineManager : NSObject
{
	MKMapView* map;
}

- (id) initWithMapView: (MKMapView*) mapView;

- (MKAnnotationView*) mapView: (MKMapView*) mapView viewForAnnotation: (id <MKAnnotation>) annotation;

@end
