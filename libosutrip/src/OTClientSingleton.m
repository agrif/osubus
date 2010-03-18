// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTClient.h"

@implementation OTClient (OTClientSingleton)

static OTClient* clientSingleton = nil;

// so much singleton!!

+ (OTClient*) sharedClient
{
	if (clientSingleton == nil)
	{
		clientSingleton = [[super allocWithZone: NULL] init];
	}
	return clientSingleton;
}

+ (id) allocWithZone: (NSZone*) zone
{
	return [self sharedClient];
}

- (id) copyWithZone: (NSZone*) zone
{
	return self;
}

- (id) retain
{
	return self;
}

- (NSUInteger) retainCount
{
	return NSUIntegerMax; // non-releasable
}

- (void) release
{ }

- (id) autorelease
{
	return self;
}

@end
