// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import <Foundation/Foundation.h>

#import "OTRequest.h"

@interface OTRPredictions : OTRequest
{
	NSMutableArray* construct;
	NSMutableDictionary* part;
}

- (id) initWithDelegate: (id<OTRequestDelegate>) del stpid: (NSString*) stpid rt: (NSString*) rt top: (NSInteger) top;
- (id) initWithDelegate: (id<OTRequestDelegate>) del vid: (NSString*) vid top: (NSInteger) top;

@end
