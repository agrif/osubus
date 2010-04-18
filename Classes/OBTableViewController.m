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

- (UITableViewCell*) stopsCellForTable: (UITableView*) tableView withData: (NSDictionary*) data
{
	// tag 1 - name label
	// tag 2 - subtitle label (for route names)
	// tag 3 - first color bar
	// tag 4 - second color bar
	// tag 5 - third color bar
	NSLog(@"cell %@", data);
	UITableViewCell* cell = [self cellForTable: tableView withIdentifier: @"OBStopsCell"];
	
	UILabel* label;
	
	label = (UILabel*)[cell viewWithTag: 1];
	[label setText: [data objectForKey: @"name"]];
	
	NSMutableString* subtitle = [[NSMutableString alloc] init];
	unsigned int tag = 3;
	for (NSDictionary* route in [data objectForKey: @"routes"])
	{
		if (tag <= 5)
		{
			[[cell viewWithTag: tag] setHidden: NO];
			[[cell viewWithTag: tag] setBackgroundColor: [[route objectForKey: @"color"] colorFromHex]];
		}
		
		if (tag != 3)
		{
			[subtitle appendString: @"  "];
		}
		[subtitle appendString: [route objectForKey: @"short"]];
		
		tag++;
	}
	for (; tag <= 5; tag++)
	{
		[[cell viewWithTag: tag] setHidden: YES];
	}
	
	label = (UILabel*)[cell viewWithTag: 2];
	[label setText: subtitle];
	[subtitle release];
	
	return cell;
}

@end
