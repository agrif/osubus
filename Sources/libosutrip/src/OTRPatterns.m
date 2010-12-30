// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTRPatterns.h"

@implementation OTRPatterns

- (id) initWithDelegate: (id<OTRequestDelegate>) del rt: (NSString*) rt;
{
	NSDictionary* arguments = [[NSDictionary alloc] initWithObjectsAndKeys: rt, @"rt", nil];
	if ([super initWithName: @"getpatterns" arguments: arguments delegate: del] == nil)
	{
		[arguments release];
		return nil;
	}
	
	[arguments release];
	
	construct = [[NSMutableArray alloc] init];
	part = [[NSMutableDictionary alloc] init];
	subconstruct = [[NSMutableArray alloc] init];
	subpart = [[NSMutableDictionary alloc] init];

	return self;
}

- (id) initWithDelegate: (id<OTRequestDelegate>) del pid: (NSString*) pid;
{
	NSDictionary* arguments = [[NSDictionary alloc] initWithObjectsAndKeys: pid, @"pid", nil];
	if ([super initWithName: @"getpatterns" arguments: arguments delegate: del] == nil)
	{
		[arguments release];
		return nil;
	}
	
	[arguments release];
	
	construct = [[NSMutableArray alloc] init];
	part = [[NSMutableDictionary alloc] init];
	subconstruct = [[NSMutableArray alloc] init];
	subpart = [[NSMutableDictionary alloc] init];

	return self;
}

- (void) dealloc
{
	if (construct)
		[construct release];
	if (part)
		[part release];
	if (subconstruct)
		[subconstruct release];
	if (subpart)
		[subpart release];

	[super dealloc];
}

- (void) didEndElement: (NSString*) elementName withText: (NSString*) text
{
	if ([elementName isEqual: @"ptr"])
	{
		[part setObject: subconstruct forKey: @"pt"];
		[subconstruct release];
		subconstruct = [[NSMutableArray alloc] init];
		
		[construct addObject: part];
		[part release];
		part = [[NSMutableDictionary alloc] init];
	} else if ([elementName isEqual: @"pt"]) {
		[subconstruct addObject: subpart];
		[subpart release];
		subpart = [[NSMutableDictionary alloc] init];
	} else if ([elementName isEqual: @"pid"]) {
		[part setObject: [NSNumber numberWithInt: [text intValue]] forKey: @"pid"];
	} else if ([elementName isEqual: @"ln"]) {
		[part setObject: [NSNumber numberWithInt: [text intValue]] forKey: @"ln"];
	} else if ([elementName isEqual: @"rtdir"]) {
		[part setObject: text forKey: @"rtdir"];
	} else if ([elementName isEqual: @"rtdir"]) {
		[part setObject: text forKey: @"rtdir"];
	} else if ([elementName isEqual: @"seq"]) {
		[subpart setObject: [NSNumber numberWithInt: [text intValue]] forKey: @"seq"];
	} else if ([elementName isEqual: @"typ"]) {
		[subpart setObject: text forKey: @"typ"];
	} else if ([elementName isEqual: @"stpid"]) {
		[subpart setObject: [NSNumber numberWithInt: [text intValue]] forKey: @"stpid"];
	} else if ([elementName isEqual: @"stpnm"]) {
		[subpart setObject: text forKey: @"stpnm"];
	} else if ([elementName isEqual: @"pdist"]) {
		[subpart setObject: [NSNumber numberWithFloat: [text floatValue]] forKey: @"pdist"];
	} else if ([elementName isEqual: @"lat"]) {
		[subpart setObject: [NSNumber numberWithDouble: [text doubleValue]] forKey: @"lat"];
	} else if ([elementName isEqual: @"lon"]) {
		[subpart setObject: [NSNumber numberWithDouble: [text doubleValue]] forKey: @"lon"];
	}
}

- (void) didEndDocument
{
	[self setResult: [NSDictionary dictionaryWithObjectsAndKeys: construct, @"ptr", nil]];
	[construct release];
	construct = nil;
	[part release];
	part = nil;
	[subconstruct release];
	subconstruct = nil;
	[subpart release];
	subpart = nil;
}

@end
