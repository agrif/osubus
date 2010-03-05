// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

// header for updateDatabase: ... helper functions

#import <Foundation/Foundation.h>

#import "FMDatabase.h"

void initializeDB(FMDatabase* db);
NSNumber* addPrettyName(FMDatabase* db, NSString* original);
void addStops(FMDatabase* db, int routeID, NSString* rt, int directionID, NSString* dir);
void addDirections(FMDatabase* db, int routeID, NSString* rt);
void addRoutes(FMDatabase* db);

