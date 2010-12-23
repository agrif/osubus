// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTRDirections.h"

@implementation OTRDirections

- (id) initWithDelegate: (id<OTRequestDelegate>) del rt: (NSString*) rt
{
	NSDictionary* arguments = [[NSDictionary alloc] initWithObjectsAndKeys: rt, @"rt", nil];
	if ([super initWithName: @"getdirections" arguments: arguments delegate: del] == nil)
	{
		[arguments release];
		return nil;
	}

	[arguments release];
	construct = [[NSMutableArray alloc] init];

	return self;
}

- (void) dealloc
{
	if (construct)
		[construct release];
	[super dealloc];
}

- (void) didEndElement: (NSString*) elementName withText: (NSString*) text
{
	if (![elementName isEqual: @"dir"])
		return;

	[construct addObject: text];
}

- (void) didEndDocument
{
	[self setResult: [NSDictionary dictionaryWithObjectsAndKeys: construct, @"dir", nil]];
	[construct release];
	construct = nil;
}

@end
