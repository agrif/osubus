// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBRoutesViewController.h"

@implementation OBRoutesViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	//[aboutViewController setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
	
	[self.navigationItem setTitle: @""];
	[self.navigationItem setBackBarButtonItem: backButton];
	[self.navigationItem setRightBarButtonItem: aboutButton];
	
	[(UILabel*)[bulletinCell viewWithTag: 1] setText: @""];
	[(UILabel*)[bulletinCell viewWithTag: 2] setText: @"Loading..."];
	
	bulletinID = -1;
	bulletinsLoaded = NO;
	[bulletinsViewController loadBulletins: self];
}

#pragma mark Table View Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView;
{
	return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	return 0;
}

- (NSString*) tableView: (UITableView*) tableView titleForHeaderInSection: (NSInteger) section
{
	return nil;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath;
{
	return nil;
}

- (UITableViewCell*) tableView: (UITableView*) tableView navigationCellForIndex: (NSInteger) index
{
	NSString* cellIdentifier = @"UITableViewCell";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier] autorelease];
	}
	
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	
	switch (index)
	{
		case OBTO_STOPS:
			[[cell textLabel] setText: @"Stops"];
			break;
		case OBTO_ROUTES:
			[[cell textLabel] setText: @"Routes"];
			break;
		case OBTO_NEARME:
			[[cell textLabel] setText: @"Near Me"];
			break;
		case OBTO_MAP:
			[[cell textLabel] setText: @"Bus Map"];
			break;
	};
	
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
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

@end
