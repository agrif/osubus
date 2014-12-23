// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBRoutesViewController.h"

#import "OTClient.h"

#import "OBStopsViewController.h"

@implementation OBRoutesViewController

@synthesize routes, routesDelegate;

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
	self.routesDelegate = nil;
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
	NSDictionary* route = [routes objectAtIndex: [indexPath row]];
	UITableViewCell* cell = [self routesCellForTable: tableView withData: route];
	
	if (routesDelegate)
	{
		// modal view mode
		cell.accessoryType = UITableViewCellAccessoryNone;
		if ([routesDelegate isRouteEnabled: route])
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	return cell;
}

#pragma mark Table View Delegate

- (NSIndexPath*) tableView: (UITableView*) tableView willSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	return indexPath;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	// navigation logic
	
	if (routesDelegate)
	{
		NSDictionary* route = [routes objectAtIndex: [indexPath row]];
		[routesDelegate setRoute: route enabled: ![routesDelegate isRouteEnabled: route]];
		
		NSArray* indexPaths = [[NSArray alloc] initWithObjects: indexPath, nil];
		[tableView reloadRowsAtIndexPaths: indexPaths withRowAnimation: UITableViewRowAnimationFade];
		[indexPaths release];
	} else {
		OBStopsViewController* stops = [[OBStopsViewController alloc] initWithNibName: @"OBStopsViewController" bundle: nil];
		[stops setRoute: [routes objectAtIndex: [indexPath row]]];
		[self.navigationController pushViewController: stops animated: YES];
		[stops release];
	}
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

#pragma mark modal-style handling

- (void) presentModallyOn: (UIViewController*) controller withDelegate: (id<OBRoutesViewDelegate>) delegate
{
	self.routesDelegate = delegate;

	UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController: self];

	UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style:UIBarButtonItemStyleDone target: self action: @selector(dismissModal)];
	[self.navigationItem setRightBarButtonItem:barButton];
	[barButton release];

	[controller presentModalViewController: navController animated: YES];
	[navController release];
}

- (void) dismissModal
{
	[self.presentingViewController dismissModalViewControllerAnimated: YES];
}

@end
