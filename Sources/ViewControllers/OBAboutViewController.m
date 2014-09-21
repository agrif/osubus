// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBAboutViewController.h"

#import "OBInsetLabel.h"
#import "OTClient.h"
#import "OBTopViewController.h"

@implementation OBAboutViewController

@synthesize tabs, versionLabel, licenseTextView, headerView, tableView;

// called from background thread to set the text
- (void) setLicenseText: (NSString*) text
{
	[licenseTextView setText: text];
}

// done in the background, to load text
- (void) loadLicenses
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString* txtpath = [[NSBundle mainBundle] pathForResource: @"Licenses" ofType: @"txt"];
	NSString* text = [NSString stringWithContentsOfFile: txtpath encoding: NSUTF8StringEncoding error: nil];
	
	[self performSelectorOnMainThread: @selector(setLicenseText:) withObject: text waitUntilDone: YES];
	
	[pool release];
}

- (void) loadView
{
	// do a little dance, since apparently UITabBarControllers don't like being loaded with nibs
	[[NSBundle mainBundle] loadNibNamed: @"OBAboutViewController" owner: self options: nil];
	[super loadView];
	
	tableView.tableHeaderView = headerView;
	[tableView loadContentsOfURL: [[NSBundle mainBundle] URLForResource: @"About" withExtension: @"xml"]];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	[self setViewControllers: tabs animated: NO];
	[self setSelectedIndex: 0];
	
	NSString* db_ver = [[OTClient sharedClient] databaseVersion];
	[versionLabel setText: [NSString stringWithFormat: @"Version: %s | Database: %@", OSU_BUS_VERSION, db_ver]];
	
	[self performSelectorInBackground: @selector(loadLicenses) withObject: nil];
	
	NSLog(@"OBAboutViewController loaded");
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return YES;
}

- (IBAction) hideAboutView: (id) button
{
	[self.presentingViewController dismissModalViewControllerAnimated: YES];
}

- (void) infoTableView: (OBInfoTableView*) itv didSelectAction: (NSString*) action
{
	if ([action isEqual: @"website"])
	{
		[self showWebsite];
	} else if ([action isEqual: @"email"]) {
		[self showEmail];
	} else if ([action isEqual: @"source"]) {
		[self showSource];
	} else if ([action isEqual: @"donate"]) {
		[self showDonate];
	} else {
		NSLog(@"unhandled info table action: %@\n", action);
	}
}

- (void) showWebsite
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://osubus.rakeri.net/"]];
}

- (void) showEmail
{
	NSString* db_ver = [[OTClient sharedClient] databaseVersion];
	NSString* url = [NSString stringWithFormat: @"mailto:?to=griffith.637@osu.edu&subject=[OSU%%20Bus%%20%s-%@]%%20", OSU_BUS_VERSION, db_ver];
	
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (void) showSource
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://github.com/agrif/osubus/"]];
}

- (void) showDonate
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://osubus.rakeri.net/donate"]];
}

@end
