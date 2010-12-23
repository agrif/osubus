// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBPolylineManager based on <https://github.com/wlach/nvpolyline>,
// with small differences

#import "OBPolylineManager.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

// internal view that handles actually drawing!
@interface OBPolylineView : MKAnnotationView <MKAnnotation>
{
	OBPolylineManager* polylines;
	MKMapView* map;
}

- (id) initWithPolylineManager: (OBPolylineManager*) poly;

@end

@implementation OBPolylineView

- (id) initWithPolylineManager: (OBPolylineManager*) poly
{
	if (self = [super init])
	{
		polylines = poly;
		map = poly.map;
		
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = NO;
		self.frame = CGRectMake(0.0, 0.0, map.frame.size.width, map.frame.size.height);
	}
	
	return self;
}

- (CLLocationCoordinate2D) coordinate
{
	return map.centerCoordinate;
}

- (CGPoint) centerOffset
{
	// we hook this to get real-time map position updates
	[self setNeedsDisplay];
	return [super centerOffset];
}

- (void) drawRect: (CGRect) rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	CGContextSetAlpha(context, 0.5);
	CGContextSetLineWidth(context, 4.0);
	
	CGPoint a = [map convertCoordinate: CLLocationCoordinate2DMake(39.96, -82.801389) toPointToView: self];
	CGPoint b = [map convertCoordinate: CLLocationCoordinate2DMake(39.96, -80) toPointToView: self];
	
	CGContextMoveToPoint(context, a.x, a.y);
	CGContextAddLineToPoint(context, b.x, b.y);
	
	CGContextStrokePath(context);
}

@end

@implementation OBPolylineManager

@synthesize map;

- (id) initWithMapView: (MKMapView*) mapView
{
	if (self = [super init])
	{
		map = [mapView retain];
		
		OBPolylineView* view = [[OBPolylineView alloc] initWithPolylineManager: self];
		[map addAnnotation: view];
		[view release];
	}
	
	return self;
}

- (void) dealloc
{
	[map release];
	
	[super dealloc];
}

- (MKAnnotationView*) mapView: (MKMapView*) mapView viewForAnnotation: (id <MKAnnotation>) annotation
{
	if ([annotation isKindOfClass: [OBPolylineView class]])
		return (OBPolylineView*)annotation;
	return nil;
}

@end
