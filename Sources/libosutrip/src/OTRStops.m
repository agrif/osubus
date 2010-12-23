// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTRStops.h"

@implementation OTRStops

- (id) initWithDelegate: (id<OTRequestDelegate>) del rt: (NSString*) rt dir: (NSString*) dir;
{
	NSDictionary* arguments = [[NSDictionary alloc] initWithObjectsAndKeys: rt, @"rt", dir, @"dir", nil];
	if ([super initWithName: @"getstops" arguments: arguments delegate: del] == nil)
	{
		[arguments release];
		return nil;
	}
	
	[arguments release];
	
	construct = [[NSMutableArray alloc] init];
	part = [[NSMutableDictionary alloc] init];

	return self;
}

- (void) dealloc
{
	if (construct)
		[construct release];
	if (part)
		[part release];

	[super dealloc];
}

- (void) didEndElement: (NSString*) elementName withText: (NSString*) text
{
	if ([elementName isEqual: @"stop"])
	{
		[construct addObject: part];
		[part release];
		part = [[NSMutableDictionary alloc] init];
	} else if ([elementName isEqual: @"stpid"]) {
		[part setObject: [NSNumber numberWithInt: [text intValue]] forKey: @"stpid"];
	} else if ([elementName isEqual: @"stpnm"]) {
		[part setObject: text forKey: @"stpnm"];
	} else if ([elementName isEqual: @"lat"]) {
		[part setObject: [NSNumber numberWithDouble: [text doubleValue]] forKey: @"lat"];
	} else if ([elementName isEqual: @"lon"]) {
		[part setObject: [NSNumber numberWithDouble: [text doubleValue]] forKey: @"lon"];
	}
}

- (void) didEndDocument
{
	[self setResult: [NSDictionary dictionaryWithObjectsAndKeys: construct, @"stop", nil]];
	[construct release];
	construct = nil;
	[part release];
	part = nil;
}

@end
