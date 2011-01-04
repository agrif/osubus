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
// how long between calls to centerOffset before reset
#define OB_TOUCH_TIMEOUT 0.1
// how many calls there can be before we consider ourselves "zooming"
#define OB_MIN_TOUCHES 1

@implementation OBOverlayManager

@synthesize overlays;

- (id) initWithMapView: (MKMapView*) mapView
{
	if (self = [super initWithAnnotation: self reuseIdentifier: @"OBOverlayManager"])
	{
		map = mapView;
		overlays = [[NSMutableArray alloc] init];
		
		//self.backgroundColor = [UIColor colorWithRed: 1.0 green: 0.0 blue: 0.0 alpha: 0.2];
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = NO;
		self.frame = CGRectMake(0.0, 0.0, map.frame.size.width, map.frame.size.height);
		
		touchTimer = nil;
		zooming = NO;
		centerOffsetCount = 0;
		
		[map addAnnotation: self];
	}
	
	return self;
}

- (void) dealloc
{
	for (OBOverlay* overlay in overlays)
	{
		[overlay removeFromSuperview];
		[overlay setMap: nil];
	}
	[overlays release];
	[map removeAnnotation: self];
	
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

- (void) touchTimeout
{
	// invalidate our timer
	[touchTimer invalidate];
	touchTimer = nil;
	
	// reset count
	centerOffsetCount = 0;
	
	// check if we've been zooming
	if (zooming)
	{
		zooming = NO;
		
		for (OBOverlay* overlay in overlays)
		{
			[self updateOverlayFrame: overlay toView: self];
			[overlay stoppedZooming];
		}
	}
}

// we hook this to get position updates during zoom
- (CGPoint) centerOffset
{
	// first, make sure our annotation is the back-most annotation
	[self.superview sendSubviewToBack: self];
	
	// make sure we're covering the full map
	self.frame = CGRectMake(0.0, 0.0, map.frame.size.width, map.frame.size.height);
	
	// now, update call count and reset timer
	centerOffsetCount++;
	if (touchTimer)
		[touchTimer invalidate];
	touchTimer = [NSTimer scheduledTimerWithTimeInterval: OB_TOUCH_TIMEOUT target: self selector: @selector(touchTimeout) userInfo: nil repeats: NO];
	
	if (!zooming && centerOffsetCount > OB_MIN_TOUCHES)
	{
		zooming = YES;
		[overlays makeObjectsPerformSelector: @selector(startedZooming)];
	}
	
	for (OBOverlay* overlay in overlays)
	{
		[self updateOverlayFrame: overlay toView: map];
	}
	
	// don't forget to actually implement this function :P
	return [super centerOffset];
}

- (void) addOverlay: (OBOverlay*) overlay
{
	if ([overlays containsObject: overlay])
		return;
	
	// set the overlay map
	[overlay setMap: map];
	
	// add it
	[overlays addObject: overlay];
	[self addSubview: overlay];
	
	// simulate a zoom, stop zoom sequence
	[overlay startedZooming];
	[self updateOverlayFrame: overlay toView: self];
	[overlay stoppedZooming];
	
	// force our annotation to back
	[self.superview sendSubviewToBack: self];
}

- (void) removeOverlay: (OBOverlay*) overlay
{
	if (![overlays containsObject: overlay])
		return;
	
	[overlays removeObject: overlay];
	[overlay removeFromSuperview];
	[overlay setMap: nil];
}

@end
