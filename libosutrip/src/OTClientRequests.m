// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTClient.h"

#import "OTRTime.h"
#import "OTRRoutes.h"
#import "OTRDirections.h"
#import "OTRStops.h"
#import "OTRPatterns.h"
#import "OTRVehicles.h"
#import "OTRServiceBulletins.h"
#import "OTRPredictions.h"

@implementation OTClient (OTClientRequests)

// now, on to actual functions!!

- (OTRequest*) requestTimeWithDelegate: (id<OTRequestDelegate>) delegate;
{
	return [[OTRTime alloc] initWithDelegate: delegate];
}

- (OTRequest*) requestRoutesWithDelegate: (id<OTRequestDelegate>) delegate;
{
	return [[OTRRoutes alloc] initWithDelegate: delegate];
}

- (OTRequest*) requestDirectionsWithDelegate: (id<OTRequestDelegate>) delegate forRoute: (NSString*) rt
{
	return [[OTRDirections alloc] initWithDelegate: delegate rt: rt];
}

- (OTRequest*) requestStopsWithDelegate: (id<OTRequestDelegate>) delegate forRoute: (NSString*) rt inDirection: (NSString*) dir
{
	return [[OTRStops alloc] initWithDelegate: delegate rt: rt dir: dir];
}

- (OTRequest*) requestPatternsWithDelegate: (id<OTRequestDelegate>) delegate forRoute: (NSString*) rt
{
	return [[OTRPatterns alloc] initWithDelegate: delegate rt: rt];
}

- (OTRequest*) requestPatternsWithDelegate: (id<OTRequestDelegate>) delegate withPatternIDs: (NSString*) pid
{
	return [[OTRPatterns alloc] initWithDelegate: delegate pid: pid];
}

- (OTRequest*) requestVehiclesWithDelegate: (id<OTRequestDelegate>) delegate forRoutes: (NSString*) rt
{
	return [[OTRVehicles alloc] initWithDelegate: delegate rt: rt];
}

- (OTRequest*) requestVehiclesWithDelegate: (id<OTRequestDelegate>) delegate withVehicleIDs: (NSString*) vid;
{
	return [[OTRVehicles alloc] initWithDelegate: delegate vid: vid];
}

- (OTRequest*) requestServiceBulletinsWithDelegate: (id<OTRequestDelegate>) delegate forRoutes: (NSString*) rt
{
	return [[OTRServiceBulletins alloc] initWithDelegate: delegate rt: rt rtdir: nil];
}

- (OTRequest*) requestServiceBulletinsWithDelegate: (id<OTRequestDelegate>) delegate forRoutes: (NSString*) rt inDirection: (NSString*) rtdir
{
	return [[OTRServiceBulletins alloc] initWithDelegate: delegate rt: rt rtdir: rtdir];
}

- (OTRequest*) requestServiceBulletinsWithDelegate: (id<OTRequestDelegate>) delegate forStopIDs: (NSString*) stpid
{
	return [[OTRServiceBulletins alloc] initWithDelegate: delegate stpid: stpid];
}

- (OTRequest*) requestPredictionsWithDelegate: (id<OTRequestDelegate>) delegate forStopIDs: (NSString*) stpid count: (NSInteger) top
{
	return [[OTRPredictions alloc] initWithDelegate: delegate stpid: stpid rt: nil top: top];
}

- (OTRequest*) requestPredictionsWithDelegate: (id<OTRequestDelegate>) delegate forStopIDs: (NSString*) stpid onRoutes: (NSString*) rt count: (NSInteger) top
{
	return [[OTRPredictions alloc] initWithDelegate: delegate stpid: stpid rt: rt top: top];
}

- (OTRequest*) requestPredictionsWithDelegate: (id<OTRequestDelegate>) delegate forVehicleIDs: (NSString*) vid count: (NSInteger) top
{
	return [[OTRPredictions alloc] initWithDelegate: delegate vid: vid top: top];
}

- (OTRequest*) requestCustomServiceBulletinsWithDelegate: (id<OTRequestDelegate>) delegate forRoutes: (NSString*) rt
{
	return [[OTRServiceBulletins alloc] initCustomWithDelegate: delegate rt: rt rtdir: nil];
}

- (OTRequest*) requestCustomServiceBulletinsWithDelegate: (id<OTRequestDelegate>) delegate forRoutes: (NSString*) rt inDirection: (NSString*) rtdir
{
	return [[OTRServiceBulletins alloc] initCustomWithDelegate: delegate rt: rt rtdir: rtdir];
}

- (OTRequest*) requestCustomServiceBulletinsWithDelegate: (id<OTRequestDelegate>) delegate forStopIDs: (NSString*) stpid
{
	return [[OTRServiceBulletins alloc] initCustomWithDelegate: delegate stpid: stpid];
}

- (NSURL*) URLWithBase: (NSString*) base name: (NSString*) name arguments: (NSDictionary*) arguments
{
	if (APIKey == nil)
	{
		return nil;
	}

	NSMutableArray* argstrings = [NSMutableArray array];

	for (NSString* key in arguments)
	{
		NSString* keyesc = [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		NSString* valesc = [[arguments objectForKey: key] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		[argstrings addObject: [NSString stringWithFormat: @"%@=%@", keyesc, valesc, nil]];
	}
	
	NSString* APIKeyEsc = [APIKey stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[argstrings addObject: [NSString stringWithFormat: @"key=%@", APIKeyEsc, nil]];
	
	if ([base isEqual: OTC_CUSTOMURL])
	{
		[argstrings addObject: [NSString stringWithFormat: @"dbversion=%s", OT_DB_VERSION]];
		[argstrings addObject: [NSString stringWithFormat: @"dbdate=%@", [self databaseVersion]]];
#ifdef OSU_BUS_VERSION
		[argstrings addObject: [NSString stringWithFormat: @"version=%s", OSU_BUS_VERSION]];
#endif
	}

	NSString* url = [NSString stringWithFormat: @"%@%@?%@", base, name, [argstrings componentsJoinedByString: @"&"], nil];
	
	return [NSURL URLWithString: url];
}

- (NSURL*) URLWithName: (NSString*) name arguments: (NSDictionary*) arguments
{
	return [self URLWithBase: OTC_BASEURL name: name arguments: arguments];
}

- (NSURL*) customURLWithName: (NSString*) name arguments: (NSDictionary*) arguments
{
	return [self URLWithBase: OTC_CUSTOMURL name: name arguments: arguments];
}

@end
