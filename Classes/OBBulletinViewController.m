// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBBulletinViewController.h"

@implementation OBBulletinViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	if (bulletin)
	{
		//[self.navigationItem setTitle: [bulletin objectForKey: @"title"]];
		
		// tag 1 - title
		// tag 2 - source
		// tag 3 - body
		UILabel* label;
		
		label = (UILabel*)[[self view] viewWithTag: 1];
		[label setText: [bulletin objectForKey: @"title"]];
		
		label = (UILabel*)[[self view] viewWithTag: 2];
		if ([[bulletin objectForKey: @"source"] isEqual: @"official"])
		{
			[label setText: @"Service Bulletin"];
		} else if ([[bulletin objectForKey: @"source"] isEqual: @"custom"]) {
			[label setText: @"Application News"];
		}
		
		UIWebView* body = (UIWebView*)[[self view] viewWithTag: 3];
		[body loadHTMLString: [bulletin objectForKey: @"body"] baseURL: nil];
	}
	NSLog(@"OBBulletinViewController loaded");
}

- (void) viewDidUnload
{
	if (bulletin)
		[bulletin release];
	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return YES;
}

- (void) setBulletin: (NSDictionary*) data
{
	if (bulletin == nil)
		bulletin = [data retain];
}

@end
