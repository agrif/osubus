// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "NSDateAdditions.h"

@implementation NSDate (OTNSDateAdditions)

+ (NSDate*) dateWithTRIPString: (NSString*) text
{
	if (!([text length] == 14 || [text length] == 17))
		return nil;
	
	NSMutableString* nicedate = [NSMutableString string];
	[nicedate appendString: [text substringWithRange: NSMakeRange(0, 4)]];
	[nicedate appendString: @"-"];
	[nicedate appendString: [text substringWithRange: NSMakeRange(4, 2)]];
	[nicedate appendString: @"-"];
	[nicedate appendString: [text substringWithRange: NSMakeRange(6, 2)]];
	[nicedate appendString: [text substringFromIndex: 8]];
	if ([text length] == 14)
	{
		// we're missing the seconds (vehicle tmstmp)
		[nicedate appendString: @":00"];
	}

	// FIXME use NSDateFormatter
	[nicedate appendFormat: @" %+03i00", [[NSTimeZone defaultTimeZone] secondsFromGMT] / (60 * 60)];
	
	return [NSDate dateWithString: nicedate];
}

@end
