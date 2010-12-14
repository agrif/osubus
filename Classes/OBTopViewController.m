// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBTopViewController.h"

#import "UILabel+SetTextAnimated.h"
#import "OTClient.h"

#import "OBBulletinsViewController.h"
#import "OBAboutViewController.h"
#import "OBRoutesViewController.h"
#import "OBStopsViewController.h"
#import "OBPredictionsViewController.h"
#import "MBProgressHUD.h"

@implementation OBTopViewController

@synthesize aboutViewController;
@synthesize bulletinCell;
@synthesize emptyFavoritesCell;

@synthesize aboutButton;
@synthesize editButton;
@synthesize doneButton;
@synthesize backButton;

@synthesize bulletinsViewController;

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	//[aboutViewController setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
	
	[self.navigationItem setTitle: @""];
	[self.navigationItem setBackBarButtonItem: backButton];
	
	[(UILabel*)[bulletinCell viewWithTag: 1] setText: @""];
	[(UILabel*)[bulletinCell viewWithTag: 2] setText: @"Loading..."];
	
	bulletinID = -1;
	bulletinsLoaded = NO;
	[bulletinsViewController loadBulletins: self];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
	
	locManager = [[CLLocationManager alloc] init];
	[locManager setDelegate: self];
	
	// setup HUD, show with no text for startup
	hud = [[MBProgressHUD alloc] initWithView: self.navigationController.view];
	[self.navigationController.view addSubview: hud];
	[hud setBackgroundColor: [UIColor colorWithWhite: 0.0 alpha: 0.5]];
	[hud setOpacity: 0.0];
	[hud show: NO];
	[(UIActivityIndicatorView*)[hud indicator] setHidden: YES];
	
	editMode = NO;
}

- (void) viewDidUnload
{
	if (aboutViewController != nil)
		[aboutViewController release];
	if (favorites != nil)
		[favorites release];
	if (favoritesData != nil)
		[favoritesData release];
	if (locManager != nil)
		[locManager release];
	if (hud != nil)
		[hud release];
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	if (aboutViewController != nil)
	{
		[aboutViewController release];
		aboutViewController = nil;
	}
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return YES;
}

- (void) viewWillAppear: (BOOL) animated
{
	BOOL firstRun = NO;
	
	if (favorites == nil)
	{
		firstRun = YES;
		
		// NOTE uncomment this to keep OSU Bus from going any farther
		// useful for getting a new Default.png
		//bulletinsLoaded = YES;
		//return;
		
		// handle hud-hiding for first launch
		[hud hide: YES];
		
		[self.tableView reloadData];
	}
	
	if (favorites)
		[favorites release];
	if (favoritesData)
		[favoritesData release];
	
	favorites = [[NSMutableArray alloc] initWithArray: [[NSUserDefaults standardUserDefaults] arrayForKey: @"favorites"]];
	favoritesData = [[NSMutableArray alloc] init];
	
	NSMutableArray* outdatedFavs = [[NSMutableArray alloc] init];
	
	for (NSNumber* fav in favorites)
	{
		NSDictionary* stop = [[OTClient sharedClient] stop: fav];
		if (stop == nil)
		{
			// this is an old stop that has been removed from the DB
			[outdatedFavs addObject: fav];
			continue;
		}
		
		[favoritesData addObject: [[OTClient sharedClient] stop: fav]];
	}
	
	for (NSDictionary* fav in outdatedFavs)
	{
		[favorites removeObject: fav];
	}
	
	[outdatedFavs release];
	[self saveFavorites];
	
	//NSLog(@"favdata: %@", favorites);
	
	if (firstRun)
	{
		NSRange range;
		range.location = OBTS_FAVORITES;
		range.length = 1;
		[self.tableView reloadSections: [NSIndexSet indexSetWithIndexesInRange: range] withRowAnimation: UITableViewRowAnimationFade];
	} else {
		[self.tableView reloadData];
	}
	
	[self.navigationItem setRightBarButtonItem: aboutButton animated: firstRun];
	if ([favorites count] != 0)
	{
		[self.navigationItem setLeftBarButtonItem: editButton animated: firstRun];
	} else {
		[self.navigationItem setLeftBarButtonItem: nil animated: firstRun];
	}
}

- (void) startBulletinDisplay
{
	// no matter what, clear that network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	
	// failsafe check...
	if (bulletinsLoaded)
		return;
	
	bulletinsLoaded = YES;
	[bulletinCell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	[NSTimer scheduledTimerWithTimeInterval: 3.0 target: self selector: @selector(updateBulletinCell:) userInfo: nil repeats: YES];
	[self updateBulletinCell: nil];
	
	// check to see if DB needs updating...
	if ([bulletinsViewController updateURL])
	{
		// we DO! ACK!
		
		UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle: @"A new route database is available. Would you like to update now? It will only take a few seconds!" delegate: self cancelButtonTitle: nil destructiveButtonTitle: nil otherButtonTitles: @"Yes", @"No", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		actionSheet.cancelButtonIndex = 1;
		[actionSheet showInView: self.view];
		[actionSheet release];
	}
}

// action sheet for db update question
- (void) actionSheet: (UIActionSheet*) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex
{
	if (buttonIndex == 0)
	{
		// user clicked YES, update database!
		NSURLRequest* theRequest = [NSURLRequest requestWithURL: [NSURL URLWithString: [bulletinsViewController updateURL]] 
												 cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
												 timeoutInterval: 30.0];
		
		NSURLConnection* theConnection = [[NSURLConnection alloc] initWithRequest: theRequest delegate: self];
		if (theConnection)
		{
			receivedData = [[NSMutableData alloc] init];
			[hud setLabelText: @"Downloading database..."];
			[hud setOpacity: 0.9];
			[(UIActivityIndicatorView*)[hud indicator] setHidden: NO];
			[hud show: YES];
		} else {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Download Failed" message: @"The database download failed. Please try again later." delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[alert show];
			[alert release];
		}
	}
}

// for db update download
- (void) connection: (NSURLConnection*) connection didReceiveResponse: (NSURLResponse*) response
{
	if ([(NSHTTPURLResponse*)response statusCode] != 200)
	{
		[self connection: connection didFailWithError: nil];
		return;
	}
	
	if (receivedData)
		[receivedData setLength: 0];
}

// for db download
- (void) connection: (NSURLConnection*) connection didReceiveData: (NSData*) data
{
	if (receivedData)
		[receivedData appendData: data];
}

// for db download
- (void) connection: (NSURLConnection*) connection didFailWithError: (NSError*) error
{
	[connection release];
	[receivedData release];
	receivedData = nil;
	[hud hide: YES];
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Download Failed" message: @"The database download failed. Please try again later." delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
	
    //NSLog(@"Connection failed! Error - %@ %@",
    //      [error localizedDescription],
    //      [[error userInfo] objectForKey: NSErrorFailingURLStringKey]);	
}

// for db download
- (void) connectionDidFinishLoading: (NSURLConnection*) connection
{
	if (receivedData)
	{
		//NSLog(@"data: %@", receivedData);
		[[OTClient sharedClient] writeNewDatabase: receivedData];
		[hud hide: YES];
		
		[connection release];
		[receivedData release];
		receivedData = nil;
	}
}

- (void) updateBulletinCell: (NSTimer*) timer
{
	BOOL animated = YES;
	if (!(self.navigationController.topViewController == self && self.navigationController.modalViewController == nil))
		animated = NO;
	
	UILabel* bulletinLabel = (UILabel*)[bulletinCell viewWithTag: 1];
	UILabel* bulletinTitleLabel = (UILabel*)[bulletinCell viewWithTag: 2];
	
	if ([[bulletinsViewController bulletins] count] == 0)
	{
		[bulletinLabel setText: @"" animated: animated];
		[bulletinTitleLabel setText: @"No Service Bulletins" animated: animated];
		return;
	}
	
	bulletinID++;
	if (bulletinID == [[bulletinsViewController bulletins] count])
		bulletinID = 0;
	
	[bulletinLabel setText: [[[bulletinsViewController bulletins] objectAtIndex: bulletinID] objectForKey: @"title"] animated: animated];
	
	NSString* source = [[[bulletinsViewController bulletins] objectAtIndex: bulletinID] objectForKey: @"source"];
	
	if ([source isEqual: @"official"])
	{
		[bulletinTitleLabel setText: @"Service Bulletin" animated: animated];
	} else if ([source isEqual: @"custom"]) {
		[bulletinTitleLabel setText: @"Application News" animated: animated];
	}
}

#pragma mark Table View Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView;
{
	return OBTS_COUNT;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	switch (section)
	{
		case OBTS_BULLETINS:
			return 1;
		case OBTS_NAVIGATION:
			return OBTO_COUNT;
		case OBTS_FAVORITES:
			if (favorites == nil)
				return 0;
			if ([favorites count] > 0)
				return [favorites count];
			return 1;
	};
	
	return 0;
}

- (NSString*) tableView: (UITableView*) tableView titleForHeaderInSection: (NSInteger) section
{
	switch (section)
	{
		case OBTS_BULLETINS:
			return nil;
		case OBTS_NAVIGATION:
			return @"Navigation";
		case OBTS_FAVORITES:
			return @"Favorites";
	};
	
	return nil;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath;
{
	switch ([indexPath section])
	{
		case OBTS_BULLETINS:
			return bulletinCell;
		case OBTS_NAVIGATION:
			return [self tableView: tableView navigationCellForIndex: [indexPath row]];
		case OBTS_FAVORITES:
			if (favorites == nil)
				return nil;
			if ([favorites count] == 0)
				return emptyFavoritesCell;
			return [self stopsCellForTable: tableView withData: [favoritesData objectAtIndex: [indexPath row]]];
	};
	
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

/*
- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
	if ([indexPath section] == OBTS_BULLETINS)
		return 100; // size of header cell
	return 44; // size of all other cells
}
 */

- (NSIndexPath*) tableView: (UITableView*) tableView willSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	if ([indexPath section] == OBTS_BULLETINS && !bulletinsLoaded)
		return nil;
	if ([indexPath section] == OBTS_FAVORITES)
		return [favorites count] == 0 ? nil : indexPath;
	return indexPath;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	// navigation logic
	
	if ([indexPath section] == OBTS_BULLETINS && bulletinsLoaded)
	{
		[self.navigationController pushViewController: bulletinsViewController animated: YES];
	} else if ([indexPath section] == OBTS_NAVIGATION && [indexPath row] == OBTO_ROUTES) {
		OBRoutesViewController* routes = [[OBRoutesViewController alloc] initWithNibName: @"OBRoutesViewController" bundle: nil];
		[self.navigationController pushViewController: routes animated: YES];
		[routes release];
	} else if ([indexPath section] == OBTS_NAVIGATION && [indexPath row] == OBTO_STOPS) {
		OBStopsViewController* stops = [[OBStopsViewController alloc] initWithNibName: @"OBStopsViewController" bundle: nil];
		[self.navigationController pushViewController: stops animated: YES];
		[stops release];
	} else if ([indexPath section] == OBTS_NAVIGATION && [indexPath row] == OBTO_NEARME) {
		gpsStartDate = [[NSDate alloc] init];
		[self performSelector: @selector(locationTimeout) withObject: nil afterDelay: GPS_MAX_WAIT];
		[locManager startUpdatingLocation];
		hud.labelText = @"Getting Position...";
		[hud setOpacity: 0.9];
		[(UIActivityIndicatorView*)[hud indicator] setHidden: NO];
		[hud show: YES];
	} else if ([indexPath section] == OBTS_FAVORITES && [favorites count] != 0) {
		OBPredictionsViewController* predictions = [[OBPredictionsViewController alloc] initWithNibName: @"OBPredictionsViewController" bundle: nil];
		[predictions setStop: [favoritesData objectAtIndex: [indexPath row]]];
		[self.navigationController pushViewController: predictions animated: YES];
		[predictions release];
	}
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

# pragma mark Editing

- (BOOL) tableView: (UITableView*) tableView canEditRowAtIndexPath: (NSIndexPath*) indexPath
{
	if ([indexPath section] != OBTS_FAVORITES)
	{
		return NO;
	}
	
	return ([favorites count] != 0);
}

- (void) tableView: (UITableView*) tableView commitEditingStyle: (UITableViewCellEditingStyle) editingStyle forRowAtIndexPath: (NSIndexPath*) indexPath
{
	if ([indexPath section] != OBTS_FAVORITES || [favorites count] == 0)
		return;
	
	[favorites removeObjectAtIndex: [indexPath row]];
	[favoritesData removeObjectAtIndex: [indexPath row]];
	if ([favorites count] == 0)
	{
		[tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil] withRowAnimation: UITableViewRowAnimationRight];
	} else {
		[tableView deleteRowsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil] withRowAnimation: UITableViewRowAnimationRight];
	}
	
	[self saveFavorites];
	
	// handle this for slide-to-delete
	if ([favorites count] == 0)
	{
		[self.navigationItem setLeftBarButtonItem: nil animated: YES];
	}
}

- (BOOL) tableView: (UITableView*) tableView canMoveRowAtIndexPath: (NSIndexPath*) indexPath
{
	if ([indexPath section] != OBTS_FAVORITES)
	{
		return NO;
	}
	
	return ([favorites count] != 0);
}

- (NSIndexPath*) tableView: (UITableView*) tableView targetIndexPathForMoveFromRowAtIndexPath: (NSIndexPath*) source toProposedIndexPath: (NSIndexPath*) destination
{
	if ([destination section] != OBTS_FAVORITES)
	{
		return [NSIndexPath indexPathForRow: 0 inSection: 2];
	}
	
	return destination;
}

- (void) tableView: (UITableView*) tableView moveRowAtIndexPath: (NSIndexPath*) source toIndexPath: (NSIndexPath*) destination
{
	NSNumber* stopid = [favorites objectAtIndex: [source row]];
	[favorites removeObjectAtIndex: [source row]];
	[favorites insertObject: stopid atIndex: [destination row]];
	
	NSDictionary* data = [favoritesData objectAtIndex: [source row]];
	[favoritesData removeObjectAtIndex: [source row]];
	[favoritesData insertObject: data atIndex: [destination row]];
	
	[self saveFavorites];
}

- (void) saveFavorites
{
	[[NSUserDefaults standardUserDefaults] setObject: favorites forKey: @"favorites"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

# pragma mark GPS fun

- (void) locationTimeout
{
	// force an update
	[gpsStartDate release];
	gpsStartDate = nil;
	[self locationManager: locManager didUpdateToLocation: locManager.location fromLocation: nil];
}

- (void) locationManager: (CLLocationManager*) manager didUpdateToLocation: (CLLocation*) newLocation fromLocation: (CLLocation*) oldLocation
{
	// if we're not on top...
	if ([self.navigationController topViewController] != self)
	{
		[manager stopUpdatingLocation];
		if (gpsStartDate)
			[gpsStartDate release];
		[hud hide: YES];
		return;
	}
	
	// throw away bad locations, if we're under 10 seconds
	if (gpsStartDate != nil && [gpsStartDate timeIntervalSinceNow] > -GPS_MAX_WAIT)
	{
		if ([newLocation horizontalAccuracy] > GPS_ACCURACY)
			return;
	}
	
	NSLog(@"accuracy: %f", [newLocation horizontalAccuracy]);
	
	[manager stopUpdatingLocation];
	if (gpsStartDate)
		[gpsStartDate release];
	[hud hide: YES];
	
	OBStopsViewController* stops = [[OBStopsViewController alloc] initWithNibName: @"OBStopsViewController" bundle: nil];
	// 40.002789 -83.016751 corner of tuttle garage
	[stops setLatitude: [newLocation coordinate].latitude longitude: [newLocation coordinate].longitude];
	[self.navigationController pushViewController: stops animated: YES];
	[stops release];
}

- (void) locationManager: (CLLocationManager*) manager didFailWithError: (NSError*) error
{
	[manager stopUpdatingLocation];
	[hud hide: YES];
	if (gpsStartDate)
		[gpsStartDate release];
	
	NSLog(@"GPS Error: %@", [error localizedDescription]);
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Your location cannot be retreived." delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
	[alertView show];
	[alertView release];
}

# pragma mark Interface Builder Actions

- (IBAction) showAboutView: (id) sender
{
	if (aboutViewController == nil)
	{
		aboutViewController = [[OBAboutViewController alloc] initWithNibName: @"OBAboutViewController" bundle: nil];
	}
	
	[self.navigationController presentModalViewController: aboutViewController animated: YES];
}

- (IBAction) beginEdit: (id) sender
{
	if (editMode == YES)
		return;
	
	[self.navigationItem setRightBarButtonItem: doneButton animated: YES];
	[self.navigationItem setLeftBarButtonItem: nil animated: YES];
	
	// cancel swipe-edit, but cause whole-edit
	[self.tableView setEditing: NO animated: NO];
	[self.tableView setEditing: YES animated: YES];
	
	editMode = YES;
}

- (IBAction) endEdit: (id) sender
{
	if (editMode == NO)
		return;
	
	[self.navigationItem setRightBarButtonItem: aboutButton animated: YES];
	if ([favorites count] != 0)
		[self.navigationItem setLeftBarButtonItem: editButton animated: YES];
	
	[self.tableView setEditing: NO animated: YES];
	
	[self saveFavorites];
	
	editMode = NO;
}

@end
