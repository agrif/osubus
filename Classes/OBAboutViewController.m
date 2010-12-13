// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBAboutViewController.h"

#import "OTClient.h"
#import "OBTopViewController.h"

@implementation OBAboutViewController

@synthesize tabBarController, versionLabel, licenseTextView;

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.view = tabBarController.view;
	
	NSString* db_ver = [[OTClient sharedClient] databaseVersion];
	[versionLabel setText: [NSString stringWithFormat: @"Version: %s | Database: %@", OSU_BUS_VERSION, db_ver]];
	
	NSString* txtpath = [[NSBundle mainBundle] pathForResource: @"Licenses" ofType: @"txt"];
	[licenseTextView setText: [NSString stringWithContentsOfFile: txtpath]];
	
	NSLog(@"OBAboutViewController loaded");
}

- (void) viewDidUnload
{
	//self.view = nil;
	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return YES;
}

- (IBAction) hideAboutView: (id) button
{
	[self.parentViewController dismissModalViewControllerAnimated: YES];
}

- (IBAction) showWebsite
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://osubus.gamma-level.com/"]];
}

- (IBAction) showEmail
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"mailto:?to=aargri@gmail.com&subject=[OSU+Bus]+"]];
}

- (IBAction) showSource
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://github.com/agrif/osubus/"]];
}

- (IBAction) showDonate
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://gamma-level.com/donate"]];
}

@end