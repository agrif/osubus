// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBVehicleViewController.h"

#import "OTClient.h"
#import "UIApplication+NiceNetworkIndicator.h"

@implementation OBVehicleViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	if (vehicle != nil)
	{
		NSLog(@"Loaded OBVehicleViewController");
		
		[self.navigationItem setTitle: @"placeholder"];
	} else {
		// do something else, mainly, fail spectacularly!
	}
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	
	if (vehicle != nil)
	{
		[vehicle release];
		vehicle = nil;
	}
	
	if (error_cell_text != nil)
	{
		[error_cell_text release];
		error_cell_text = nil;
	}
	
	if (predictions != nil)
	{
		[predictions release];
		predictions = nil;
	}
}

- (void) viewDidAppear: (BOOL) animated
{
	[self updateTimes: nil];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval: 30.0 target: self selector: @selector(updateTimes:) userInfo: nil repeats: YES];
}

- (void) viewDidDisappear: (BOOL) animated
{
	if (refreshTimer)
	{
		[refreshTimer invalidate];
		refreshTimer = nil;
	}
}

- (void) setVehicle: (NSNumber*) vehiclein
{
	if (vehiclein != nil)
		vehicle = [vehiclein retain];
}

- (void) updateTimes: (NSTimer*) timer
{
	NSLog(@"vehicle: %@", vehicle);
	if (vehicle == nil)
		return;
	OTRequest* req = [[OTClient sharedClient] requestPredictionsWithDelegate: self forVehicleIDs: [NSString stringWithFormat: @"%@", vehicle] count: 5];
	[[UIApplication sharedApplication] setNetworkInUse: YES byObject: req];
}

#pragma mark Request Delegates

- (void) request: (OTRequest*) request hasResult: (NSDictionary*) result
{
	if (error_cell_text)
		[error_cell_text release];
	error_cell_text = nil;
	
	if (predictions)
		[predictions release];
	predictions = [[result objectForKey: @"prd"] retain];
	
	if (self.tableView)
	{
		NSRange range;
		range.location = 0;
		range.length = 1;
		[self.tableView reloadSections: [NSIndexSet indexSetWithIndexesInRange: range] withRowAnimation: UITableViewRowAnimationFade];
	}
	
	[[UIApplication sharedApplication] setNetworkInUse: NO byObject: request];
	[request release];
}

- (void) request: (OTRequest*) request hasError: (NSError*) error
{
	NSLog(@"error: %@", error);
	
	// take the error and stick it on the screen
	if (error_cell_text)
		[error_cell_text release];
	error_cell_text = [[error localizedDescription] copy];
	
	if (predictions)
		[predictions release];
	predictions = nil;
	
	if (self.tableView)
	{
		NSRange range;
		range.location = 0;
		range.length = 1;
		[self.tableView reloadSections: [NSIndexSet indexSetWithIndexesInRange: range] withRowAnimation: UITableViewRowAnimationFade];
	}
	
	[[UIApplication sharedApplication] setNetworkInUse: NO byObject: request];
	[request release];
}

#pragma mark Table View Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView;
{
	return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	if (predictions)
		return [predictions count];
	return 1;
}

- (NSString*) tableView: (UITableView*) tableView titleForHeaderInSection: (NSInteger) section
{
	return nil;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath;
{
	UITableViewCell* ret = nil;
	if (predictions)
	{
		ret = [self cellForTable: tableView withText: @"content"];
	} else {
		if (error_cell_text)
		{
			ret = [self cellForTable: tableView withText: error_cell_text];
		} else {
			ret = [self cellForTable: tableView withText: @"Loading..."];
		}		
		[ret setAccessoryType: UITableViewCellAccessoryNone];
	}
	
	return ret;
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
