// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTRPredictions.h"

#import "NSDateAdditions.h"

@implementation OTRPredictions

- (id) initWithDelegate: (id<OTRequestDelegate>) del stpid: (NSString*) stpid rt: (NSString*) rt top: (NSInteger) top;
{
	NSMutableDictionary* arguments = [[NSMutableDictionary alloc] initWithObjectsAndKeys: stpid, @"stpid", nil];
	
	if (rt)
	{
		[arguments setObject: rt forKey: @"rt"];
	}

	if (top > 0)
	{
		NSNumber* num = [[NSNumber alloc] initWithLong: top];
		NSString* numstr = [[NSString alloc] initWithFormat: @"%@", num, nil];
		[arguments setObject: numstr forKey: @"top"];
		[numstr release];
		[num release];
	}
	
	if ([super initWithName: @"getpredictions" arguments: arguments delegate: del] == nil)
	{
		[arguments release];
		return nil;
	}
	
	[arguments release];
	
	construct = [[NSMutableArray alloc] init];
	part = [[NSMutableDictionary alloc] init];

	return self;
}

- (id) initWithDelegate: (id<OTRequestDelegate>) del vid: (NSString*) vid top: (NSInteger) top;
{
	NSMutableDictionary* arguments = [[NSMutableDictionary alloc] initWithObjectsAndKeys: vid, @"vid", nil];
	
	if (top > 0)
	{
		NSNumber* num = [[NSNumber alloc] initWithLong: top];
		NSString* numstr = [[NSString alloc] initWithFormat: @"%@", num, nil];
		[arguments setObject: numstr forKey: @"top"];
		[numstr release];
		[num release];
	}
	
	if ([super initWithName: @"getpredictions" arguments: arguments delegate: del] == nil)
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
	if ([elementName isEqual: @"prd"])
	{
		[construct addObject: part];
		[part release];
		part = [[NSMutableDictionary alloc] init];
	} else if ([elementName isEqual: @"vid"]) {
		[part setObject: text forKey: @"vid"];
	} else if ([elementName isEqual: @"typ"]) {
		[part setObject: text forKey: @"typ"];
	} else if ([elementName isEqual: @"stpnm"]) {
		[part setObject: text forKey: @"stpnm"];
	} else if ([elementName isEqual: @"rt"]) {
		[part setObject: text forKey: @"rt"];
	} else if ([elementName isEqual: @"rtdir"]) {
		[part setObject: text forKey: @"rtdir"];
	} else if ([elementName isEqual: @"des"]) {
		[part setObject: text forKey: @"des"];
	} else if ([elementName isEqual: @"tmstmp"]) {
		[part setObject: [NSDate dateWithTRIPString: text] forKey: @"tmstmp"];
	} else if ([elementName isEqual: @"prdtm"]) {
		[part setObject: [NSDate dateWithTRIPString: text] forKey: @"prdtm"];
	} else if ([elementName isEqual: @"des"]) {
		[part setObject: text forKey: @"des"];
	} else if ([elementName isEqual: @"dly"]) {
		[part setObject: [NSNumber numberWithBool: [text boolValue]] forKey: @"dly"];
	} else if ([elementName isEqual: @"stpid"]) {
		[part setObject: [NSNumber numberWithInt: [text intValue]] forKey: @"stpid"];
	} else if ([elementName isEqual: @"vid"]) {
		[part setObject: [NSNumber numberWithInt: [text intValue]] forKey: @"vid"];
	} else if ([elementName isEqual: @"dstp"]) {
		[part setObject: [NSNumber numberWithInt: [text intValue]] forKey: @"dstp"];
	}
}

- (void) didEndDocument
{
	[self setResult: [NSDictionary dictionaryWithObjectsAndKeys: construct, @"prd", nil]];
	[construct release];
	construct = nil;
	[part release];
	part = nil;
}

@end
