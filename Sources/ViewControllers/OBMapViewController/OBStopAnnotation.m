//
//  OBStopAnnotation.m
//  OSU Bus
//
//  Created by Aaron Griffith on 12/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OBStopAnnotation.h"

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
		
		self.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
		self.backgroundColor = [[route objectForKey: @"color"] colorFromHex];
		
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
	NSLog(@"opening predictions view via map");
	OBPredictionsViewController* predictions = [[OBPredictionsViewController alloc] initWithNibName: @"OBPredictionsViewController" bundle: nil];
	[predictions setStop: stop];
	[map.navigationController pushViewController: predictions animated: NO];
	[predictions release];
}

#pragma mark Annotation Protocol

- (CLLocationCoordinate2D) coordinate
{
	return CLLocationCoordinate2DMake([[stop objectForKey: @"lat"] floatValue], [[stop objectForKey: @"lon"] floatValue]);
}

- (NSString*) title
{
	return [stop objectForKey: @"name"];
}

@end
