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

@synthesize stop;

- (id) initWithMapViewController: (OBMapViewController*) _map route: (NSDictionary*) _route stop: (NSDictionary*) _stop
{
	if (self = [super initWithAnnotation: nil reuseIdentifier: @"OBStopAnnotation"])
	{
		map = _map;
		if (_route)
			route = [_route retain];
		stop = [_stop retain];
		
		if (route)
		{
			self.pinColor = [[route objectForKey: @"color"] colorFromHex];
		} else {
			// FIXME special image for primary stop?
			self.pinColor = [UIColor whiteColor];
		}
		
		self.pinShadowed = YES;
		self.pinShadowRadius = 4.0;
		self.pinShadowColor = [UIColor colorWithWhite: 0.0 alpha: 0.33];
		
		self.mask = [UIImage imageNamed: @"pin-mask"];
		self.overlay = [UIImage imageNamed: OSU_BUS_NEW_UI ? @"pin-overlay-new" : @"pin-overlay"];
		
		self.centerOffset = CGPointMake(0.0, (-self.frame.size.height / 2.0) + self.pinShadowRadius);
		
		self.canShowCallout = YES;
		
		if (route)
		{
			// set up callout button
			UIButton* button = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
			[button addTarget: self action: @selector(showStopViewController) forControlEvents: UIControlEventTouchUpInside];
			self.rightCalloutAccessoryView = button;
		}
		
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
	if (route)
		[route release];
	[stop release];
	
	[super dealloc];
}

- (void) showStopViewController
{
	// parent predictions controller search
	OBPredictionsViewController* parent = nil;
	for (UIViewController* controller in map.navigationController.viewControllers)
	{
		if ([controller isKindOfClass: [OBPredictionsViewController class]])
		{
			parent = (OBPredictionsViewController*)controller;
			break;
		}
	}
	
	OBPredictionsViewController* predictions = [[OBPredictionsViewController alloc] initWithNibName: @"OBPredictionsViewController" bundle: nil];
	[predictions setStop: stop];
	
	if (parent)
	{
		// moving into what could become an infinite loop
		// replace view stack with just top / map / new
		NSArray* newstack = [[NSArray alloc] initWithObjects: [map.navigationController.viewControllers objectAtIndex: 0], map, nil];
		[map setStop: nil];
		[map.navigationController setViewControllers: newstack animated: NO];
		[newstack release];
	}
	
	[map.navigationController pushViewController: predictions animated: YES];
	
	[predictions release];
}

#pragma mark OBMapViewAnnotation protocol

- (MKAnnotationView*) annotationViewForMap: (MKMapView*) mapView
{
	// *this* is how the map view takes it's annotation views
	return [self autorelease];
}

- (NSObject*) visibilityKey
{
	return [stop objectForKey: @"id"];
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
