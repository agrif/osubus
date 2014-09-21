// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBPolylineView.h"

@implementation OBPolylineView

@synthesize polyline;
@synthesize polylineColor;
@synthesize polylineAlpha;
@synthesize polylineWidth;
@synthesize polylineBorderColor;
@synthesize polylineBorderWidth;

- (id) initWithPolyline: (MKPolyline*) pl
{
	self = [super initWithOverlay: pl];
	if (self)
	{
		self.polyline = pl;
		
		self.polylineColor = [UIColor blueColor];
		self.polylineAlpha = 0.5;
		self.polylineWidth = 4.0;
		self.polylineBorderColor = [UIColor blackColor];
		self.polylineBorderWidth = 1.0;
	}
	return self;
}

- (void) dealloc
{
	self.polyline = nil;
	self.polylineColor = nil;
	self.polylineBorderColor = nil;
	[super dealloc];
}

- (void) drawMapRect: (MKMapRect) mapRect zoomScale: (MKZoomScale) zoomScale inContext: (CGContextRef) context
{
	[super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
	
	CGFloat width1 = (self.polylineWidth + self.polylineBorderWidth) / zoomScale;
	CGFloat width2 = self.polylineWidth / zoomScale;
	
	// slight hack to approximate old stroke sizes
	width1 *= 2;
	width2 *= 2;
	
	CGMutablePathRef path = [self createPath];
	if (polylineAlpha < 1.0)
		CGContextSetAlpha(context, polylineAlpha);
	CGContextBeginTransparencyLayer(context, NULL);
	
	// draw the dark colour thicker
	CGContextAddPath(context, path);
	CGContextSetStrokeColorWithColor(context, self.polylineBorderColor.CGColor);
	CGContextSetLineWidth(context, width1);
	CGContextStrokePath(context);
	
	// now draw the stroke color with the regular width
	CGContextAddPath(context, path);
	CGContextSetStrokeColorWithColor(context, self.polylineColor.CGColor);
	CGContextSetLineWidth(context, width2);
	CGContextStrokePath(context);
	
	CGContextEndTransparencyLayer(context);
	CGPathRelease(path);
}

- (CGMutablePathRef) createPath
{
	CGMutablePathRef mpath = CGPathCreateMutable();
	for (int i = 0; self.polyline && i < self.polyline.pointCount; i++)
	{
		CGPoint point = [self pointForMapPoint:self.polyline.points[i]];
		if (i == 0)
		{
			CGPathMoveToPoint(mpath, nil, point.x, point.y);
		} else {
			CGPathAddLineToPoint(mpath, nil, point.x, point.y);
		}
	}
	
	return mpath;
}

@end
