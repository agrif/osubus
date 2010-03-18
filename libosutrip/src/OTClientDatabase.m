// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTClient.h"

#import "OTClientUpdateDatabase.h"

@implementation OTClient (OTClientDatabase)

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
