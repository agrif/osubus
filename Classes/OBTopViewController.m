// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBTopViewController.h"

#import "UILabel+SetTextAnimated.h"
#import "OTClient.h"

#import "OBBulletinsViewController.h"

@implementation OBTopViewController

@synthesize aboutViewController;
@synthesize bulletinCell;
@synthesize emptyFavoritesCell;

@synthesize aboutButton;
@synthesize backButton;

@synthesize bulletinsViewController;

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

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	if (aboutViewController != nil)
	{
		[aboutViewController release];
		aboutViewController = nil;
	}
}

- (void) startBulletinDisplay
{
	bulletinsLoaded = YES;
	[bulletinCell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	[NSTimer scheduledTimerWithTimeInterval: 5.0 target: self selector: @selector(updateBulletinCell:) userInfo: nil repeats: YES];
	[self updateBulletinCell: nil];
}

- (void) updateBulletinCell: (NSTimer*) timer
{
	if (!(self.navigationController.topViewController == self && self.navigationController.modalViewController == nil))
		return;
	
	UILabel* bulletinLabel = (UILabel*)[bulletinCell viewWithTag: 1];
	UILabel* bulletinTitleLabel = (UILabel*)[bulletinCell viewWithTag: 2];
	
	BOOL animated = YES;
	
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
			return emptyFavoritesCell;
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
		return nil;
	return indexPath;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	// navigation logic
	
	if ([indexPath section] == OBTS_BULLETINS && bulletinsLoaded)
	{
		[self.navigationController pushViewController: bulletinsViewController animated: YES];
	}
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

# pragma mark Interface Builder Actions

- (IBAction) showAboutView: (id) sender
{
	if (aboutViewController == nil)
	{
		NSLog(@"Creating OBAboutViewController");
		[[NSBundle mainBundle] loadNibNamed: @"OBAboutViewController" owner: self options: nil];
	}
	
	[self.navigationController presentModalViewController: aboutViewController animated: YES];
}

- (IBAction) dismissAboutView: (id) sender
{
	[self.navigationController dismissModalViewControllerAnimated: YES];
}

@end
