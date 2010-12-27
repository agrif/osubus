// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBStopAnnotation.h"

#import <CoreGraphics/CoreGraphics.h>
#import "UIImage+ScaleCompat.h"
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
		
		self.pinColor = [[route objectForKey: @"color"] colorFromHex];
		self.mask = [UIImage compatImageNamed: @"pin-mask"];
		self.overlay = [UIImage compatImageNamed: @"pin-overlay"];
		
		self.centerOffset = CGPointMake(0.0, -self.frame.size.height / 2.0);
		
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
	
	[super dealloc];
}

- (MKAnnotationView*) annotationViewForMap: (MKMapView*) mapView
{
	return self;
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
