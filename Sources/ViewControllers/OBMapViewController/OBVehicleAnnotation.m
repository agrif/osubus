// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBVehicleAnnotation.h"

#import <CoreGraphics/CoreGraphics.h>
#import "UIImage+ScaleCompat.h"
#import "OBMapViewController.h"
#import "OBPredictionsViewController.h"
#import "NSString+HexColor.h"
#import "OBColorBandView.h"

@implementation OBVehicleAnnotation

@synthesize vehicle;

- (id) initWithMapViewController: (OBMapViewController*) _map route: (NSDictionary*) _route vehicle: (NSDictionary*) _vehicle
{
	if (self = [super initWithAnnotation: nil reuseIdentifier: @"OBVehicleAnnotation"])
	{
		map = _map;
		if (_route)
			route = [_route retain];
		vehicle = [_vehicle retain];
		
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
		self.overlay = [UIImage imageNamed: @"pin-overlay"];
		
		self.centerOffset = CGPointMake(0.0, (-self.frame.size.height / 2.0) + self.pinShadowRadius);
		
		self.canShowCallout = YES;
		
		if (route)
		{
			// set up callout button
			UIButton* button = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
			[button addTarget: self action: @selector(showVehicleViewController) forControlEvents: UIControlEventTouchUpInside];
			self.rightCalloutAccessoryView = button;
		}
	}
	
	return self;
}

- (void) dealloc
{
	if (route)
		[route release];
	[vehicle release];
	
	[super dealloc];
}

- (MKAnnotationView*) annotationViewForMap: (MKMapView*) mapView
{
	// *this* is how the map view takes it's annotation views
	return [self autorelease];
}

- (void) showVehicleViewController
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
	[predictions setVehicle: [vehicle objectForKey: @"vid"] onRoute: [route objectForKey: @"short"]];
	
	if (!parent)
	{
		[map.navigationController pushViewController: predictions animated: YES];
	} else {
		// moving into what could become an infinite loop
		// replace view stack with just top / map / new
		NSArray* newstack = [[NSArray alloc] initWithObjects: [map.navigationController.viewControllers objectAtIndex: 0], map, predictions, nil];
		[map setStop: nil];
		[map.navigationController setViewControllers: newstack animated: YES];
		[newstack release];
	}
	
	[predictions release];
}

#pragma mark Annotation Protocol

- (CLLocationCoordinate2D) coordinate
{
	CLLocationCoordinate2D loc;
	loc.latitude = [[vehicle objectForKey: @"lat"] floatValue];
	loc.longitude = [[vehicle objectForKey: @"lon"] floatValue];
	return loc;
}

- (NSString*) title
{
	return [NSString stringWithFormat: @"%@ %@", [route objectForKey: @"short"], [vehicle objectForKey: @"vid"]];
}

@end
