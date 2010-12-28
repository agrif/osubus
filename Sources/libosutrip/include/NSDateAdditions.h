// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import <Foundation/Foundation.h>

@interface NSDate (OTNSDateAdditions)

// first one auto-corrects with last sync date, last one lets you set the sync date
+ (NSDate*) dateWithTRIPString: (NSString*) text;
+ (NSDate*) dateWithTRIPString: (NSString*) text useToSynchronize: (BOOL) sync;

@end
