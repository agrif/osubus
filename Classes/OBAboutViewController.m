// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBAboutViewController.h"

#import "OTClient.h"
#import "OBTopViewController.h"

@implementation OBAboutViewController

@synthesize tabBarController;

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.view = tabBarController.view;
	
	// FIXME turn this tag horror into a set of properties
	// FIXME also make the buttons work
	
	// note that tag 1 is the "version info" label on the front page
	UILabel* info = (UILabel*)[[[[[tabBarController.viewControllers objectAtIndex: 0] viewControllers] objectAtIndex: 0] view] viewWithTag: 1];
	NSString* db_ver = [[OTClient sharedClient] databaseVersion];
	[info setText: [NSString stringWithFormat: @"Version: %s | Database: %@", OSU_BUS_VERSION, db_ver]];
	
	// tag 2 is the licenses text area on third page
	UITextView* license = (UITextView*)[[[[[tabBarController.viewControllers objectAtIndex: 2] viewControllers] objectAtIndex: 0] view] viewWithTag: 2];
	NSString* txtpath = [[NSBundle mainBundle] pathForResource: @"Licenses" ofType: @"txt"];
	if (txtpath)
	{
		[license setText: [NSString stringWithContentsOfFile: txtpath]];
	}
	
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

@end
