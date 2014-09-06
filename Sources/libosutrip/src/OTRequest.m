// libosutrip - a client library for the OSU bus system
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "OTClient.h" for details.

#import "OTRequest.h"
#import "OTClient.h"

@implementation OTRequest

@synthesize result;
@synthesize error;

- (id) initWithName: (NSString*) name arguments: (NSDictionary*) arguments delegate: (NSObject<OTRequestDelegate>*) requestDelegate;
{
	if ([super init] == nil)
		return nil;
	
	if (requestDelegate)
		delegate = [requestDelegate retain];

	NSURL* url = [[OTClient sharedClient] URLWithName: name arguments: arguments];

	callingThread = [NSThread currentThread];
	
	thread = [[NSThread alloc] initWithTarget: self selector: @selector(parserThread:) object: url];
	[thread start];
	
	return self;
}

- (id) initCustomWithName: (NSString*) name arguments: (NSDictionary*) arguments delegate: (NSObject<OTRequestDelegate>*) requestDelegate;
{
	if ([super init] == nil)
		return nil;
	
	if (requestDelegate)
		delegate = [requestDelegate retain];
	
	NSURL* url = [[OTClient sharedClient] customURLWithName: name arguments: arguments];
	
	callingThread = [NSThread currentThread];
	
	thread = [[NSThread alloc] initWithTarget: self selector: @selector(parserThread:) object: url];
	[thread start];
	
	return self;
}

- (void) dealloc
{
	if (delegate)
		[(NSObject*)delegate release];
	if (thread)
		[thread release];
	if (result)
		[result release];
	if (error)
		[error release];
	[super dealloc];
}

// dummy copy method, lets us use requests as dictionary keys
// besides, requests are basically immutable
- (id) copyWithZone: (NSZone*) zone
{
	return [self retain];
}

- (BOOL) hasResult
{
	return [thread isFinished];
}

- (void) waitForResult
{
	while (![self hasResult]);
}

- (void) parserThread: (NSURL*) url
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	foundResponse = NO;
	foundError = NO;
	
	//NSLog(@"Opening url: %@", url, nil);
	NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL: url];
	
	[parser setDelegate: self];
	[parser setShouldProcessNamespaces: NO];
	[parser setShouldReportNamespacePrefixes: NO];
	[parser setShouldResolveExternalEntities: NO];
	
	[parser parse];

	[parser release];
	if (foundText)
		[foundText release];
	foundText = nil;

	if (error == nil)
		[self didEndDocument];
	
	if (delegate)
	{
		// this needs a run loop!
		[self performSelector: @selector(sendFinalDelegateMessage:) onThread: callingThread withObject: nil waitUntilDone: NO];
		// this doesn't
		//[self sendFinalDelegateMessage: nil];
	}	

	[pool release];
}

- (void) sendFinalDelegateMessage: (id) unused
{
	if (error)
	{
		[delegate request: self hasError: self.error];
	} else {
		[delegate request: self hasResult: self.result];
	}
}

- (void) parser: (NSXMLParser*) parser didStartElement: (NSString*) elementName namespaceURI: (NSString*) namespaceURI qualifiedName: (NSString*) qName attributes: (NSDictionary*) attributeDict
{
	if (foundResponse)
	{
		if (foundError)
		{
			// do nothing, it's not important anymore
			return;
		} else {
			// in response, no error found (yet)
			// but a tag is definately starting
			
			if (foundText)
				[foundText release];
			foundText = [[NSMutableString alloc] init];

			if ([elementName isEqual: @"error"])
			{
				foundError = YES;
				foundFirstErrorCode = NO;
				return;
			}
			
			[self didStartElement: elementName];
			return;
		}
	} else {
		// response not yet found
		if ([elementName isEqual: @"bustime-response"])
		{
			foundResponse = YES;
			return;
		} else {
			// malformed xml
			[parser abortParsing];
			[self sendInvalidResponseError];
			return;
		}
	}
}

- (void) parser: (NSXMLParser*) parser didEndElement: (NSString*) elementName namespaceURI: (NSString*) namespaceURI qualifiedName: (NSString*) qName
{
	if (!foundResponse)
	{
		// malformed xml
		[parser abortParsing];
		[self sendInvalidResponseError];
		return;
	}
	
	if ([elementName isEqual: @"bustime-response"])
	{
		// we found the end, start over?
		foundResponse = NO;
		return;
	}

	if (foundError && [elementName isEqual: @"error"])
	{
		// errorText complete
		[parser abortParsing];
		[self sendAPIError];
		return;
	}  else if (foundError) {
		return;
	} else {
		if (foundText != nil && [foundText length] == 0)
		{
			[foundText release];
			foundText = nil;
		}
		[self didEndElement: elementName withText: foundText];
		if (foundText)
			[foundText release];
		foundText = nil;
		return;
	}
}

- (void) parser: (NSXMLParser*) parser foundCharacters: (NSString*) string
{
	if (!foundResponse)
	{
		// malformed xml
		[parser abortParsing];
		[self sendInvalidResponseError];
	}
	
	if (foundText)
	{
		if (foundError)
		{
			// strip out extra whitespace for errors
			NSCharacterSet* whitespaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
			NSPredicate* noEmptyStrings = [NSPredicate predicateWithFormat: @"SELF != ''"];
			
			NSArray* parts = [string componentsSeparatedByCharactersInSet: whitespaces];
			parts = [parts filteredArrayUsingPredicate: noEmptyStrings];
			string = [parts componentsJoinedByString: @" "];
		}
		
		if ([string length] > 0)
		{
			// we need to skip the first part of an error -- it's a useless number!
			// (unless it's not, in the case of request cap exceeded)
			if (foundError && !foundFirstErrorCode && [string length] < 10)
			{
				foundFirstErrorCode = YES;
			} else {
				if (foundError && [foundText length] > 0)
					[foundText appendString: @" "];
				[foundText appendString: string];
			}
		}
	}
}

- (void) parser: (NSXMLParser*) parser parseErrorOccurred: (NSError*) parseError
{
	if ([parseError code] == NSXMLParserDelegateAbortedParseError)
	{
		// that's us, we did something else! ignore
		return;
	}
	
	// generic case first
	NSString* errstr = @"XML parse error.";
	
	switch ([parseError code])
	{
		// this is usually because the server could not be reached
		case NSXMLParserPrematureDocumentEndError:
			errstr = @"Could not connect to server.";
			break;
	};
	
	NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys: errstr, NSLocalizedDescriptionKey, parseError, NSUnderlyingErrorKey, nil];
	NSError* errorl = [NSError errorWithDomain: OTRequestErrorDomain code: OTRequestParseError userInfo: info];
	
	self.error = errorl;
	[self didEncounterError: errorl];
}


- (void) sendInvalidResponseError
{
	// error on unexpected formed response
	NSString* errstr = @"Invalid Response from Server";
	NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys: errstr, NSLocalizedDescriptionKey, nil];
	NSError* errorl = [NSError errorWithDomain: OTRequestErrorDomain code: OTRequestInvalidResponseError userInfo: info];

	self.error = errorl;
	[self didEncounterError: errorl];
}

- (void) sendAPIError
{
	// error from <error> tag
	NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys: foundText, NSLocalizedDescriptionKey, nil];
	NSError* errorl = [NSError errorWithDomain: OTRequestErrorDomain code: OTRequestAPIError userInfo: info];

	self.error = errorl;
	[self didEncounterError: errorl];
}

// dummy subclass'd methods

- (void) didStartElement: (NSString*) elementName
{
	//NSLog(@"start: %@", elementName, nil);
}

- (void) didEndElement: (NSString*) elementName withText: (NSString*) text
{
	//NSLog(@"end: %@ text: \"%@\"", elementName, text, nil);
}

- (void) didEncounterError: (NSError*) error
{
	//NSLog(@"error: %@", error, nil);
}

- (void) didEndDocument
{
	//NSLog(@"document end");
}

@end
