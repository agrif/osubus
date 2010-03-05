// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTRTime.h"

#import "NSDateAdditions.h"

@implementation OTRTime

- (id) initWithDelegate: (id<OTRequestDelegate>) del
{
	if ([super initWithName: @"gettime" arguments: nil delegate: del] == nil)
	{
		return nil;
	}
	return self;
}

- (void) didEndElement: (NSString*) elementName withText: (NSString*) text
{
	if (![elementName isEqual: @"tm"])
	{
		return;
	}
	
	NSDate* time = [NSDate dateWithTRIPString: text];
	[self setResult: [NSDictionary dictionaryWithObjectsAndKeys: time, @"tm", nil]];
}

@end
