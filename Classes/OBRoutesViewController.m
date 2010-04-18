// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBRoutesViewController.h"

#import "OTClient.h"

#import "OBStopsViewController.h"

@implementation OBRoutesViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	routes = [[OTClient sharedClient] routes];
	NSLog(@"Loaded OBRoutesViewController");
	
	[self.navigationItem setTitle: @"Routes"];
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
	return [self routesCellForTable: tableView withData: [routes objectAtIndex: [indexPath row]]];
}

#pragma mark Table View Delegate

- (NSIndexPath*) tableView: (UITableView*) tableView willSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	return indexPath;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	// navigation logic
	
	OBStopsViewController* stops = [[OBStopsViewController alloc] initWithNibName: @"OBStopsViewController" bundle: nil];
	[stops setRoute: [[routes objectAtIndex: [indexPath row]] objectForKey: @"id"]];
	[self.navigationController pushViewController: stops animated: YES];
	[stops release];
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

@end
