// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "NSDateAdditions.h"

static NSTimeInterval correction_interval = 0.0;

@implementation NSDate (OTNSDateAdditions)

+ (NSDate*) dateWithTRIPString: (NSString*) text
{
	return [NSDate dateWithTRIPString: text useToSynchronize: NO];
}

+ (NSDate*) dateWithTRIPString: (NSString*) text useToSynchronize: (BOOL) sync
{
	NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
	
	[dateFormat setDateFormat: @"yyyyMMdd HH:mm"];
	NSDate* date = [dateFormat dateFromString: text];
	if (!date)
	{
		// we failed, try again (last try)
		[dateFormat setDateFormat: @"yyyyMMdd HH:mm:ss"];
		date = [dateFormat dateFromString: text];
	}
	
	[dateFormat release];
	
	// if we've failed, stop now
	if (!date)
		return nil;
	
	// handle synchronization
	if (sync)
	{
		// negative timeIntervalSinceNow means date is EARLIER, so we must
		// ADD an interval to get to our time => we need -interval, not +interval
		correction_interval = -[date timeIntervalSinceNow];
		
		NSLog(@"[time sync] theirs: %@ ours: %@ correction: %f", date, [NSDate date], correction_interval);
	} else {
		// we must apply the sync factor
		date = [date dateByAddingTimeInterval: correction_interval];
	}
	
	return date;
}

@end
