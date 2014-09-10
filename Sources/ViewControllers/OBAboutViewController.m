// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBAboutViewController.h"

#import "OBInsetLabel.h"
#import "OTClient.h"
#import "OBTopViewController.h"

@implementation OBAboutViewController

@synthesize tabs, versionLabel, licenseTextView, headerView, tableView;

// called from background thread to set the text
- (void) setLicenseText: (NSString*) text
{
	[licenseTextView setText: text];
}

// done in the background, to load text
- (void) loadLicenses
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString* txtpath = [[NSBundle mainBundle] pathForResource: @"Licenses" ofType: @"txt"];
	NSString* text = [NSString stringWithContentsOfFile: txtpath encoding: NSUTF8StringEncoding error: nil];
	
	[self performSelectorOnMainThread: @selector(setLicenseText:) withObject: text waitUntilDone: YES];
	
	[pool release];
}

- (void) loadView
{
	// do a little dance, since apparently UITabBarControllers don't like being loaded with nibs
	[[NSBundle mainBundle] loadNibNamed: @"OBAboutViewController" owner: self options: nil];
	[super loadView];
	
	if (!headers)
	{
		headers = [[NSMutableArray alloc] initWithCapacity: OBAS_COUNT];
		for (unsigned int i = 0; i < OBAS_COUNT; i++)
		{
			OBInsetLabel* label = [[OBInsetLabel alloc] init];
			label.text = [self textForHeaderInSection: i];
			label.numberOfLines = 0;
			label.textAlignment = NSTextAlignmentLeft;
			label.lineBreakMode = NSLineBreakByWordWrapping;
			label.font = [UIFont fontWithName: OSU_BUS_NEW_UI_FONT_NAME size: 16];
			label.edgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
			
			[headers insertObject: label atIndex: i];
			[label release];
		}
	}
	
	tableView.tableHeaderView = headerView;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	[self setViewControllers: tabs animated: NO];
	[self setSelectedIndex: 0];
	
	NSString* db_ver = [[OTClient sharedClient] databaseVersion];
	[versionLabel setText: [NSString stringWithFormat: @"Version: %s | Database: %@", OSU_BUS_VERSION, db_ver]];
	
	[self performSelectorInBackground: @selector(loadLicenses) withObject: nil];
	
	NSLog(@"OBAboutViewController loaded");
}

- (void) viewDidUnload
{
	if (headers)
	{
		[headers release];
		headers = nil;
	}
	
	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return YES;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
	return OBAS_COUNT;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	switch (section)
	{
		case OBAS_CONTACT:
			return OBAC_CONTACT_END - OBAC_CONTACT_START - 1;
		case OBAS_SOURCE:
			return OBAC_SOURCE_END - OBAC_SOURCE_START - 1;
		case OBAS_DONATE:
			return OBAC_DONATE_END - OBAC_DONATE_START - 1;
	}
	return 0;
}

- (NSInteger) normalIndexForIndexPath: (NSIndexPath*) indexPath
{
	NSInteger idx = [indexPath indexAtPosition: 1];
	idx++;
	switch ([indexPath indexAtPosition: 0])
	{
		case OBAS_CONTACT:
			idx += OBAC_CONTACT_START;
			break;
		case OBAS_SOURCE:
			idx += OBAC_SOURCE_START;
			break;
		case OBAS_DONATE:
			idx += OBAC_DONATE_START;
			break;
	}
	return idx;
}

- (UITableViewCell*) tableView: (UITableView*) lTableView cellForRowAtIndexPath: (NSIndexPath*)indexPath
{
	UITableViewCell* cell = [lTableView dequeueReusableCellWithIdentifier: @"UITableViewCell"];
	if (!cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"UITableViewCell"] autorelease];
	}
	
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	switch ([self normalIndexForIndexPath: indexPath])
	{
		case OBAC_EMAIL:
			[cell.textLabel setText: @"email: griffith.637@osu.edu"];
			break;
		case OBAC_WEBSITE:
			[cell.textLabel setText: @"http://osubus.rakeri.net/"];
			break;
		case OBAC_SOURCE:
			[cell.textLabel setText: @"Browse the Source"];
			break;
		case OBAC_DONATE:
			[cell.textLabel setText: @"Donate!"];
			break;
	}
	
	return cell;
}

- (NSString*) textForHeaderInSection: (NSInteger) section
{
	switch (section)
	{
		case OBAS_CONTACT:
			return @"Do you like OSU Bus? Have ideas for the next version? Found a bug you want fixed? I would love to hear from you.";
		case OBAS_SOURCE:
			return @"This program uses data from the OSU TRIP program, as well as code from some open-source projects; see the \"Licenses\" tab for details. OSU Bus itself is free software: its source is distributed under the GNU GPL version 2.";
		case OBAS_DONATE:
			return @"OSU Bus is offered free of charge to those who find it useful. However, iPhone development is not free. If you like this App and use it often, consider donating the few bucks you would have spent for a non-free App.";
	}
	
	return nil;
}

- (UIView*) tableView: (UITableView*) lTableView viewForHeaderInSection: (NSInteger) section
{
	UIView* view = [headers objectAtIndex: section];
	CGRect frame = view.frame;
	frame.size.width = lTableView.frame.size.width;
	view.frame = frame;
	[view sizeToFit];
	[view retain];
	return view;
}

- (CGFloat)tableView: (UITableView*) lTableView heightForHeaderInSection: (NSInteger) section
{
	UIView* view = [self tableView: lTableView viewForHeaderInSection: section];
	NSUInteger height = view.frame.size.height;
	[view release];
	
	return height;
}

- (void) tableView: (UITableView*) lTableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	switch ([self normalIndexForIndexPath: indexPath])
	{
		case OBAC_EMAIL:
			[self showEmail];
			break;
		case OBAC_WEBSITE:
			[self showWebsite];
			break;
		case OBAC_SOURCE:
			[self showSource];
			break;
		case OBAC_DONATE:
			[self showDonate];
			break;
	}
}

- (IBAction) hideAboutView: (id) button
{
	[self.presentingViewController dismissModalViewControllerAnimated: YES];
}

- (void) showWebsite
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://osubus.rakeri.net/"]];
}

- (void) showEmail
{
	NSString* db_ver = [[OTClient sharedClient] databaseVersion];
	NSString* url = [NSString stringWithFormat: @"mailto:?to=griffith.637@osu.edu&subject=[OSU%%20Bus%%20%s-%@]%%20", OSU_BUS_VERSION, db_ver];
	
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (void) showSource
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://github.com/agrif/osubus/"]];
}

- (void) showDonate
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://osubus.rakeri.net/donate"]];
}

@end
