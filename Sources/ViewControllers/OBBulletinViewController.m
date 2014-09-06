// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010, 2011 Aaron Griffith
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
		[self.navigationItem setTitle: [bulletin objectForKey: @"title"]];
		
		UIWebView* body = (UIWebView*)[self view];
		NSString* templated = [[NSString alloc] initWithFormat: @"<html><body style=\"font-family: '%@', 'Arial', 'Serif'\">%@</body></html>", (OSU_BUS_NEW_UI ? @"HelveticaNeue" : @"Helvetica"), [bulletin objectForKey: @"body"]];
		[body loadHTMLString: templated baseURL: nil];
		[templated release];
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

- (BOOL) webView: (UIWebView*) webView shouldStartLoadWithRequest: (NSURLRequest*) request navigationType: (UIWebViewNavigationType) navType
{
	if (navType == UIWebViewNavigationTypeLinkClicked)
	{
		[[UIApplication sharedApplication] openURL: request.URL];
		return NO;
	}
	
	return YES;
}

@end
