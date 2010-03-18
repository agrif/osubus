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

// haha! this is to update the local cache of route data!

- (void) updateDatabase;
{	
	initializeDB(db);
	addRoutes(db);
}

@end
