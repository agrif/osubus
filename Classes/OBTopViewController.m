// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBTopViewController.h"

#import "UILabel+SetTextAnimated.h"
#import "OTClient.h"

#import "OBBulletinsViewController.h"
#import "OBRoutesViewController.h"
#import "OBStopsViewController.h"
#import "OBPredictionsViewController.h"

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

- (void) viewWillAppear: (BOOL) animated
{
	if (favorites)
		[favorites release];
	if (favoritesData)
		[favoritesData release];
	
	favorites = [[NSMutableArray alloc] initWithArray: [[NSUserDefaults standardUserDefaults] arrayForKey: @"favorites"]];
	favoritesData = [[NSMutableArray alloc] init];
	
	for (NSNumber* fav in favorites)
	{
		[favoritesData addObject: [[OTClient sharedClient] stop: fav]];
	}
	
	//NSLog(@"favdata: %@", favorites);
	
	[self.tableView reloadData];
	
	[self.navigationItem setRightBarButtonItem: aboutButton];
	if ([favorites count] != 0)
	{
		[self.navigationItem setLeftBarButtonItem: editButton];
	} else {
		[self.navigationItem setLeftBarButtonItem: nil];
	}
}

- (void) startBulletinDisplay
{
	bulletinsLoaded = YES;
	[bulletinCell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	[NSTimer scheduledTimerWithTimeInterval: 3.0 target: self selector: @selector(updateBulletinCell:) userInfo: nil repeats: YES];
	[self updateBulletinCell: nil];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
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
	
	if ([source isEqual: @"osu"])
	{
		[bulletinTitleLabel setText: @"Service Bulletin" animated: animated];
	} else if ([source isEqual: @"gamma"]) {
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
		OBStopsViewController* stops = [[OBStopsViewController alloc] initWithNibName: @"OBStopsViewController" bundle: nil];
		// 40.002789 -83.016751 corner of tuttle garage
		[stops setLatitude: 40.002789 longitude: -83.016751];
		[self.navigationController pushViewController: stops animated: YES];
		[stops release];
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

# pragma mark Interface Builder Actions

- (IBAction) showAboutView: (id) sender
{
	if (aboutViewController == nil)
	{
		NSLog(@"Creating OBAboutViewController");
		[[NSBundle mainBundle] loadNibNamed: @"OBAboutViewController" owner: self options: nil];
		
		// note that tag 1 is the "version info" label on the front page
		UILabel* info = (UILabel*)[[[[aboutViewController viewControllers] objectAtIndex: 0] view] viewWithTag: 1];
		[info setText: [NSString stringWithFormat: @"Version: %s | Database: %s", OSU_BUS_VERSION, "TODO db ver"]];
	}
	
	[self.navigationController presentModalViewController: aboutViewController animated: YES];
}

- (IBAction) dismissAboutView: (id) sender
{
	[self.navigationController dismissModalViewControllerAnimated: YES];
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
