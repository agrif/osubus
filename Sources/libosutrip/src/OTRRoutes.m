// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTRRoutes.h"

@implementation OTRRoutes

- (id) initWithDelegate: (id<OTRequestDelegate>) del
{
	if ([super initWithName: @"getroutes" arguments: nil delegate: del] == nil)
	{
		return nil;
	}
	
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
	if ([elementName isEqual: @"route"])
	{
		[construct addObject: part];
		[part release];
		part = [[NSMutableDictionary alloc] init];
	} else if ([elementName isEqual: @"rt"]) {
		[part setObject: text forKey: @"rt"];
	} else if ([elementName isEqual: @"rtnm"]) {
		[part setObject: text forKey: @"rtnm"];
	}
}

- (void) didEndDocument
{
	[self setResult: [NSDictionary dictionaryWithObjectsAndKeys: construct, @"route", nil]];
	[construct release];
	construct = nil;
	[part release];
	part = nil;
}

@end
