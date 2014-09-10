// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBPolylineView.h"

@implementation OBPolylineView

@synthesize polylineColor;
@synthesize polylineAlpha;
@synthesize polylineWidth;
@synthesize polylineBorderColor;
@synthesize polylineBorderWidth;

- (id) initWithPolyline: (MKPolyline*) polyline
{
	OBPolylineView* pv = [super initWithPolyline: polyline];
	if (pv)
	{
		self.polylineColor = [UIColor blueColor];
		self.polylineAlpha = 0.5;
		self.polylineWidth = 4.0;
		self.polylineBorderColor = [UIColor blackColor];
		self.polylineBorderWidth = 1.0;
	}
	return pv;
}

- (void) dealloc
{
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
	
	if (polylineAlpha < 1.0)
		CGContextSetAlpha(context, polylineAlpha);
	CGContextBeginTransparencyLayer(context, NULL);
	
	// draw the dark colour thicker
	CGContextAddPath(context, self.path);
	CGContextSetStrokeColorWithColor(context, self.polylineBorderColor.CGColor);
	CGContextSetLineWidth(context, width1);
	CGContextSetLineCap(context, self.lineCap);
	CGContextStrokePath(context);
	
	// now draw the stroke color with the regular width
	CGContextAddPath(context, self.path);
	CGContextSetStrokeColorWithColor(context, self.polylineColor.CGColor);
	CGContextSetLineWidth(context, width2);
	CGContextSetLineCap(context, self.lineCap);
	CGContextStrokePath(context);
	
	CGContextEndTransparencyLayer(context);
}

@end
