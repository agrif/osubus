// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

// header for updateDatabase: ... helper functions

#import <Foundation/Foundation.h>

#import "FMDatabase.h"

#define OT_DB_VERSION "1"

void initializeDB(FMDatabase* db);
NSNumber* addPrettyName(FMDatabase* db, NSString* original);
NSNumber* addRouteColor(FMDatabase* db, NSString* rt);
void addStops(FMDatabase* db, long long routeID, NSString* rt, long long directionID, NSString* dir);
void addDirections(FMDatabase* db, long long routeID, NSString* rt);
void addRoutes(FMDatabase* db);

