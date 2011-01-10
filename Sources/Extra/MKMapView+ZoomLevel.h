// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <MapKit/MapKit.h>

// interface for Google Maps API - like zoom levels
// based on http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/
// with extra code for reading back zoom levels

@interface MKMapView (ZoomLevel)

// zoom-level getting is *very* approximate
@property (nonatomic, assign) NSUInteger zoomLevel;
- (void) setZoomLevel: (NSUInteger) zoomLevel animated: (BOOL) animated;
- (void) setCenterCoordinate: (CLLocationCoordinate2D) centerCoordinate zoomLevel: (NSUInteger) zoomLevel animated: (BOOL) animated;

@end