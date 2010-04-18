// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBPredictionsViewController.h"

#import "OTClient.h"

@implementation OBPredictionsViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	if (stop != nil)
	{
		NSLog(@"Loaded OBPredictionsViewController");
		
		[self.navigationItem setTitle: [stop objectForKey: @"name"]];
	} else {
		// do something else, mainly, fail spectacularly!
	}
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	if (stop != nil)
		[stop release];
}

- (void) setStop: (NSDictionary*) stopin
{
	if (stop == nil)
		stop = [stopin retain];
}

#pragma mark Table View Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView;
{
	return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	return [stop count];
}

- (NSString*) tableView: (UITableView*) tableView titleForHeaderInSection: (NSInteger) section
{
	return nil;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath;
{	
	return [self predictionsCellForTable: tableView withData: nil];
}

#pragma mark Table View Delegate

- (NSIndexPath*) tableView: (UITableView*) tableView willSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	return indexPath;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	// navigation logic
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

@end
