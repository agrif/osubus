// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBOverlayManager based on <https://github.com/wlach/nvpolyline>,
// but was written from scratch to be more versatile

#import "OBOverlayManager.h"

// this gives the views an extra bit of space to work in
#define OB_OVERLAY_MARGIN 16

@implementation OBOverlayManager

@synthesize overlays;

- (id) initWithMapView: (MKMapView*) mapView
{
	if (self = [super init])
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

- (CGPoint) centerOffset
{
	for (UIView<OBOverlay>* overlay in overlays)
	{
		// first we need to set up the view frame
		MKCoordinateRegion region = [overlay overlayRegion];
		
		// check for empty region
		if (region.span.latitudeDelta == 0.0 || region.span.longitudeDelta == 0)
			continue;
		
		CLLocationCoordinate2D mincoord = CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta,
																	 region.center.longitude - region.span.longitudeDelta);
		CLLocationCoordinate2D maxcoord = CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta,
																	 region.center.longitude + region.span.longitudeDelta);
		
		CGPoint minpt = [map convertCoordinate: mincoord toPointToView: self];
		CGPoint maxpt = [map convertCoordinate: maxcoord toPointToView: self];
		
		overlay.frame = CGRectMake(minpt.x - OB_OVERLAY_MARGIN,
								   minpt.y - OB_OVERLAY_MARGIN,
								   maxpt.x - minpt.x + 2*OB_OVERLAY_MARGIN,
								   maxpt.y - minpt.y + 2*OB_OVERLAY_MARGIN);
		
		// now we redraw
		[overlay setNeedsDisplay];
	}
	
	// don't forget to actually implement this function :P
	return [super centerOffset];
}

- (void) addOverlay: (UIView<OBOverlay>*) overlay
{
	if ([overlays containsObject: overlay])
		return;
	
	overlay.backgroundColor = [UIColor clearColor];
	overlay.clipsToBounds = NO;
	
	[overlays addObject: overlay];
	[self addSubview: overlay];
}

- (void) removeOverlay: (UIView<OBOverlay>*) overlay
{
	if (![overlays containsObject: overlay])
		return;
	
	[overlays removeObject: overlay];
	[overlay removeFromSuperview];
}

@end
