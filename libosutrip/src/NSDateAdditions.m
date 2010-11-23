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

	// hack
	// OH GOD WHAT A HACK I'M CHANGING THIS NOW UGH
	// FIXME : I didn't actually change it... *sad face*
	// THIS is NUMBER ONE on my list of fixes now.... ARRRRGGH
	[nicedate appendString: @" -0500"];
	
	return [NSDate dateWithString: nicedate];
}

@end
