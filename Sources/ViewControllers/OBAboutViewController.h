// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

@class OBTopViewController;

enum OBAboutCells
{
	OBAC_CONTACT_START,
	OBAC_EMAIL,
	OBAC_WEBSITE,
	OBAC_CONTACT_END,
	
	OBAC_SOURCE_START,
	OBAC_SOURCE,
	OBAC_SOURCE_END,
	
	OBAC_DONATE_START,
	OBAC_DONATE,
	OBAC_DONATE_END,
};

enum OBAboutSections
{
	OBAS_DONATE,
	OBAS_CONTACT,
	OBAS_SOURCE,
	
	OBAS_COUNT
};

@interface OBAboutViewController : UITabBarController <UITableViewDelegate, UITableViewDataSource>
{
	NSArray* tabs;
	UILabel* versionLabel;
	UITextView* licenseTextView;
	NSMutableArray* headers;
	UITableView* tableView;
	UIView* headerView;
}

@property (nonatomic, retain) IBOutletCollection(UIViewController) NSArray* tabs;
@property (nonatomic, retain) IBOutlet UILabel* versionLabel;
@property (nonatomic, retain) IBOutlet UITextView* licenseTextView;
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIView* headerView;

- (IBAction) hideAboutView: (id) button;

- (void) showWebsite;
- (void) showEmail;
- (void) showSource;
- (void) showDonate;

@end
