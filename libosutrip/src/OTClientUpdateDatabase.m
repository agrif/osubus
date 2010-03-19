// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

// helper functions for [OTClient updateDatabase: ...]

#import "OTClient.h"
#import "OTClientUpdateDatabase.h"

#include <stdio.h>
#include <time.h>

// called after each request to the server
#define REQ_DELAY //sleep(1.0)
// called after every item processed
#define REQ_BREAK 

void initializeDB(FMDatabase* db)
{
	NSMutableDictionary* tables = [NSMutableDictionary dictionary];
	[tables setObject: @"(rt text, rtnm int)" forKey: @"routes"];
	[tables setObject: @"(route int, dir text, name int)" forKey: @"directions"];
	[tables setObject: @"(stpid int PRIMARY KEY, routes int, direction int, stpnm int, lat double, lon double)" forKey: @"stops"];

	[db beginTransaction];
	
	for (NSString* name in tables)
	{
		[db executeUpdate: [NSString stringWithFormat: @"DROP TABLE IF EXISTS %@", name]];
	}
	
	// hack for now, remove later
	//[db executeUpdate: @"DROP TABLE IF EXISTS pretty_names"];

	[db executeUpdate: @"CREATE TABLE IF NOT EXISTS pretty_names (original text, pretty text)"];
	[db executeUpdate: @"CREATE TABLE IF NOT EXISTS route_colors (rt text, color text)"];

	for (NSString* name in tables)
	{
		[db executeUpdate: [NSString stringWithFormat: @"CREATE TABLE  %@ %@", name, [tables objectForKey: name]]];
	}

	[db commit];
}


NSNumber* addRouteColor(FMDatabase* db, NSString* rt)
{
	FMResultSet* rs = [db executeQuery: @"SELECT rowid FROM route_colors WHERE rt == ?", rt];
	if ([rs next])
	{
		int ret = [rs intForColumn: @"rowid"];
		[rs close];
		return [NSNumber numberWithInt: ret];
	}
	[rs close];
	
	if ([db executeUpdate: @"INSERT INTO route_colors (rt, color) VALUES (?, ?)", rt, @"#000000"])
	{
		return [NSNumber numberWithInt: [db lastInsertRowId]];
	}
	
	return nil;
}

NSNumber* addPrettyName(FMDatabase* db, NSString* original)
{
	FMResultSet* rs = [db executeQuery: @"SELECT rowid FROM pretty_names WHERE original == ?", original];
	if ([rs next])
	{
		int ret = [rs intForColumn: @"rowid"];
		[rs close];
		return [NSNumber numberWithInt: ret];
	}
	[rs close];
	
	if ([db executeUpdate: @"INSERT INTO pretty_names (original, pretty) VALUES (?, ?)", original, original])
	{
		return [NSNumber numberWithInt: [db lastInsertRowId]];
	}
	
	return nil;
}

void addStops(FMDatabase* db, int routeID, NSString* rt, int directionID, NSString* dir)
{
	OTRequest* req = [[OTClient sharedClient] requestStopsWithDelegate: nil forRoute: rt inDirection: dir];
	[req waitForResult];
	if ([req error])
	{
		NSLog(@"error: %@", [req error]);
		exit(1);
	}
	
	NSArray* stops = [[req result] objectForKey: @"stop"];
	for (NSDictionary* stop in stops)
	{
		NSLog(@"Adding stop: %@", [stop objectForKey: @"stpnm"]);

		FMResultSet* rs = [db executeQuery: @"SELECT routes FROM stops WHERE stpid == ?", [stop objectForKey: @"stpid"]];
		
		if ([rs next])
		{
			int routes = [rs intForColumn: @"routes"];
			if (![db executeUpdate: @"UPDATE stops SET routes = ? WHERE stpid == ?", [NSNumber numberWithInt: routes | (1 << routeID)], [stop objectForKey: @"stpid"]])
			{
				NSLog(@"Error adding stop...");
				exit(1);
			}
		} else {
			if (![db executeUpdate: @"INSERT INTO stops (routes, direction, stpid, stpnm, lat, lon) VALUES (?, ?, ?, ?, ?, ?)", [NSNumber numberWithInt: 1 << routeID], [NSNumber numberWithInt: directionID], [stop objectForKey: @"stpid"], addPrettyName(db, [stop objectForKey: @"stpnm"]), [stop objectForKey: @"lat"], [stop objectForKey: @"lon"]])
			{
				NSLog(@"Error adding stop...");
				exit(1);
			}
		}

		[rs close];
		
		// hack
		// REQ_BREAK; // doesn't call subrequests; not needed
	}

	[req release];
	REQ_DELAY;
}

void addDirections(FMDatabase* db, int routeID, NSString* rt)
{
	OTRequest* req = [[OTClient sharedClient] requestDirectionsWithDelegate: nil forRoute: rt];
	[req waitForResult];
	if ([req error])
	{
		NSLog(@"error: %@", [req error]);
		exit(1);
	}

	NSArray* directions = [[req result] objectForKey: @"dir"];
	for (NSString* direction in directions)
	{
		NSLog(@"Adding direction: %@", direction);
		if ([db executeUpdate: @"INSERT INTO directions (route, dir, name) VALUES (?, ?, ?)", [NSNumber numberWithInt: routeID], direction, addPrettyName(db, direction)])
		{
			addStops(db, routeID, rt, [db lastInsertRowId], direction);
		} else {
			NSLog(@"Error adding direction...");
			exit(1);
		}

		// hack
		REQ_BREAK;
	}

	[req release];
	REQ_DELAY;
}

void addRoutes(FMDatabase* db)
{
	OTRequest* req = [[OTClient sharedClient] requestRoutesWithDelegate: nil];
	[req waitForResult];
	if ([req error])
	{
		NSLog(@"error: %@", [req error]);
		exit(1);
	}

	NSArray* routes = [[req result] objectForKey: @"route"];
	for (NSDictionary* route in routes)
	{
		NSLog(@"Adding route: %@", [route objectForKey: @"rtnm"]);
		if ([db executeUpdate: @"INSERT INTO routes (rt, rtnm) VALUES (?, ?)", [route objectForKey: @"rt"], addPrettyName(db, [route objectForKey: @"rtnm"])])
		{
			addRouteColor(db, [route objectForKey: @"rt"]);
			addDirections(db, [db lastInsertRowId], [route objectForKey: @"rt"]);
		} else {
			NSLog(@"Error adding route...");
			exit(1);
		}

		// hack
		REQ_BREAK;
	}

	[req release];
	// REQ_DELAY; // last one, not needed
}
