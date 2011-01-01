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
		
		redrawOverlays = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	[overlays release];
	[redrawOverlays release];
	
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

- (CGRect) convertMapRegionToRect: (MKCoordinateRegion) region toView: (UIView*) toView;
{
	CLLocationCoordinate2D mincoord;
	mincoord.latitude = region.center.latitude + region.span.latitudeDelta;
	mincoord.longitude = region.center.longitude - region.span.longitudeDelta;
	CLLocationCoordinate2D maxcoord;
	maxcoord.latitude = region.center.latitude - region.span.latitudeDelta;
	maxcoord.longitude = region.center.longitude + region.span.longitudeDelta;
	
	CGPoint minpt = [map convertCoordinate: mincoord toPointToView: toView];
	CGPoint maxpt = [map convertCoordinate: maxcoord toPointToView: toView];
	
	return CGRectMake(minpt.x - OB_OVERLAY_MARGIN,
					  minpt.y - OB_OVERLAY_MARGIN,
					  maxpt.x - minpt.x + 2*OB_OVERLAY_MARGIN,
					  maxpt.y - minpt.y + 2*OB_OVERLAY_MARGIN);
}

// returns YES if frame size changed
- (BOOL) updateOverlayFrame: (OBOverlay*) overlay toView: (UIView*) toView
{
	MKCoordinateRegion region = overlay.overlayRegion;
	
	// check for empty region
	if (region.span.latitudeDelta == 0.0 || region.span.longitudeDelta == 0.0)
		return NO;
	
	CGRect newframe = [self convertMapRegionToRect: region toView: toView];
	BOOL ret = !CGSizeEqualToSize(overlay.frame.size, newframe.size);
	overlay.frame = newframe;
	
	return ret;
}

- (void) redrawOverlays;
{
	for (OBOverlay* overlay in overlays)
	{
		// only redraw if we're registered to redraw
		if ([redrawOverlays containsObject: overlay])
		{
			[overlay setNeedsDisplay];
			[redrawOverlays removeObject: overlay];
		}
	}
} 

- (CGPoint) centerOffset
{
	// first, make sure our annotation is the back-most annotation
	[self.superview sendSubviewToBack: self];
	
	// we hook this to get position updates during zoom
	for (OBOverlay* overlay in overlays)
	{
		[self updateOverlayFrame: overlay toView: map];
		
		// register this overlay for forced redraw when map touches end
		if (![redrawOverlays containsObject: overlay])
			[redrawOverlays addObject: overlay];
	}
	
	// don't forget to actually implement this function :P
	return [super centerOffset];
}

- (void) addOverlay: (OBOverlay*) overlay
{
	if ([overlays containsObject: overlay])
		return;
	
	// DEBUG overlay background
	//overlay.backgroundColor = [UIColor colorWithRed: 1.0 green: 0.0 blue: 0.0 alpha: 0.2];
	
	// set the overlay map
	[overlay setMap: map];
	
	// rejigger overlay frame
	[self updateOverlayFrame: overlay toView: self];
	
	[overlays addObject: overlay];
	[self addSubview: overlay];
	
	// force redraw
	[overlay setNeedsDisplay];
	
	// force our annotation to back
	[self.superview sendSubviewToBack: self];
}

- (void) removeOverlay: (OBOverlay*) overlay
{
	if (![overlays containsObject: overlay])
		return;
	
	[overlays removeObject: overlay];
	[overlay removeFromSuperview];
}

@end
