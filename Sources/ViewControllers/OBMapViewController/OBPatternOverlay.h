// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <MapKit/MapKit.h>
#import "OBPolylineView.h"

@interface OBPatternOverlay : OBPolylineView <MKOverlay, MKAnnotation>

- (id) initWithPattern: (NSDictionary*) pattern;

@end
