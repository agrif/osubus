// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>
#import "OBInfoTableView.h"

@class OBTopViewController;

@interface OBAboutViewController : UITabBarController <OBInfoTableViewDelegate>
{
	NSArray* tabs;
	UILabel* versionLabel;
	UITextView* licenseTextView;
	OBInfoTableView* tableView;
	UIView* headerView;
}

@property (nonatomic, retain) IBOutletCollection(UIViewController) NSArray* tabs;
@property (nonatomic, retain) IBOutlet UILabel* versionLabel;
@property (nonatomic, retain) IBOutlet UITextView* licenseTextView;
@property (nonatomic, retain) IBOutlet OBInfoTableView* tableView;
@property (nonatomic, retain) IBOutlet UIView* headerView;

- (IBAction) hideAboutView: (id) button;

- (void) showWebsite;
- (void) showEmail;
- (void) showSource;
- (void) showDonate;

@end
