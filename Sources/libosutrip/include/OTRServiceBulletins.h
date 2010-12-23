// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import <Foundation/Foundation.h>

#import "OTRequest.h"

@interface OTRServiceBulletins : OTRequest
{
	NSMutableArray* construct;
	NSMutableDictionary* part;
	NSMutableArray* subconstruct;
	NSMutableDictionary* subpart;
}

- (id) initWithDelegate: (id<OTRequestDelegate>) del rt: (NSString*) rt rtdir: (NSString*) rtdir;
- (id) initWithDelegate: (id<OTRequestDelegate>) del stpid: (NSString*) stpid;
- (id) initCustomWithDelegate: (id<OTRequestDelegate>) del rt: (NSString*) rt rtdir: (NSString*) rtdir;
- (id) initCustomWithDelegate: (id<OTRequestDelegate>) del stpid: (NSString*) stpid;

@end
