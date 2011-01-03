// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBTableViewController.h"

#import "NSString+HexColor.h"
#import "OBColorBandView.h"

@implementation OBTableViewController

@synthesize tableView = _tableView;
@synthesize newCell;

// globally allow table views to autorotate
- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return YES;
}

// stub implementations of data source methods to pacify compiler
- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) path
{
	return nil;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	return 0;
}

- (UITableViewCell*) cellForTable: (UITableView*) tableView withIdentifier: (NSString*) cellIdentifier
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
	if (cell)
	{
		return cell;
	}
	
	if ([cellIdentifier isEqual: @"UITableViewCell"])
	{
		return [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier] autorelease];
	}
	
	[[NSBundle mainBundle] loadNibNamed: cellIdentifier owner: self options: nil];
	cell = newCell;
	[self setNewCell: nil];
	
	return cell;
}


- (UITableViewCell*) cellForTable: (UITableView*) tableView withText: (NSString*) text
{
	UITableViewCell* cell = [self cellForTable: tableView withIdentifier: @"UITableViewCell"];
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	[cell.textLabel setText: text];
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
	// tag 3 - distance label
	// tag 4 - color band view
	UITableViewCell* cell = [self cellForTable: tableView withIdentifier: @"OBStopsCell"];
	
	UILabel* label;
	
	label = (UILabel*)[cell viewWithTag: 1];
	[label setText: [data objectForKey: @"name"]];
	
	// storage for colors
	NSMutableArray* colors = [[NSMutableArray alloc] initWithCapacity: [[data objectForKey: @"routes"] count]];
	
	NSMutableString* subtitle = [[NSMutableString alloc] init];
	unsigned int i = 0;
	unsigned int routeslen = [[data objectForKey: @"routes"] count];
	for (NSDictionary* route in [data objectForKey: @"routes"])
	{
		[colors addObject: [[route objectForKey: @"color"] colorFromHex]];
		
		if (i == routeslen - 1 && i != 0) {
			[subtitle appendString: @" and "];
		} else if (i != 0) {
			[subtitle appendString: @", "];
		}
		[subtitle appendString: [route objectForKey: @"short"]];
		
		i++;
	}
	
	// set color bands
	OBColorBandView* bands = (OBColorBandView*)[cell viewWithTag: 4];
	bands.colors = colors;
	[colors release];
	
	label = (UILabel*)[cell viewWithTag: 2];
	[label setText: subtitle];
	
	label = (UILabel*)[cell viewWithTag: 3];
	
	if ([[data allKeys] containsObject: @"dist"])
	{
		BOOL isMetric = [[NSUserDefaults standardUserDefaults] boolForKey: @"metric_preference"];
		//BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
		
		double dist = [[data objectForKey: @"dist"] doubleValue];
		
		if (isMetric)
		{
			int meters = dist;
			[label setText: [NSString stringWithFormat: @"%i %s", meters, meters == 1 ? "meter" : "meters"]];
		} else {
			double miles = (dist * 0.621371192) / 1000;
			int feet = miles * 5280;
			
			if (miles > 0.4)
			{
				[label setText: [NSString stringWithFormat: @"%.01f miles", miles]];
			} else {
				[label setText: [NSString stringWithFormat: @"%i %s", feet, feet == 1 ? "foot" : "feet"]];
			}
		}
		[label setHidden: NO];
	} else {
		[label setHidden: YES];
	}
	
	[subtitle release];
	
	return cell;
}

- (UITableViewCell*) predictionsCellForTable: (UITableView*) tableView withData: (NSDictionary*) data
{
	// data comes directly as an element from requestPredictions...
	// tag 1 - route name label
	// tag 2 - prediction time label
	// tag 3 - destination label
	// tag 4 - color bar
	UITableViewCell* cell = [self cellForTable: tableView withIdentifier: @"OBPredictionsCell"];
	
	UILabel* label;
	
	label = (UILabel*)[cell viewWithTag: 1];
	[label setText: [data objectForKey: @"rt"]];
	
	NSTimeInterval time = [(NSDate*)[data objectForKey: @"prdtm"] timeIntervalSinceNow] / 60;
	label = (UILabel*)[cell viewWithTag: 2];
	if (time < 1.0)
	{
		[label setText: @"now"];
	} else if ((int)time == 1) {
		[label setText: @"1 minute"];
	} else {
		[label setText: [NSString stringWithFormat: @"%i minutes", (int)time]];
	}
	
	label = (UILabel*)[cell viewWithTag: 3];
	[label setText: [NSString stringWithFormat: @"to %@", [data objectForKey: @"des"]]];
	
	UIView* colorbar = [cell viewWithTag: 4];
	[colorbar setBackgroundColor: [[data objectForKey: @"color"] colorFromHex]];
	
	return cell;
}

@end
