// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "NSDateAdditions.h"

@implementation NSDate (OTNSDateAdditions)

+ (NSDate*) dateWithTRIPString: (NSString*) text
{
	NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
	
	[dateFormat setDateFormat: @"yyyyMMdd HH:mm"];
	NSDate* date = [dateFormat dateFromString: text];
	if (date)
	{
		[dateFormat release];
		return date;
	}
	
	// we failed, try again (last try)
	[dateFormat setDateFormat: @"yyyyMMdd HH:mm:ss"];
	date = [dateFormat dateFromString: text];
	[dateFormat release];
	return date;
}

@end
