// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBStopsViewController.h"

#import "OTClient.h"

@implementation OBStopsViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	stops = [[OTClient sharedClient] routes];
	NSLog(@"Loaded OBStopsViewController");
	
	[self.navigationItem setTitle: @"Stops"];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	[stops release];
}

#pragma mark Table View Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView;
{
	return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	return [stops count];
}

- (NSString*) tableView: (UITableView*) tableView titleForHeaderInSection: (NSInteger) section
{
	return nil;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath;
{	
	return [self stopsCellForTable: tableView withData: [stops objectAtIndex: [indexPath row]]];
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
