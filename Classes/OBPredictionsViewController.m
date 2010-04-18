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
	
	predictions = nil;
	[[OTClient sharedClient] requestPredictionsWithDelegate: self forStopIDs: [NSString stringWithFormat: @"%@", [stop objectForKey: @"id"]] count: 5];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	if (predictions != nil)
		[predictions release];
	if (stop != nil)
		[stop release];
}

- (void) setStop: (NSDictionary*) stopin
{
	if (stop == nil)
		stop = [stopin retain];
}

#pragma mark Request Delegates

- (void) request: (OTRequest*) request hasResult: (NSDictionary*) result
{
	predictions = [[result objectForKey: @"prd"] retain];
	NSRange range;
	range.location = 0;
	range.length = 1;
	[self.tableView reloadSections: [NSIndexSet indexSetWithIndexesInRange: range] withRowAnimation: UITableViewRowAnimationBottom];
	[request release];
}

- (void) request: (OTRequest*) request hasError: (NSError*) error
{
	NSLog(@"error: %@", error);
}

#pragma mark Table View Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView;
{
	return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	if (predictions == nil)
		return 0;
	return [predictions count];
}

- (NSString*) tableView: (UITableView*) tableView titleForHeaderInSection: (NSInteger) section
{
	return nil;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath;
{
	if (predictions == nil)
		return nil;
	return [self predictionsCellForTable: tableView withData: [predictions objectAtIndex: [indexPath row]]];
}

#pragma mark Table View Delegate

- (NSIndexPath*) tableView: (UITableView*) tableView willSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	return nil;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	// navigation logic
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

@end
