//
//  OBStopAnnotation.m
//  OSU Bus
//
//  Created by Aaron Griffith on 12/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OBStopAnnotation.h"

#import "NSString+HexColor.h"

@implementation OBStopAnnotation

- (id) initWithRoute: (NSDictionary*) _route stop: (NSDictionary*) _stop
{
	if (self = [super initWithAnnotation: self reuseIdentifier: @"OBStopAnnotation"])
	{
		route = [_route retain];
		stop = [_stop retain];
		
		self.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
		self.backgroundColor = [[route objectForKey: @"color"] colorFromHex];
	}
	
	return self;
}

- (void) dealloc
{
	[route release];
	[stop release];
	
	[super dealloc];
}

- (MKAnnotationView*) annotationViewForMap: (MKMapView*) map
{
	return self;
}

- (CLLocationCoordinate2D) coordinate
{
	return CLLocationCoordinate2DMake([[stop objectForKey: @"lat"] floatValue], [[stop objectForKey: @"lon"] floatValue]);
}

- (BOOL) canShowCallout
{
	return YES;
}

- (NSString*) title
{
	return [stop objectForKey: @"name"];
}

@end
