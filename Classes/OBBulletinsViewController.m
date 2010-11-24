// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBBulletinsViewController.h"

#import "OBTopViewController.h"
#import "OBBulletinViewController.h"

@implementation OBBulletinsViewController

@synthesize bulletins;
@synthesize updateURL;

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.navigationItem setTitle: @"News"];
	NSLog(@"OBBulletinsViewController loaded");
}

- (void) loadBulletins: (OBTopViewController*) caller
{
	topViewController = caller;
	requestedCustom = NO;
	self.bulletins = [NSMutableArray array];
	
	NSArray* routes = [[OTClient sharedClient] routes];
	NSMutableString* rtstring = [[NSMutableString alloc] init];
	BOOL first = YES;
	for (NSDictionary* route in routes)
	{
		if (first)
		{
			first = NO;
			[rtstring appendString: [route objectForKey: @"short"]];
		} else {
			[rtstring appendFormat: @",%@", [route objectForKey: @"short"]];
		}
	}
	//NSLog(@"routestring: %@", rtstring);
	
	[[OTClient sharedClient] requestServiceBulletinsWithDelegate: self forRoutes: rtstring];
	[rtstring release];
}

- (void) dealloc
{
	if (bulletins)
		self.bulletins = nil;
	if (updateURL)
		self.updateURL = nil;
	[super dealloc];
}

- (void) request: (OTRequest*) request hasResult: (NSDictionary*) result
{
	//NSLog(@"bulletins: %@", result);
	for (NSInteger i = 0; i < [[result objectForKey: @"sb"] count]; ++i)
	{
		if ([[[result objectForKey: @"sb"] objectAtIndex: i] objectForKey: @"srvc"] != nil)
		{
			// FIXME non-global service bulletins
			// we used to ignore... in the future, look for a better way to include all
			// bulletins, even non-globals like these
			//continue;
		}
		NSString* title = [[[result objectForKey: @"sb"] objectAtIndex: i] objectForKey: @"sbj"];
		NSString* body = [[[result objectForKey: @"sb"] objectAtIndex: i] objectForKey: @"dtl"];
		
		// special value meaning UPDATE THE FREAKING DATABASE (WHOO!)
		if ([title isEqual: @"!!!DBUPDATE"])
		{
			self.updateURL = body;
		} else {
			[bulletins addObject: [NSDictionary dictionaryWithObjectsAndKeys: title, @"title", body, @"body", requestedCustom ? @"gamma" : @"osu", @"source", nil]];
		}
	}
	
	if (requestedCustom == NO)
	{
		endOfOfficialBulletins = [bulletins count];
		
		requestedCustom = YES;
		[[OTClient sharedClient] requestCustomServiceBulletinsWithDelegate: self forRoutes: @""];
	} else {
		// we've got customs
		[topViewController startBulletinDisplay];
		topViewController = nil;
	}
	
	[request release];
}

- (void) request: (OTRequest*) request hasError: (NSError*) error
{
	NSLog(@"request error: %@", error);
	[topViewController startBulletinDisplay];
	topViewController = nil;
	[request release];
}

#pragma mark Table View Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView;
{
	return 2;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	switch (section)
	{
		case 0:
			return endOfOfficialBulletins;
		case 1:
			return [bulletins count] - endOfOfficialBulletins;
	}
	return 0;
}

- (NSString*) tableView: (UITableView*) tableView titleForHeaderInSection: (NSInteger) section
{
	switch (section)
	{
		case 0:
			return endOfOfficialBulletins > 0 ? @"Service Bulletins" : nil;
		case 1:
			return [bulletins count] - endOfOfficialBulletins > 0 ? @"Application News" : nil;
	}
	
	return nil;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath;
{
	NSString* cellIdentifier = @"UITableViewCell";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier] autorelease];
	}
	
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	
	NSInteger index = [indexPath row];
	if ([indexPath section] == 1)
		index += endOfOfficialBulletins;
	
	[[cell textLabel] setText: [[bulletins objectAtIndex: index] objectForKey: @"title"]];
	
	return cell;		
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	NSInteger index = [indexPath row];
	if ([indexPath section] == 1)
		index += endOfOfficialBulletins;
	
	// title, body, source
	OBBulletinViewController* bulletin = [[OBBulletinViewController alloc] initWithNibName: @"OBBulletinViewController" bundle: nil];
	[bulletin setBulletin: [bulletins objectAtIndex: index]];
	[self.navigationController pushViewController: bulletin animated: YES];
	[bulletin release];
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

@end
