// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

#import "OBTableViewController.h"

@class OBBulletinsViewController;

enum OBTopOptions
{
	OBTO_STOPS,
	OBTO_ROUTES,
	OBTO_NEARME,
	OBTO_COUNT,
	OBTO_MAP, // Maybe later...
};

enum OBTopSections
{
	OBTS_BULLETINS,
	OBTS_NAVIGATION,
	OBTS_FAVORITES,
	OBTS_COUNT
};

@interface OBTopViewController : OBTableViewController
{
	UITabBarController* aboutViewController;
	UITableViewCell* bulletinCell;
	UITableViewCell* emptyFavoritesCell;
	
	UIBarButtonItem* aboutButton;
	UIBarButtonItem* editButton;
	UIBarButtonItem* doneButton;
	UIBarButtonItem* backButton;
	
	NSInteger bulletinID;
	BOOL bulletinsLoaded;
	
	NSMutableArray* favorites;
	BOOL editMode;
	
	OBBulletinsViewController* bulletinsViewController;
}

@property (nonatomic, retain) IBOutlet UIViewController* aboutViewController;
@property (nonatomic, retain) IBOutlet UITableViewCell* bulletinCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* emptyFavoritesCell;

@property (nonatomic, retain) IBOutlet UIBarButtonItem* aboutButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* editButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* doneButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* backButton;

@property (nonatomic, retain) IBOutlet OBBulletinsViewController* bulletinsViewController;

- (UITableViewCell*) tableView: (UITableView*) tableView navigationCellForIndex: (NSInteger) index;

- (void) startBulletinDisplay;
- (void) updateBulletinCell: (NSTimer*) timer;
- (void) saveFavorites;

- (IBAction) showAboutView: (id) sender;
- (IBAction) dismissAboutView: (id) sender;

- (IBAction) beginEdit: (id) sender;
- (IBAction) endEdit: (id) sender;

@end
