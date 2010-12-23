// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "OBTableViewController.h"

#define GPS_ACCURACY 100 /* meters */
#define GPS_MAX_WAIT 10 /* seconds */

@class OBBulletinsViewController;
@class MBProgressHUD;
@class OBAboutViewController;

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

@interface OBTopViewController : OBTableViewController <CLLocationManagerDelegate, UIActionSheetDelegate>
{
	OBAboutViewController* aboutViewController;
	UITableViewCell* bulletinCell;
	UITableViewCell* emptyFavoritesCell;
	
	UIBarButtonItem* aboutButton;
	UIBarButtonItem* editButton;
	UIBarButtonItem* doneButton;
	UIBarButtonItem* backButton;
	
	NSInteger bulletinID;
	BOOL bulletinsLoaded;
	
	NSMutableArray* favorites;
	NSMutableArray* favoritesData;
	BOOL editMode;
	
	CLLocationManager* locManager;
	NSDate* gpsStartDate;
	MBProgressHUD* hud;
	
	NSMutableData* receivedData;
	
	OBBulletinsViewController* bulletinsViewController;
}

@property (nonatomic, retain) IBOutlet OBAboutViewController* aboutViewController;
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

- (void) locationTimeout;

- (IBAction) showAboutView: (id) sender;

- (IBAction) beginEdit: (id) sender;
- (IBAction) endEdit: (id) sender;

@end
