// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
// 
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

#define OTC_BASEURL @"http://trip.osu.edu/bustime/api/v1/"
#define OTC_CUSTOMURL @"http://gamma-level.com/osubus/"

#import "OTRequest.h"

@interface OTClient : NSObject
{
	NSString* APIKey;
	NSString* databasePath;
	
	// this is NOT auto-memmanaged, do it yerself!
	FMDatabase* db;
}

@property (nonatomic, copy) NSString* APIKey;

@end

@interface OTClient (OTClientSingleton)

+ (OTClient*) sharedClient;

@end

@interface OTClient (OTClientDatabase)

- (void) setDatabasePath: (NSString*) newDatabasePath;
- (NSString*) databasePath;
- (NSArray*) routes;
- (NSArray*) stops;
- (NSArray*) stopsWithRoute: (NSNumber*) routeid;
- (NSDictionary*) stop: (NSNumber*) stopid;
- (NSArray*) stopsNearLatitude: (double) lat longitude: (double) lon limit: (unsigned int) limit;
- (void) updateDatabase;

@end

@interface OTClient(OTClientRequests)

// these are NOT autoreleased, they're yours to take care of
- (OTRequest*) requestTimeWithDelegate: (id<OTRequestDelegate>) delegate;
- (OTRequest*) requestRoutesWithDelegate: (id<OTRequestDelegate>) delegate;
- (OTRequest*) requestDirectionsWithDelegate: (id<OTRequestDelegate>) delegate forRoute: (NSString*) rt;
- (OTRequest*) requestStopsWithDelegate: (id<OTRequestDelegate>) delegate forRoute: (NSString*) rt inDirection: (NSString*) dir;
- (OTRequest*) requestPatternsWithDelegate: (id<OTRequestDelegate>) delegate forRoute: (NSString*) rt;
- (OTRequest*) requestPatternsWithDelegate: (id<OTRequestDelegate>) delegate withPatternIDs: (NSString*) pid;
- (OTRequest*) requestVehiclesWithDelegate: (id<OTRequestDelegate>) delegate forRoutes: (NSString*) rt;
- (OTRequest*) requestVehiclesWithDelegate: (id<OTRequestDelegate>) delegate withVehicleIDs: (NSString*) vid;
- (OTRequest*) requestServiceBulletinsWithDelegate: (id<OTRequestDelegate>) delegate forRoutes: (NSString*) rt;
- (OTRequest*) requestServiceBulletinsWithDelegate: (id<OTRequestDelegate>) delegate forRoutes: (NSString*) rt inDirection: (NSString*) rtdir;
- (OTRequest*) requestServiceBulletinsWithDelegate: (id<OTRequestDelegate>) delegate forStopIDs: (NSString*) stpid;
- (OTRequest*) requestPredictionsWithDelegate: (id<OTRequestDelegate>) delegate forStopIDs: (NSString*) stpid count: (NSInteger) top;
- (OTRequest*) requestPredictionsWithDelegate: (id<OTRequestDelegate>) delegate forStopIDs: (NSString*) stpid onRoutes: (NSString*) rt count: (NSInteger) top;
- (OTRequest*) requestPredictionsWithDelegate: (id<OTRequestDelegate>) delegate forVehicleIDs: (NSString*) vid count: (NSInteger) top;

- (OTRequest*) requestCustomServiceBulletinsWithDelegate: (id<OTRequestDelegate>) delegate forRoutes: (NSString*) rt;
- (OTRequest*) requestCustomServiceBulletinsWithDelegate: (id<OTRequestDelegate>) delegate forRoutes: (NSString*) rt inDirection: (NSString*) rtdir;
- (OTRequest*) requestCustomServiceBulletinsWithDelegate: (id<OTRequestDelegate>) delegate forStopIDs: (NSString*) stpid;

- (NSURL*) URLWithBase: (NSString*) base name: (NSString*) name arguments: (NSDictionary*) arguments;
- (NSURL*) URLWithName: (NSString*) name arguments: (NSDictionary*) arguments;
- (NSURL*) customURLWithName: (NSString*) name arguments: (NSDictionary*) arguments;

@end
