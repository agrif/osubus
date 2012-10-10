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
	
	if (stop != nil || vehicle != nil)
	{
		NSLog(@"Loaded OBPredictionsViewController");
		
		// stop-view specific favorites stuff
		if (stop)
		{
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
			// vehicle setup
			[self.navigationItem setTitle: [NSString stringWithFormat: @"%@ %@", vehicle_route, vehicle]];
		};

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
	if (vehicle != nil)
	{
		[vehicle release];
		vehicle = nil;
	}
	if (vehicle_route != nil)
	{
		[vehicle_route release];
		vehicle_route = nil;
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
	//OBTopViewController* top = [self.navigationController.viewControllers objectAtIndex: 0];
	//OBMapViewController* map = top.mapViewController;
	//showMapAction = ![self.navigationController.viewControllers containsObject: map];
	showMapAction = YES;
}

- (void) viewDidAppear: (BOOL) animated
{
	predictions = nil;
	[self updateTimes: nil];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval: OSU_BUS_REFRESH_TIME target: self selector: @selector(updateTimes:) userInfo: nil repeats: YES];
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
	if (stop || vehicle)
		return;
	if (stop == nil)
		stop = [stopin retain];
}

- (void) setVehicle: (NSString*) vehiclein onRoute: (NSString*) route
{
	if (stop || vehicle)
		return;
	if (vehiclein == nil || route == nil)
		return;
	if (vehicle == nil)
	{
		vehicle = [vehiclein retain];
		vehicle_route = [route retain];
	}
}

- (void) toggleFavorite: (UIBarButtonItem*) button
{
	if (stop == nil)
		return;
	
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
	if (stop == nil)
		return;
	
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

- (void) animateFromPredictions: (NSArray*) old toPredictions: (NSArray*) new
{
	// sanity constants
	UITableViewRowAnimation insert_anim = UITableViewRowAnimationLeft;
	UITableViewRowAnimation delete_anim = UITableViewRowAnimationRight;
	
	// helper for nice animations
	[self.tableView	beginUpdates];
	
	// first, handle nil old
	NSUInteger nilpath[] = {0, 0};
	NSArray* nilpaths = [[NSArray alloc] initWithObjects: [NSIndexPath indexPathWithIndexes: nilpath length: 2], nil];
	if (!old)
		[self.tableView deleteRowsAtIndexPaths: nilpaths withRowAnimation: delete_anim];
	
	// now, compile lists of deleted and added
	// index paths to delete, the intersection (ordered as in old and new)
	// the paths corresponding to the intersection, relative to the old list,
	// and the index paths to add
	
	NSMutableArray* to_delete = [[NSMutableArray alloc] init];
	NSMutableArray* old_intersection = [[NSMutableArray alloc] init];
	NSMutableArray* intersection_paths = [[NSMutableArray alloc] init];
	NSMutableArray* new_intersection = [[NSMutableArray alloc] init];
	NSMutableArray* to_add = [[NSMutableArray alloc] init];
	
	if (old)
	{
		[old enumerateObjectsUsingBlock: ^(id prediction, NSUInteger i, BOOL* stop)
		 {
			 NSUInteger newidx = new ? [new indexOfObjectPassingTest: ^BOOL(id p, NSUInteger j, BOOL* stopinner)
										{
											return [[p objectForKey: @"id"] isEqual: [prediction objectForKey: @"id"]];
										}] : NSNotFound;
			 NSUInteger path[] = {0, i};
			 if (newidx == NSNotFound)
			 {
				 [to_delete addObject: [NSIndexPath indexPathWithIndexes: path length: 2]];
			 } else {
				 [old_intersection addObject: [prediction objectForKey: @"id"]];
				 // reloadRowsAtIndexPaths: always takes paths relative to the old info
				 [intersection_paths addObject: [NSIndexPath indexPathWithIndexes: path length: 2]];
			 }
		 }];
	}
	
	if (new)
	{
		[new enumerateObjectsUsingBlock: ^(id prediction, NSUInteger i, BOOL* stop)
		 {
			 NSUInteger oldidx = old ? [old indexOfObjectPassingTest: ^BOOL(id p, NSUInteger j, BOOL* stopinner)
										{
											return [[p objectForKey: @"id"] isEqual: [prediction objectForKey: @"id"]];
										}] : NSNotFound;
			 if (oldidx == NSNotFound)
			 {
				 NSUInteger path[] = {0, i};
				 [to_add addObject: [NSIndexPath indexPathWithIndexes: path length: 2]];
			 } else {
				 [new_intersection addObject: [prediction objectForKey: @"id"]];
			 }
		 }];
	}
	
	// commit the animation changes
	
	[self.tableView deleteRowsAtIndexPaths: to_delete withRowAnimation: delete_anim];
	
	if (![old_intersection isEqual: new_intersection])
	{
		// mixing!
		
		NSMutableArray* reload_paths = [[NSMutableArray alloc] init];
		[intersection_paths enumerateObjectsUsingBlock: ^(id path, NSUInteger i, BOOL* stop)
		 {
			 if (![[old_intersection objectAtIndex: i] isEqual: [new_intersection objectAtIndex: i]])
				 [reload_paths addObject: path];
		 }];
		
		[self.tableView reloadRowsAtIndexPaths: reload_paths withRowAnimation: UITableViewRowAnimationFade];
		[reload_paths release];
	}
	
	[self.tableView insertRowsAtIndexPaths: to_add withRowAnimation: insert_anim];
	
	// finally handle nil new
	if (!new)
		[self.tableView insertRowsAtIndexPaths: nilpaths withRowAnimation: insert_anim];
	
	[to_delete release];
	[old_intersection release];
	[new_intersection release];
	[intersection_paths release];
	[to_add	release];
	[nilpaths release];
	
	[self.tableView endUpdates];
}

#pragma mark Request Delegates

- (void) updateTimes: (NSTimer*) timer
{
	if (stop == nil && vehicle == nil)
		return;
	OTRequest* req = nil;
	if (stop)
	{
		req = [[OTClient sharedClient] requestPredictionsWithDelegate: self forStopIDs: [NSString stringWithFormat: @"%@", [stop objectForKey: @"id"]] count: 5];
	} else {
		req = [[OTClient sharedClient] requestPredictionsWithDelegate: self forVehicleIDs: [NSString stringWithFormat: @"%@", vehicle] count: 5];
	}
	[[UIApplication sharedApplication] setNetworkInUse: YES byObject: req];
}

- (void) request: (OTRequest*) request hasResult: (NSDictionary*) result
{
	NSArray* old_predictions = predictions;
	predictions = [[result objectForKey: @"prd"] retain];
	if (error_cell_text)
		[error_cell_text release];
	error_cell_text = nil;
	
	//NSLog(@"predictions: %@", predictions);
	
	while ([predictions count] > OSU_BUS_PREDICTIONS_COUNT)
		[predictions removeLastObject];
	
	for (NSMutableDictionary* prediction in predictions)
	{
		for (NSDictionary* route in routes)
		{
			if ([[route objectForKey: @"short"] isEqual: [prediction objectForKey: @"rt"]])
			{
				[prediction setObject: [route objectForKey: @"long"] forKey: @"rt"];
				[prediction setObject: [route objectForKey: @"short"] forKey: @"rtshort"];
				[prediction setObject: [route objectForKey: @"color"] forKey: @"color"];
				if (stop)
				{
					[prediction setObject: [prediction objectForKey: @"vid"] forKey: @"id"];
				} else {
					[prediction setObject: [prediction objectForKey: @"stpid"] forKey: @"id"];
				}
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
		[self animateFromPredictions: old_predictions toPredictions: predictions];
	}
	
	if (old_predictions)
		[old_predictions release];
	
	[[UIApplication sharedApplication] setNetworkInUse: NO byObject: request];
	[request release];
}

- (void) request: (OTRequest*) request hasError: (NSError*) error
{
	NSLog(@"error: %@", error);
	if (error_cell_text)
		[error_cell_text release];
	NSArray* old_predictions = predictions;
	predictions = nil;
	
	// take the error and stick it on the screen
	error_cell_text = [[error localizedDescription] copy];
	
	if (self.tableView)
	{
		[self animateFromPredictions: old_predictions toPredictions: predictions];
	}
	
	if (old_predictions)
		[old_predictions release];
	
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
					cell.textLabel.adjustsFontSizeToFitWidth = YES;
					[cell setAccessoryType: UITableViewCellAccessoryNone];
					return cell;
				}
				UITableViewCell* ret = [self cellForTable: tableView withText: @"Loading..."];
				[ret setAccessoryType: UITableViewCellAccessoryNone];
				return ret;
			}
			return [self predictionsCellForTable: tableView withData: [predictions objectAtIndex: [indexPath row]] forVehicle: (stop == nil)];
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
	return indexPath;
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
		if (stop)
		{
			[map setStop: stop];
		} else if (vehicle) {
			NSDictionary* route = [[OTClient sharedClient] routeWithShortName: vehicle_route];
			[map setVehicle: vehicle onRoute: route];
			[route release];
		}
		
		// remove the map from the stack, if it's there already
		if ([self.navigationController.viewControllers containsObject: map])
		{
			NSMutableArray* viewControllers = [self.navigationController.viewControllers mutableCopy];
			[viewControllers removeObject: map];
			[self.navigationController setViewControllers: viewControllers animated: NO];
			[viewControllers release];
		}
		
		// push onto stack
		[self.navigationController pushViewController: map animated: YES];
	} else if ([indexPath section] == OBPS_PREDICTIONS) {
		// push on a new predictions view
		OBPredictionsViewController* vc = [[OBPredictionsViewController alloc] initWithNibName: @"OBPredictionsViewController" bundle: nil];
		if (vehicle)
		{
			// new view is a stop-view
			NSDictionary* predstop = [[OTClient sharedClient] stop: [[predictions objectAtIndex: [indexPath row]] objectForKey: @"stpid"]];
			[vc setStop: predstop];
			[predstop release];
		} else {
			// new view is a vehicle-view
			[vc setVehicle: [[predictions objectAtIndex: [indexPath row]] objectForKey: @"vid"]
				   onRoute: [[predictions objectAtIndex: [indexPath row]] objectForKey: @"rtshort"]];
		}
		
		// we could potentially be entering a loop of prediction views, so limit them
		unsigned int num_predictions_views = 0;
		UIViewController* first_prediction_view = nil;
		for (UIViewController* controller in self.navigationController.viewControllers)
		{
			if ([controller isKindOfClass: [OBPredictionsViewController class]])
			{
				if (!first_prediction_view)
					first_prediction_view = controller;
				num_predictions_views++;
			}
		}
		
		// only allow so many prediction views at once, by removing the first if needed
		if (num_predictions_views >= OSU_BUS_PREDICTIONS_DEPTH)
		{
			NSMutableArray* viewControllers = [self.navigationController.viewControllers mutableCopy];
			[viewControllers removeObject: first_prediction_view];
			[self.navigationController setViewControllers: viewControllers animated: NO];
			[viewControllers release];
		}
		
		[self.navigationController pushViewController: vc animated: YES];
		
		[vc release];
	}
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

@end
