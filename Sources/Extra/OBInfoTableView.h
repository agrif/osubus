// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// an info table view is a table view that will automatically manage
// sections of text blocks and cells that act like links, and will load
// these from an xml file.
//
// looks best with the grouped style

#import <UIKit/UIKit.h>

@class OBInfoTableView;

@protocol OBInfoTableViewDelegate
- (void) infoTableView: (OBInfoTableView*) itv didSelectAction: (NSString*) action;
@end

@interface OBInfoTableView : UITableView <UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate>
{
	NSObject<OBInfoTableViewDelegate>* infoTableViewDelegate;
	NSMutableArray* headers;
	NSMutableArray* sections;
	
	NSMutableDictionary* parse;
}

@property (nonatomic, assign) IBOutlet NSObject<OBInfoTableViewDelegate>* infoTableViewDelegate;

- (BOOL) loadContentsOfURL: (NSURL*) url;

@end
