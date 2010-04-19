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
	
	if (stop != nil)
	{
		NSLog(@"Loaded OBPredictionsViewController");
		
		[self.navigationItem setTitle: [stop objectForKey: @"name"]];
	} else {
		// do something else, mainly, fail spectacularly!
	}
	
	predictions = nil;
	error_cell_text = nil;
	[self updateTimes: nil];
	[NSTimer scheduledTimerWithTimeInterval: 30.0 target: self selector: @selector(updateTimes:) userInfo: nil repeats: YES];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	if (predictions != nil)
		[predictions release];
	if (stop != nil)
		[stop release];
	if (routes != nil)
		[routes release];
	if (error_cell_text != nil)
		[error_cell_text release];
}

- (void) setStop: (NSDictionary*) stopin
{
	if (stop == nil)
		stop = [stopin retain];
}

- (void) updateTimes: (NSTimer*) timer
{
	[[OTClient sharedClient] requestPredictionsWithDelegate: self forStopIDs: [NSString stringWithFormat: @"%@", [stop objectForKey: @"id"]] count: 5];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
}

#pragma mark Request Delegates

- (void) request: (OTRequest*) request hasResult: (NSDictionary*) result
{
	if (predictions)
		[predictions release];
	predictions = [[result objectForKey: @"prd"] retain];
	if (error_cell_text)
		[error_cell_text release];
	error_cell_text = nil;
	
	for (NSMutableDictionary* prediction in predictions)
	{
		for (NSDictionary* route in routes)
		{
			if ([[route objectForKey: @"short"] isEqual: [prediction objectForKey: @"rt"]])
			{
				[prediction setObject: [route objectForKey: @"long"] forKey: @"rt"];
				break;
			}
		}
	}
	
	NSRange range;
	range.location = 0;
	range.length = 1;
	[self.tableView reloadSections: [NSIndexSet indexSetWithIndexesInRange: range] withRowAnimation: UITableViewRowAnimationFade];
	[request release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

- (void) request: (OTRequest*) request hasError: (NSError*) error
{
	NSLog(@"error: %@", error);
	if (error_cell_text)
		[error_cell_text release];
	if (predictions)
		[predictions release];
	predictions = nil;
	// FIXME - a better error message system!
	//error_cell_text = [[error localizedDescription] copy];
	error_cell_text = [[NSString alloc] initWithString: @"No upcoming arrivals."];
	NSRange range;
	range.location = 0;
	range.length = 1;
	[self.tableView reloadSections: [NSIndexSet indexSetWithIndexesInRange: range] withRowAnimation: UITableViewRowAnimationFade];
	[request release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

#pragma mark Table View Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView;
{
	return OBPS_COUNT;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	switch (section)
	{
		case OBPS_PREDICTIONS:
			if (predictions == nil)
				return 1;
			return [predictions count];
		case OBPS_ACTIONS:
			return OBPA_COUNT;
	};
	
	return 0;
}

- (NSString*) tableView: (UITableView*) tableView titleForHeaderInSection: (NSInteger) section
{
	switch (section)
	{
		case OBPS_PREDICTIONS:
			return @"Next Arrivals";
		case OBPS_ACTIONS:
			return @"Actions";
	};
	
	return nil;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath;
{
	switch ([indexPath section])
	{
		case OBPS_PREDICTIONS:
			if (predictions == nil)
			{
				if (error_cell_text)
					return [self cellForTable: tableView withText: error_cell_text];
				return [self cellForTable: tableView withText: @"Loading..."];
			}
			return [self predictionsCellForTable: tableView withData: [predictions objectAtIndex: [indexPath row]]];
		case OBPS_ACTIONS:
			switch ([indexPath row])
			{
				case OBPA_DIRECTIONS:
					return [self cellForTable: tableView withText: @"Directions"];
			};
			return nil;
	};
	
	return nil;
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
