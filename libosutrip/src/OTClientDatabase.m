// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTClient.h"

#import "OTClientUpdateDatabase.h"

NSMutableDictionary* createStopDict(FMResultSet* rs, NSArray* routedata, NSNumber* routeid)
{
	NSMutableDictionary* add = [[NSMutableDictionary alloc] init];
	
	NSNumber* sid = [[NSNumber alloc] initWithInt: [rs intForColumn: @"stpid"]];
	[add setValue: sid forKey:	@"id"];
	[sid release];
	
	[add setValue: [rs stringForColumn: @"pretty"] forKey: @"name"];
	
	NSMutableArray* routeadd = [[NSMutableArray alloc] init];
	unsigned int routes = [rs intForColumn: @"routes"];
	for (NSDictionary* routeobj in routedata)
	{
		if ((1 << [[routeobj objectForKey: @"id"] integerValue]) & routes)
		{
			if ([routeobj objectForKey: @"id"] == routeid)
			{
				[routeadd insertObject: routeobj atIndex: 0];
			} else {
				[routeadd addObject: routeobj];
			}
		}
	}
	
	[add setValue: routeadd forKey: @"routes"];
	[routeadd release];
	
	return add;
}

#define EARTH_RADIUS 6371000 /* in meters */

void lat_lon_distance(sqlite3_context* context, int argc, sqlite3_value** argv)
{
	if (argc != 4)
	{
		sqlite3_result_double(context, 0.0);
		return;
	}
	
	double lat1 = sqlite3_value_double(argv[0]);
	double lon1 = sqlite3_value_double(argv[1]);
	double lat2 = sqlite3_value_double(argv[2]);
	double lon2 = sqlite3_value_double(argv[3]);
	
	// of course these are in degrees (2pi rad / 360 degrees)
	// so make them radians
	lat1 *= M_PI / 180.0;
	lon1 *= M_PI / 180.0;
	lat2 *= M_PI / 180.0;
	lon2 *= M_PI / 180.0;
	
	double dlat = lat2 - lat1;
	double dlon = lon2 - lon1;
	
	// a = sin²(Δlat/2) + cos(lat1).cos(lat2).sin²(Δlong/2)
	// c = 2.atan2(√a, √(1−a))
	// d = R.c
	
	double a = pow(sin(dlat/2.0), 2) + cos(lat1)*cos(lat2)*pow(sin(dlon/2.0), 2);
	sqlite3_result_double(context, EARTH_RADIUS * 2 * atan2(pow(a, 0.5), pow(1.0 - a, 0.5)));
}

@implementation OTClient (OTClientDatabase)

- (void) setDatabasePath: (NSString*) newDatabasePath
{
	if (newDatabasePath == nil)
	{
		if (databasePath)
			[databasePath release];
		databasePath = nil;
		if (db)
			[db close];
		db = nil;
		return;
	}
	
	FMDatabase* newdb = [FMDatabase databaseWithPath: newDatabasePath];
	if (![newdb open])
	{
		NSLog(@"Could not open db.");
		return;
	}
	
	databasePath = [newDatabasePath copy];
	db = newdb;
	
	sqlite3_create_function([db sqliteHandle], "distance", 4, SQLITE_ANY, NULL, &lat_lon_distance, NULL, NULL);
}

- (NSString*) databasePath
{
	return databasePath;
}

- (NSArray*) routes
{
	NSMutableArray* ret = [[NSMutableArray alloc] init];
	FMResultSet* rs = [db executeQuery: @"SELECT routes.rowid, routes.rt, route_colors.color, pretty_names.pretty FROM routes, route_colors, pretty_names WHERE routes.rt == route_colors.rt AND routes.rtnm == pretty_names.rowid ORDER BY routes.rt ASC"];
	
	while ([rs next])
	{
		NSNumber* rid = [[NSNumber alloc] initWithInt: [rs intForColumn: @"rowid"]];
		NSDictionary* add = [[NSDictionary alloc] initWithObjectsAndKeys: [rs stringForColumn: @"rt"], @"short", [rs stringForColumn: @"pretty"], @"long", [rs stringForColumn: @"color"], @"color", rid, @"id", nil]; 
		[ret addObject: add];
		[add release];
		[rid release];
	}
	[rs close];
	
	return ret;
}

- (NSDictionary*) stop: (NSNumber*) stopid
{
	NSDictionary* ret = nil;
	FMResultSet* rs;
	
	rs = [db executeQuery: @"SELECT pretty_names.pretty, stops.routes, stops.stpid FROM stops, pretty_names WHERE pretty_names.rowid == stops.stpnm AND stops.stpid == ? ORDER BY pretty_names.pretty ASC", stopid];
	
	NSArray* routedata = [self routes];
	
	while ([rs next] && ret == nil)
	{
		ret = createStopDict(rs, routedata, nil);
	}
	[rs close];
	
	[routedata release];
	
	return ret;
}

- (NSArray*) stopsNearLatitude: (double) lat longitude: (double) lon limit: (unsigned int) limit
{
	NSMutableArray* ret = [[NSMutableArray alloc] init];
	FMResultSet* rs;
	
	rs = [db executeQuery: @"SELECT pretty_names.pretty, stops.routes, stops.stpid, distance(?, ?, stops.lat, stops.lon) AS dist FROM stops, pretty_names WHERE pretty_names.rowid == stops.stpnm ORDER BY dist ASC LIMIT ?", [NSNumber numberWithDouble: lat], [NSNumber numberWithDouble: lon], [NSNumber numberWithInteger: limit]];
	
	NSArray* routedata = [self routes];
	
	while ([rs next])
	{
		NSMutableDictionary* add = createStopDict(rs, routedata, nil);
		[add setObject: [NSNumber numberWithDouble: [rs doubleForColumn: @"dist"]] forKey: @"dist"];
		
		[ret addObject: add];
		[add release];
	}
	[rs close];
	
	[routedata release];
	
	return ret;
}

- (NSArray*) stops
{
	return [self stopsWithRoute: nil];
}

- (NSArray*) stopsWithRoute: (NSNumber*) routeid
{
	NSMutableArray* ret = [[NSMutableArray alloc] init];
	FMResultSet* rs;
	
	if (routeid == nil)
	{
		rs = [db executeQuery: @"SELECT pretty_names.pretty, stops.routes, stops.stpid FROM stops, pretty_names WHERE pretty_names.rowid == stops.stpnm ORDER BY pretty_names.pretty ASC"];
	} else {
		rs = [db executeQuery: @"SELECT pretty_names.pretty, stops.routes, stops.stpid FROM stops, pretty_names WHERE pretty_names.rowid == stops.stpnm AND stops.routes & (1 << ?) ORDER BY pretty_names.pretty ASC", routeid];
	}
	
	NSArray* routedata = [self routes];
	
	while ([rs next])
	{
		NSDictionary* add = createStopDict(rs, routedata, routeid);
		
		[ret addObject: add];
		[add release];
	}
	[rs close];
	
	[routedata release];
	
	return ret;
}

- (NSString*) databaseVersion
{
	// in this case, version means generation date, not db interface version (OT_DB_VERSION)
	FMResultSet* rs = [db executeQuery: @"SELECT value FROM meta WHERE name == ?", @"date"];
	while ([rs next])
	{
		NSString* ret = [rs stringForColumn: @"value"];
		[rs close];
		return ret;
	}
	
	[rs close];
	return nil;
}

// haha! this is to update the local cache of route data!

- (void) updateDatabase;
{	
	initializeDB(db);
	addRoutes(db);
}

@end
