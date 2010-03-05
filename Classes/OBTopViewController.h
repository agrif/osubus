// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

@class OBBulletinsViewController;

enum OBTopOptions
{
	OBTO_STOPS,
	OBTO_ROUTES,
	OBTO_NEARME,
	OBTO_MAP,
	OBTO_COUNT
};

enum OBTopSections
{
	OBTS_BULLETINS,
	OBTS_NAVIGATION,
	OBTS_FAVORITES,
	OBTS_COUNT
};

@interface OBTopViewController : UITableViewController
{
	UIViewController* aboutViewController;
	UITableViewCell* bulletinCell;
	UITableViewCell* emptyFavoritesCell;
	
	UIBarButtonItem* aboutButton;
	UIBarButtonItem* backButton;
	
	NSInteger bulletinID;
	BOOL bulletinsLoaded;
	
	OBBulletinsViewController* bulletinsViewController;
}

@property (nonatomic, retain) IBOutlet UIViewController* aboutViewController;
@property (nonatomic, retain) IBOutlet UITableViewCell* bulletinCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* emptyFavoritesCell;

@property (nonatomic, retain) IBOutlet UIBarButtonItem* aboutButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* backButton;

@property (nonatomic, retain) IBOutlet OBBulletinsViewController* bulletinsViewController;

- (UITableViewCell*) tableView: (UITableView*) tableView navigationCellForIndex: (NSInteger) index;

- (void) startBulletinDisplay;
- (void) updateBulletinCell: (NSTimer*) timer;

- (IBAction) showAboutView: (id) sender;
- (IBAction) dismissAboutView: (id) sender;

@end
