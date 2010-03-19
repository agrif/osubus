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
	FMResultSet* rs = [db executeQuery: @"SELECT routes.rt, route_colors.color, pretty_names.pretty FROM routes, route_colors, pretty_names WHERE routes.rt == route_colors.rt AND routes.rtnm == pretty_names.rowid ORDER BY routes.rt ASC"];
	
	while ([rs next])
	{
		NSDictionary* add = [[NSDictionary alloc] initWithObjectsAndKeys: [rs stringForColumn: @"rt"], @"short", [rs stringForColumn: @"pretty"], @"long", [rs stringForColumn: @"color"], @"color", nil]; 
		[ret addObject: add];
		[add release];
	}
	[rs close];
	
	return ret;
}

// haha! this is to update the local cache of route data!

- (void) updateDatabase;
{	
	initializeDB(db);
	addRoutes(db);
}

@end
