// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTRVehicles.h"

#import "NSDateAdditions.h"

@implementation OTRVehicles

- (id) initWithDelegate: (id<OTRequestDelegate>) del rt: (NSString*) rt;
{
	NSDictionary* arguments = [[NSDictionary alloc] initWithObjectsAndKeys: rt, @"rt", nil];
	if ([super initWithName: @"getvehicles" arguments: arguments delegate: del] == nil)
	{
		[arguments release];
		return nil;
	}
	
	[arguments release];
	
	construct = [[NSMutableArray alloc] init];
	part = [[NSMutableDictionary alloc] init];

	return self;
}

- (id) initWithDelegate: (id<OTRequestDelegate>) del vid: (NSString*) vid;
{
	NSDictionary* arguments = [[NSDictionary alloc] initWithObjectsAndKeys: vid, @"vid", nil];
	if ([super initWithName: @"getvehicles" arguments: arguments delegate: del] == nil)
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
	if ([elementName isEqual: @"vehicle"])
	{
		[construct addObject: part];
		[part release];
		part = [[NSMutableDictionary alloc] init];
	} else if ([elementName isEqual: @"vid"]) {
		[part setObject: text forKey: @"vid"];
	} else if ([elementName isEqual: @"tmstmp"]) {
		[part setObject: [NSDate dateWithTRIPString: text] forKey: @"tmstmp"];
	} else if ([elementName isEqual: @"lat"]) {
		[part setObject: [NSNumber numberWithDouble: [text doubleValue]] forKey: @"lat"];
	} else if ([elementName isEqual: @"lon"]) {
		[part setObject: [NSNumber numberWithDouble: [text doubleValue]] forKey: @"lon"];
	} else if ([elementName isEqual: @"hdg"]) {
		[part setObject: [NSNumber numberWithInt: [text intValue]] forKey: @"hdg"];
	} else if ([elementName isEqual: @"pid"]) {
		[part setObject: [NSNumber numberWithInt: [text intValue]] forKey: @"pid"];
	} else if ([elementName isEqual: @"pdist"]) {
		[part setObject: [NSNumber numberWithInt: [text intValue]] forKey: @"pdist"];
	} else if ([elementName isEqual: @"des"]) {
		[part setObject: text forKey: @"des"];
	} else if ([elementName isEqual: @"dly"]) {
		[part setObject: [NSNumber numberWithBool: [text boolValue]] forKey: @"dly"];
	}
}

- (void) didEndDocument
{
	[self setResult: [NSDictionary dictionaryWithObjectsAndKeys: construct, @"vehicle", nil]];
	[construct release];
	construct = nil;
	[part release];
	part = nil;
}

@end
