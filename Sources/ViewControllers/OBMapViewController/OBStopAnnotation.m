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
#import "OBColorBandView.h"

@implementation OBStopAnnotation

- (id) initWithMapViewController: (OBMapViewController*) _map route: (NSDictionary*) _route stop: (NSDictionary*) _stop
{
	if (self = [super initWithAnnotation: nil reuseIdentifier: @"OBStopAnnotation"])
	{
		map = _map;
		route = [_route retain];
		stop = [_stop retain];
		
		self.pinColor = [[route objectForKey: @"color"] colorFromHex];
		self.pinShadowed = YES;
		self.pinShadowRadius = 4.0;
		self.pinShadowColor = [UIColor colorWithWhite: 0.0 alpha: 0.33];
		
		self.mask = [UIImage imageNamed: @"pin-mask"];
		self.overlay = [UIImage imageNamed: @"pin-overlay"];
		
		self.centerOffset = CGPointMake(0.0, (-self.frame.size.height / 2.0) + self.pinShadowRadius);
		
		self.canShowCallout = YES;
		
		// set up callout button
		UIButton* button = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
		[button addTarget: self action: @selector(showStopViewController) forControlEvents: UIControlEventTouchUpInside];
		self.rightCalloutAccessoryView = button;
		
		// set up route color bands
		NSMutableArray* colors = [[NSMutableArray alloc] initWithCapacity: [[stop objectForKey: @"routes"] count]];
		for (NSDictionary* r in [stop objectForKey: @"routes"])
		{
			[colors addObject:[[r objectForKey: @"color"] colorFromHex]];
		}
		
		OBColorBandView* bands = [[OBColorBandView alloc] initWithFrame: CGRectMake(0.0, 0.0, 32.0, 32.0)];
		bands.colors = colors;
		[colors release];
		bands.autoResizing = YES;
		
		self.leftCalloutAccessoryView = bands;
		[bands release];
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
	// this is used in a map view delegate that *expects* an object to be
	// *created*, so retain it...
	return [self retain];
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
