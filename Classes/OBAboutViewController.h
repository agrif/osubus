// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

@class OBTopViewController;

@interface OBAboutViewController : UIViewController
{
	UITabBarController* tabBarController;
	UILabel* versionLabel;
	UITextView* licenseTextView;
}

@property (nonatomic, retain) IBOutlet UITabBarController* tabBarController;
@property (nonatomic, retain) IBOutlet UILabel* versionLabel;
@property (nonatomic, retain) IBOutlet UITextView* licenseTextView;

- (IBAction) hideAboutView: (id) button;

@end
