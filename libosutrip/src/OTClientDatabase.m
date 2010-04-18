// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTClient.h"

#import "OTClientUpdateDatabase.h"

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
		NSDictionary* add = [[NSMutableDictionary alloc] init];
		
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
		
		[ret addObject: add];
		[add release];
	}
	[rs close];
	
	[routedata release];
	
	return ret;
}

// haha! this is to update the local cache of route data!

- (void) updateDatabase;
{	
	initializeDB(db);
	addRoutes(db);
}

@end
