// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTRServiceBulletins.h"

@implementation OTRServiceBulletins

- (id) initWithDelegate: (id<OTRequestDelegate>) del rt: (NSString*) rt rtdir: (NSString*) rtdir;
{
	NSDictionary* arguments = [[NSDictionary alloc] initWithObjectsAndKeys: rt, @"rt", rtdir, @"rtdir", nil];
	if ([super initWithName: @"getservicebulletins" arguments: arguments delegate: del] == nil)
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

- (id) initWithDelegate: (id<OTRequestDelegate>) del stpid: (NSString*) stpid;
{
	NSDictionary* arguments = [[NSDictionary alloc] initWithObjectsAndKeys: stpid, @"stpid", nil];
	if ([super initWithName: @"getservicebulletins" arguments: arguments delegate: del] == nil)
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

- (id) initCustomWithDelegate: (id<OTRequestDelegate>) del rt: (NSString*) rt rtdir: (NSString*) rtdir;
{
	NSDictionary* arguments = [[NSDictionary alloc] initWithObjectsAndKeys: rt, @"rt", rtdir, @"rtdir", nil];
	if ([super initCustomWithName: @"getservicebulletins" arguments: arguments delegate: del] == nil)
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

- (id) initCustomWithDelegate: (id<OTRequestDelegate>) del stpid: (NSString*) stpid;
{
	NSDictionary* arguments = [[NSDictionary alloc] initWithObjectsAndKeys: stpid, @"stpid", nil];
	if ([super initCustomWithName: @"getservicebulletins" arguments: arguments delegate: del] == nil)
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
	if ([elementName isEqual: @"sb"])
	{
		if ([subconstruct count] > 0)
		{
			[part setObject: subconstruct forKey: @"srvc"];
			[subconstruct release];
			subconstruct = [[NSMutableArray alloc] init];
		}

		[construct addObject: part];
		[part release];
		part = [[NSMutableDictionary alloc] init];
	} else if ([elementName isEqual: @"srvc"]) {
		if ([subpart count] > 0)
		{
			[subconstruct addObject: subpart];
			[subpart release];
			subpart = [[NSMutableDictionary alloc] init];
		}
	}
	
	if (text == nil)
		return; // weird!
	
	if ([elementName isEqual: @"nm"]) {
		[part setObject: text forKey: @"nm"];
	} else if ([elementName isEqual: @"sbj"]) {
		[part setObject: text forKey: @"sbj"];
	} else if ([elementName isEqual: @"dtl"]) {
		[part setObject: text forKey: @"dtl"];
	} else if ([elementName isEqual: @"brf"]) {
		[part setObject: text forKey: @"brf"];
	} else if ([elementName isEqual: @"prty"]) {
		[part setObject: text forKey: @"prty"];
	} else if ([elementName isEqual: @"rt"]) {
		[subpart setObject: text forKey: @"rt"];
	} else if ([elementName isEqual: @"rtdir"]) {
		[subpart setObject: text forKey: @"rtdir"];
	} else if ([elementName isEqual: @"stpid"]) {
		[subpart setObject: [NSNumber numberWithInt: [text intValue]] forKey: @"stpid"];
	} else if ([elementName isEqual: @"stpnm"]) {
		[subpart setObject: text forKey: @"stpnm"];
	}
}

- (void) didEndDocument
{
	[self setResult: [NSDictionary dictionaryWithObjectsAndKeys: construct, @"sb", nil]];
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
