// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBPredictionsViewController.h"

#import "OTClient.h"
#import "UIApplication+NiceNetworkIndicator.h"
#import "OBTopViewController.h"
#import "OBMapViewController.h"

@implementation OBPredictionsViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	routes = [[OTClient sharedClient] routes];
	
	addButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"favorites-add"] style: UIBarButtonItemStyleBordered target: self action: @selector(toggleFavorite:)];
	
	if (stop != nil)
	{
		NSLog(@"Loaded OBPredictionsViewController");
		
		if ([[[NSUserDefaults standardUserDefaults] arrayForKey: @"favorites"] containsObject: [stop objectForKey: @"id"]])
		{
			addButton.image = [UIImage imageNamed: @"favorites-remove"];
			isFavorite = YES;
		} else {
			isFavorite = NO;
		}
		
		[self.navigationItem setRightBarButtonItem: addButton];
		[self.navigationItem setTitle: [stop objectForKey: @"name"]];
	} else {
		// do something else, mainly, fail spectacularly!
	}
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	
	if (predictions != nil)
	{
		[predictions release];
		predictions = nil;
	}
	if (stop != nil)
	{
		[stop release];
		stop = nil;
	}
	if (routes != nil)
	{
		[routes release];
		routes = nil;
	}
	if (error_cell_text != nil)
	{
		[error_cell_text release];
		error_cell_text = nil;
	}
	if (addButton != nil)
	{
		[addButton release];
		addButton = nil;
	}
}

- (void) viewWillAppear: (BOOL) animated
{
	OBTopViewController* top = [self.navigationController.viewControllers objectAtIndex: 0];
	OBMapViewController* map = top.mapViewController;
	showMapAction = ![self.navigationController.viewControllers containsObject: map];
}

- (void) viewDidAppear: (BOOL) animated
{
	predictions = nil;
	error_cell_text = nil;
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

- (void) setStop: (NSDictionary*) stopin
{
	if (stop == nil)
		stop = [stopin retain];
}

- (void) updateTimes: (NSTimer*) timer
{
	if (stop == nil)
		return;
	OTRequest* req = [[OTClient sharedClient] requestPredictionsWithDelegate: self forStopIDs: [NSString stringWithFormat: @"%@", [stop objectForKey: @"id"]] count: 5];
	[[UIApplication sharedApplication] setNetworkInUse: YES byObject: req];
}

- (void) toggleFavorite: (UIBarButtonItem*) button
{
	UIActionSheet* actionSheet;
	if (isFavorite)
	{
		actionSheet = [[UIActionSheet alloc] initWithTitle: @"Remove this route from favorites?" delegate: self cancelButtonTitle: nil destructiveButtonTitle: nil otherButtonTitles: @"Yes", @"No", nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle: @"Add this route to favorites?" delegate: self cancelButtonTitle: nil destructiveButtonTitle: nil otherButtonTitles: @"Yes", @"No", nil];
	}
	
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.cancelButtonIndex = 1;
	[actionSheet showInView: self.view];
	[actionSheet release];
}

- (void) actionSheet: (UIActionSheet*) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex
{
	if (buttonIndex == 0)
	{
		if (isFavorite)
		{
			// user clicked YES, remove from favorites
			addButton.image = [UIImage imageNamed: @"favorites-add"];
			
			NSMutableArray* defaults = [[[NSUserDefaults standardUserDefaults] arrayForKey: @"favorites"] mutableCopy];
			[defaults removeObject: [stop objectForKey: @"id"]];
			[[NSUserDefaults standardUserDefaults] setValue: defaults forKey: @"favorites"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[defaults release];
			
			isFavorite = NO;
		} else {
			// user clicked YES, add to favorites
			addButton.image = [UIImage imageNamed: @"favorites-remove"];
			
			NSMutableArray* defaults = [[[NSUserDefaults standardUserDefaults] arrayForKey: @"favorites"] mutableCopy];
			[defaults addObject: [stop objectForKey: @"id"]];
			[[NSUserDefaults standardUserDefaults] setValue: defaults forKey: @"favorites"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[defaults release];
			
			isFavorite = YES;
		}
	}
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
	
	//NSLog(@"predictions: %@", predictions);
	
	for (NSMutableDictionary* prediction in predictions)
	{
		for (NSDictionary* route in routes)
		{
			if ([[route objectForKey: @"short"] isEqual: [prediction objectForKey: @"rt"]])
			{
				[prediction setObject: [route objectForKey: @"long"] forKey: @"rt"];
				[prediction setObject: [route objectForKey: @"color"] forKey: @"color"];
				break;
			}
		}
	}
	
	if ([predictions count] == 0)
	{
		error_cell_text = [[NSString alloc] initWithString: @"No upcoming arrivals."];
		[predictions release];
		predictions = nil;
	}
	
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
	if (error_cell_text)
		[error_cell_text release];
	if (predictions)
		[predictions release];
	predictions = nil;
	
	// take the error and stick it on the screen
	error_cell_text = [[error localizedDescription] copy];
	
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
	return OBPS_COUNT - ([self tableView: tableView numberOfRowsInSection: OBPS_ACTIONS] > 0 ? 0 : 1);
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
			return OBPA_COUNT - (showMapAction ? 0 : 1);
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
				{
					UITableViewCell* cell = [self cellForTable: tableView withText: error_cell_text];
					[cell setAccessoryType: UITableViewCellAccessoryNone];
					return cell;
				}
				UITableViewCell* ret = [self cellForTable: tableView withText: @"Loading..."];
				[ret setAccessoryType: UITableViewCellAccessoryNone];
				return ret;
			}
			return [self predictionsCellForTable: tableView withData: [predictions objectAtIndex: [indexPath row]]];
		case OBPS_ACTIONS:
			switch ([indexPath row])
			{
				case OBPA_MAP:
					
					return [self cellForTable: tableView withText: @"Show on Map"];
			};
			return nil;
	};
	
	return nil;
}

#pragma mark Table View Delegate

- (NSIndexPath*) tableView: (UITableView*) tableView willSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	if ([indexPath section] == OBPS_ACTIONS)
		return indexPath;
	return nil;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	if ([indexPath section] == OBPS_ACTIONS && [indexPath row] == OBPA_MAP)
	{
		// get the root view controller, then the map controller
		OBTopViewController* top = [self.navigationController.viewControllers objectAtIndex: 0];
		OBMapViewController* map = top.mapViewController;
		
		// setup map
		[map clearMap];
		[map setStop: stop];
		
		// push onto stack
		[self.navigationController pushViewController: map animated: YES];
	}
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

@end
