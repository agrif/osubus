// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <MapKit/MapKit.h>

#import "OBMapViewController.h"
#import "OBPinView.h"

@interface OBStopAnnotation : OBPinView <MKAnnotation, OBMapViewAnnotation>
{
	OBMapViewController* map;
	NSDictionary* route;
	NSDictionary* stop;
}

@property (nonatomic, readonly) NSDictionary* stop;

- (id) initWithMapViewController: (OBMapViewController*) _map route: (NSDictionary*) _route stop: (NSDictionary*) _stop;

@end
