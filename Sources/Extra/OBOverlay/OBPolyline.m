// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBOverlayManager based on <https://github.com/wlach/nvpolyline>,
// but was written from scratch to be more versatile

#import "OBPolyline.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation OBPolyline

@synthesize overlayRegion;
@synthesize polylineColor;
@synthesize polylineAlpha;

- (id) initWithMapView: (MKMapView*) mapView
{
	if (self = [super init])
	{
		map = mapView;
		self.polylineColor = [UIColor blueColor];
		self.polylineAlpha = 0.5;
	}
	
	return self;
}

- (id) initWithMapView: (MKMapView*) mapView points: (NSArray*) pts
{
	if (self = [self initWithMapView: mapView])
	{
		self.points = pts;
	}
	
	return self;
}

- (void) dealloc
{
	self.points = nil;
	self.polylineColor = nil;
	
	[super dealloc];
}

- (void) setPoints: (NSArray*) pts
{
	if (points)
	{
		[points release];
		points = nil;
		overlayRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(0.0, 0.0),
											   MKCoordinateSpanMake(0.0, 0.0));
	}
	
	if (!pts || pts.count == 0)
		return;
	
	points = [pts retain];
	
	// now we can dynamically generate overlayRegion
	
	CLLocation* first = [points objectAtIndex: 0];
	CLLocationCoordinate2D mincoord, maxcoord;
	mincoord = maxcoord = first.coordinate;
	
	for (CLLocation* loc in points)
	{
		CLLocationCoordinate2D coord = loc.coordinate;
		
		if (coord.latitude > maxcoord.latitude)
			maxcoord.latitude = coord.latitude;
		if (coord.latitude < mincoord.latitude)
			mincoord.latitude = coord.latitude;
		
		if (coord.longitude > maxcoord.longitude)
			maxcoord.longitude = coord.longitude;
		if (coord.longitude < mincoord.longitude)
			mincoord.longitude = coord.longitude;
	}
	
	// and now we can set it
	overlayRegion.center.latitude = (maxcoord.latitude + mincoord.latitude) / 2.0;
	overlayRegion.center.longitude = (maxcoord.longitude + mincoord.longitude) / 2.0;
	
	overlayRegion.span.latitudeDelta = (maxcoord.latitude - mincoord.latitude) / 2.0;
	overlayRegion.span.longitudeDelta = (maxcoord.longitude - mincoord.longitude) / 2.0;
}

- (NSArray*) points
{
	return points;
}

- (void) drawRect: (CGRect) rect
{
	if (!points || points.count == 0)
		return;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, polylineColor.CGColor);
	CGContextSetAlpha(context, polylineAlpha);
	CGContextSetLineWidth(context, 4.0);
	
	BOOL first = YES;
	
	for (CLLocation* loc in points)
	{
		CGPoint pt = [map convertCoordinate: loc.coordinate toPointToView: self];
		
		if (first)
		{
			CGContextMoveToPoint(context, pt.x, pt.y);
			first = NO;
		} else {
			CGContextAddLineToPoint(context, pt.x, pt.y);
		}
	}
	
	CGContextStrokePath(context);
}

@end