// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "UIApplication+NiceNetworkIndicator.h"

static NSMutableArray* networkObjects = nil;

@implementation UIApplication (NiceNetworkIndicator)

- (void) setNetworkInUse: (BOOL) inUse byObject: (NSObject*) obj
{
	if (!networkObjects)
	{
		networkObjects = [[NSMutableArray alloc] init];
	}
	
	if (inUse)
	{
		if ([networkObjects containsObject: obj])
			return;
		
		[networkObjects addObject: obj];
	} else {
		if (![networkObjects containsObject: obj])
			return;
		
		[networkObjects removeObject: obj];
	}
	
	[self setNetworkActivityIndicatorVisible: networkObjects.count > 0];
}

@end
