// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBOverlayManager based on <https://github.com/wlach/nvpolyline>,
// but was written from scratch to be more versatile

#import "OBOverlayManager.h"

// this gives the views an extra bit of space to work in
#define OB_OVERLAY_MARGIN 4

@implementation OBOverlayManager

@synthesize overlays;

- (id) initWithMapView: (MKMapView*) mapView
{
	if (self = [super initWithAnnotation: self reuseIdentifier: @"OBOverlayManager"])
	{
		map = mapView;
		overlays = [[NSMutableArray alloc] init];
		
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = NO;
		self.frame = CGRectMake(0.0, 0.0, map.frame.size.width, map.frame.size.height);
	}
	
	return self;
}

- (void) dealloc
{
	[overlays release];
	
	[super dealloc];
}

- (CLLocationCoordinate2D) coordinate
{
	return map.centerCoordinate;
}

// send view to back on touch, prevents annonotation wierdness
- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
{
	[self.superview sendSubviewToBack: self];
	[super touchesBegan: touches withEvent: event];
}

- (void) updateOverlayFrame: (UIView<OBOverlay>*) overlay
{
	MKCoordinateRegion region = [overlay overlayRegion];
	
	// check for empty region
	if (region.span.latitudeDelta == 0.0 || region.span.longitudeDelta == 0.0)
		return;
	
	CLLocationCoordinate2D mincoord;
	mincoord.latitude = region.center.latitude + region.span.latitudeDelta;
	mincoord.longitude = region.center.longitude - region.span.longitudeDelta;
	CLLocationCoordinate2D maxcoord;
	maxcoord.latitude = region.center.latitude - region.span.latitudeDelta;
	maxcoord.longitude = region.center.longitude + region.span.longitudeDelta;
	
	CGPoint minpt = [map convertCoordinate: mincoord toPointToView: map];
	CGPoint maxpt = [map convertCoordinate: maxcoord toPointToView: map];
	
	overlay.frame = CGRectMake(minpt.x - OB_OVERLAY_MARGIN,
								minpt.y - OB_OVERLAY_MARGIN,
								maxpt.x - minpt.x + 2*OB_OVERLAY_MARGIN,
								maxpt.y - minpt.y + 2*OB_OVERLAY_MARGIN);
}

- (void) redrawOverlays;
{
	for (UIView<OBOverlay>* overlay in overlays)
	{
		[overlay setNeedsDisplay];
	}
} 

- (CGPoint) centerOffset
{
	// first, make sure our annotation is the back-most annotation
	[self.superview sendSubviewToBack: self];
	
	// we hook this to get position updates during zoom
	for (UIView<OBOverlay>* overlay in overlays)
	{
		[self updateOverlayFrame: overlay];

		// redraw SHOULD be handled by view's content mode
		//[overlay setNeedsDisplay];
	}
	
	// don't forget to actually implement this function :P
	return [super centerOffset];
}

- (void) addOverlay: (UIView<OBOverlay>*) overlay
{
	if ([overlays containsObject: overlay])
		return;
	
	// set the overlay map
	[overlay setMap: map];
	
	// rejigger overlay frame
	[self updateOverlayFrame: overlay];
	
	[overlays addObject: overlay];
	[self addSubview: overlay];	
	
	// force redraw
	[overlay setNeedsDisplay];
	
	// force our annotation to back
	[self.superview sendSubviewToBack: self];
}

- (void) removeOverlay: (UIView<OBOverlay>*) overlay
{
	if (![overlays containsObject: overlay])
		return;
	
	[overlays removeObject: overlay];
	[overlay removeFromSuperview];
}

@end