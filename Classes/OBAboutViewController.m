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

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.view = tabBarController.view;
	
	NSString* db_ver = [[OTClient sharedClient] databaseVersion];
	[versionLabel setText: [NSString stringWithFormat: @"Version: %s | Database: %@", OSU_BUS_VERSION, db_ver]];
	
	[self performSelectorInBackground: @selector(loadLicenses) withObject: nil];
	
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
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://gamma-level.com/"]];
}

- (IBAction) showEmail
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"mailto:?to=griffith.637@osu.edu&subject=[OSU%20Bus]%20"]];
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
