// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBTableViewController.h"

#import "NSString+HexColor.h"

@implementation OBTableViewController

@synthesize newCell;

- (UITableViewCell*) cellForTable: (UITableView*) tableView withIdentifier: (NSString*) cellIdentifier
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
	if (cell)
	{
		return cell;
	}
	
	[[NSBundle mainBundle] loadNibNamed: cellIdentifier owner: self options: nil];
	cell = newCell;
	[self setNewCell: nil];
	
	return cell;
}

- (UITableViewCell*) routesCellForTable: (UITableView*) tableView withData: (NSDictionary*) data
{
	// tag 1 - name label
	// tag 2 - short name label, with route color
	UITableViewCell* cell = [self cellForTable: tableView withIdentifier: @"OBRoutesCell"];
	
	UILabel* label;
	
	label = (UILabel*)[cell viewWithTag: 1];
	[label setText: [data objectForKey: @"long"]];
	
	label = (UILabel*)[cell viewWithTag: 2];
	[label setText: [data objectForKey: @"short"]];
	[label setTextColor: [[data objectForKey: @"color"] colorFromHex]];
	
	return cell;
}

#define STOPS_COLOR_FIRST_TAG 3
#define STOPS_COLOR_LAST_TAG 5

- (UITableViewCell*) stopsCellForTable: (UITableView*) tableView withData: (NSDictionary*) data
{
	// tag 1 - name label
	// tag 2 - subtitle label (for route names)
	// tag 3 - first color bar
	// tag 4 - second color bar
	// tag 5 - third color bar
	UITableViewCell* cell = [self cellForTable: tableView withIdentifier: @"OBStopsCell"];
	
	UILabel* label;
	
	label = (UILabel*)[cell viewWithTag: 1];
	[label setText: [data objectForKey: @"name"]];
	
	NSMutableString* subtitle = [[NSMutableString alloc] init];
	unsigned int tag = STOPS_COLOR_FIRST_TAG;
	unsigned int routeslen = [[data objectForKey: @"routes"] count];
	for (NSDictionary* route in [data objectForKey: @"routes"])
	{
		if (tag <= STOPS_COLOR_LAST_TAG)
		{
			[[cell viewWithTag: tag] setHidden: NO];
			[[cell viewWithTag: tag] setBackgroundColor: [[route objectForKey: @"color"] colorFromHex]];
		}
		
		if (tag == STOPS_COLOR_FIRST_TAG + routeslen - 1 && tag != STOPS_COLOR_FIRST_TAG) {
			[subtitle appendString: @" and "];
		} else if (tag != STOPS_COLOR_FIRST_TAG) {
			[subtitle appendString: @", "];
		}
		[subtitle appendString: [route objectForKey: @"short"]];
		
		tag++;
	}
	for (; tag <= STOPS_COLOR_LAST_TAG; tag++)
	{
		[[cell viewWithTag: tag] setHidden: YES];
	}
	
	label = (UILabel*)[cell viewWithTag: 2];
	[label setText: subtitle];
	[subtitle release];
	
	return cell;
}

@end
