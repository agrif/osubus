// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBOverlayManager based on <https://github.com/wlach/nvpolyline>,
// but was written from scratch to be more versatile

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface OBOverlay : UIView
{
	MKMapView* map;
	MKCoordinateRegion overlayRegion;
	
	// set to YES during zooming, so tilelayer doesn't freak out
	BOOL drawEnabled;
}

@property (nonatomic, assign) MKMapView* map;
@property (nonatomic, assign) MKCoordinateRegion overlayRegion;

- (id) init;

// must be implemented in subclass - this is where to draw!
- (void) drawOverlayRect: (CGRect) rect inContext: (CGContextRef) context;

@end
