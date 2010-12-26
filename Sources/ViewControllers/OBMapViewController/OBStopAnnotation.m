// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBStopAnnotation.h"

#import <CoreGraphics/CoreGraphics.h>
#import "OBMapViewController.h"
#import "OBPredictionsViewController.h"
#import "NSString+HexColor.h"

@implementation OBStopAnnotation

- (id) initWithMapViewController: (OBMapViewController*) _map route: (NSDictionary*) _route stop: (NSDictionary*) _stop
{
	if (self = [super initWithAnnotation: self reuseIdentifier: @"OBStopAnnotation"])
	{
		map = _map;
		route = [_route retain];
		stop = [_stop retain];
		
		self.frame = CGRectMake(0.0, 0.0, 24.0, 24.0);
		color = [[[route objectForKey: @"color"] colorFromHex] retain];
		self.backgroundColor = [UIColor clearColor];
		
		self.canShowCallout = YES;
		
		// set up callout button
		UIButton* button = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
		[button addTarget: self action: @selector(showStopViewController) forControlEvents: UIControlEventTouchUpInside];
		self.rightCalloutAccessoryView = button;
	}
	
	return self;
}

- (void) dealloc
{
	[route release];
	[stop release];
	[color release];
	
	[super dealloc];
}

- (MKAnnotationView*) annotationViewForMap: (MKMapView*) mapView
{
	return self;
}

- (void) drawRect: (CGRect) rect
{
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGRect area = CGRectMake(1.0, 1.0, self.frame.size.width - 2.0, self.frame.size.height - 2.0);
	
	CGContextSetFillColorWithColor(c, [color CGColor]);
	CGContextSetAlpha(c, 1.0);
	
	CGContextAddEllipseInRect(c, area);
	CGContextFillPath(c);
	
	CGContextSetRGBStrokeColor(c, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(c, 2.0);
	
	CGContextAddEllipseInRect(c, area);
	CGContextStrokePath(c);
}

- (void) showStopViewController
{
	OBPredictionsViewController* predictions = [[OBPredictionsViewController alloc] initWithNibName: @"OBPredictionsViewController" bundle: nil];
	[predictions setStop: stop];
	[map.navigationController pushViewController: predictions animated: YES];
	[predictions release];
}

#pragma mark Annotation Protocol

- (CLLocationCoordinate2D) coordinate
{
	CLLocationCoordinate2D loc;
	loc.latitude = [[stop objectForKey: @"lat"] floatValue];
	loc.longitude = [[stop objectForKey: @"lon"] floatValue];
	return loc;
}

- (NSString*) title
{
	return [stop objectForKey: @"name"];
}

@end
