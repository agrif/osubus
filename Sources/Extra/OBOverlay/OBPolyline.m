// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBOverlayManager based on <https://github.com/wlach/nvpolyline>,
// but was written from scratch to be more versatile

#import "OBPolyline.h"
#import <QuartzCore/CoreAnimation.h>

@implementation OBPolyline

@synthesize map;
@synthesize overlayRegion;
@synthesize polylineColor;
@synthesize polylineAlpha;
@synthesize polylineWidth;
@synthesize polylineBorderColor;
@synthesize polylineBorderWidth;

- (id) init
{
	return [self initWithPoints: nil];
}

- (id) initWithPoints: (NSArray*) pts
{
	if (self = [super init])
	{
		// generic setup for all overlays
		self.backgroundColor = [UIColor clearColor];
		
		zooming = NO;
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
	self.map = nil;
	
	if (path)
		CGPathRelease(path);
	
	[super dealloc];
}

// use CATiledLayer as our layer class
+ (Class) layerClass
{
	return [CATiledLayer class];
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

- (void) setNeedsDisplay
{
	// let our draw function do its business
	zooming = NO;
	
	// clear the tiled layer cache (makes sure ALL tiles are drawn)
	self.layer.contents = nil;
	
	// regenerate path if needed
	if (!path)
	{
		path = CGPathCreateMutable();
		BOOL first = YES;
		
		for (CLLocation* loc in points)
		{
			CGPoint pt = [map convertCoordinate: loc.coordinate toPointToView: self];
			
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

- (void) setFrame: (CGRect) frame
{
	// turn of drawing, for the time being...
	zooming = YES;
	
	// our path has become invalid
	if (path)
	{
		CGPathRelease(path);
		path = NULL;
	}
	
	// chain up
	[super setFrame: frame];
}

- (void) drawLayer: (CALayer*) layer inContext: (CGContextRef) context
{
	if (zooming || !path || !map || !points || points.count == 0)
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
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	
	CGContextEndTransparencyLayer(context);
}

@end
