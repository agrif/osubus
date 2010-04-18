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
	
	routes = [[OTClient sharedClient] routes];
	NSLog(@"Loaded OBPredictionsViewController");
	
	[self.navigationItem setTitle: @"Predictions"];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	[routes release];
}

#pragma mark Table View Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView;
{
	return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	return [routes count];
}

- (NSString*) tableView: (UITableView*) tableView titleForHeaderInSection: (NSInteger) section
{
	return nil;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath;
{	
	return [self predictionsCellForTable: tableView withData: [routes objectAtIndex: [indexPath row]]];
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
