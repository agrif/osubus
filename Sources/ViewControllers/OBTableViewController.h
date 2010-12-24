// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

@interface OBTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView* _tableView;
	UITableViewCell* newCell;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell* newCell;

- (UITableViewCell*) cellForTable: (UITableView*) tableView withIdentifier: (NSString*) cellIdentifier;
- (UITableViewCell*) cellForTable: (UITableView*) tableView withText: (NSString*) text;
- (UITableViewCell*) routesCellForTable: (UITableView*) tableView withData: (NSDictionary*) data;
- (UITableViewCell*) stopsCellForTable: (UITableView*) tableView withData: (NSDictionary*) data;
- (UITableViewCell*) predictionsCellForTable: (UITableView*) tableView withData: (NSDictionary*) data;

@end