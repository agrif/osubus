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

#import "OTClientUpdateDatabase.h"

@implementation OTClient

@synthesize APIKey;
@synthesize databasePath;

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

// haha! this is to update the local cache of route data!

- (void) updateDatabase;
{
	FMDatabase* db = [FMDatabase databaseWithPath: [OTClient sharedClient].databasePath];
	if (![db open])
	{
		NSLog(@"Could not open db.");
		exit(1); // hack
	}
	
	initializeDB(db);
	addRoutes(db);
	
	[db close];
}

@end
