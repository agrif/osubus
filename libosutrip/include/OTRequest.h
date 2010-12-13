// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import <Foundation/Foundation.h>

#define OTRequestErrorDomain @"OTRequestErrorDomain"
#define OTRequestParseError 1
#define OTRequestInvalidResponseError 2
#define OTRequestAPIError 3

@class OTRequest;

@protocol OTRequestDelegate

- (void) request: (OTRequest*) request hasResult: (NSDictionary*) result;
- (void) request: (OTRequest*) request hasError: (NSError*) error;

@end

@interface OTRequest : NSObject
{
	BOOL foundResponse;
	BOOL foundError;
	BOOL foundFirstErrorCode;
	NSMutableString* foundText;
	NSThread* thread;
	NSThread* callingThread;

	id<OTRequestDelegate> delegate;
	NSDictionary* result;
	NSError* error;
}

// we want this atomic, if at all possible
@property (retain) NSDictionary* result;
@property (retain) NSError* error;

- (id) initWithName: (NSString*) name arguments: (NSDictionary*) arguments delegate: (id<OTRequestDelegate>) requestDelegate;
- (id) initCustomWithName: (NSString*) name arguments: (NSDictionary*) arguments delegate: (id<OTRequestDelegate>) requestDelegate;
- (BOOL) hasResult;

// hack
- (void) waitForResult;

// these next four are subclassable callbacks!
- (void) didStartElement: (NSString*) elementName;
- (void) didEndElement: (NSString*) elementName withText: (NSString*) text;
- (void) didEncounterError: (NSError*) error;
- (void) didEndDocument;

// for internal use ONLY!!
- (void) sendFinalDelegateMessage: (id) unused;
- (void) sendInvalidResponseError;
- (void) sendAPIError;

@end
