// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBOverlayManager based on <https://github.com/wlach/nvpolyline>,
// but was written from scratch to be more versatile

#import "OBPolyline.h"

@implementation OBPolyline

@synthesize polylineColor;
@synthesize polylineAlpha;
@synthesize polylineWidth;
@synthesize polylineBorderColor;
@synthesize polylineBorderWidth;
@synthesize dash_lengths;
@synthesize dash_count;

- (id) init
{
	return [self initWithPoints: nil];
}

- (id) initWithPoints: (NSArray*) pts
{
	if (self = [super init])
	{
		path = NULL;
		
		self.polylineColor = [UIColor blueColor];
		self.polylineAlpha = 0.5;
		self.polylineWidth = 4.0;
		self.polylineBorderColor = [UIColor blackColor];
		self.polylineBorderWidth = 1.0;
		self.points = pts;
	}
	
	return self;
}

- (void) dealloc
{
	self.points = nil;
	self.polylineColor = nil;
	self.polylineBorderColor = nil;
	
	if (path)
		CGPathRelease(path);
	
	if (dash_lengths)
		free(dash_lengths);
	
	[super dealloc];
}

- (void) setPoints: (NSArray*) pts
{
	if (points)
	{
		[points release];
		points = nil;
		
		overlayRegion.center.latitude = 0.0;
		overlayRegion.center.longitude = 0.0;
		overlayRegion.span.latitudeDelta = 0.0;
		overlayRegion.span.longitudeDelta = 0.0;
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
	MKCoordinateRegion region;
	region.center.latitude = (maxcoord.latitude + mincoord.latitude) / 2.0;
	region.center.longitude = (maxcoord.longitude + mincoord.longitude) / 2.0;
	
	region.span.latitudeDelta = (maxcoord.latitude - mincoord.latitude) / 2.0;
	region.span.longitudeDelta = (maxcoord.longitude - mincoord.longitude) / 2.0;
	
	self.overlayRegion = region;
}

- (NSArray*) points
{
	return points;
}

- (void) setDashLengths: (CGFloat*) lengths count: (size_t) count
{
	if (dash_lengths)
	{
		free(dash_lengths);
		dash_lengths = NULL;
	}
	
	dash_count = count;
	if (count > 0)
	{
		dash_lengths = malloc(sizeof(CGFloat) * count);
		memcpy(dash_lengths, lengths, sizeof(CGFloat) * count);
	}
}

- (void) setNeedsDisplay
{
	// zoom level changed, old path cache is now invalid
	
	if (path)
	{
		CGPathRelease(path);
		path = NULL;
	}
	
	if (self.map && points && points.count > 0)
	{
		// regenerate path
		
		path = CGPathCreateMutable();
		BOOL first = YES;
		
		for (CLLocation* loc in points)
		{
			CGPoint pt = [self.map convertCoordinate: loc.coordinate toPointToView: self];
			
			if (first)
			{
				CGPathMoveToPoint(path, NULL, pt.x, pt.y);
				first = NO;
			} else {
				CGPathAddLineToPoint(path, NULL, pt.x, pt.y);
			}
		}
	}
	
	// chain up
	[super setNeedsDisplay];
}

- (void) drawOverlayRect: (CGRect) rect inContext: (CGContextRef) context
{
	if (!path)
		return;
	
	if (polylineAlpha < 1.0)
		CGContextSetAlpha(context, polylineAlpha);
	CGContextBeginTransparencyLayer(context, NULL);
	
	CGContextSetStrokeColorWithColor(context, polylineBorderColor.CGColor);
	CGContextSetLineWidth(context, polylineWidth + polylineBorderWidth);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	
	CGContextSetStrokeColorWithColor(context, polylineColor.CGColor);
	CGContextSetLineWidth(context, polylineWidth);
	if (dash_lengths)
	{
		CGFloat* dash_lengths_scaled = malloc(sizeof(CGFloat) * dash_count);
		for (size_t i = 0; i < dash_count; i++)
		{
			dash_lengths_scaled[i] = dash_lengths[i] * polylineWidth;
		}
		CGContextSetLineDash(context, 0, dash_lengths_scaled, dash_count);
		free(dash_lengths_scaled);
	}
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	
	CGContextEndTransparencyLayer(context);
}

@end
