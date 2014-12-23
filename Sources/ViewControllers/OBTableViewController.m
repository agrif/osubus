// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBTableViewController.h"

#import "NSString+HexColor.h"
#import "UILabel+SetTextAnimated.h"
#import "OBColorBandView.h"
#import "OTClient.h"

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
	OSU_BUS_NEW_UI_FONTIFY(label);
	
	label = (UILabel*)[cell viewWithTag: 2];
	[label setText: [data objectForKey: @"short"]];
	[label setTextColor: [[data objectForKey: @"color"] colorFromHex]];
	if (OSU_BUS_NEW_UI)
		[label setShadowColor: [UIColor clearColor]];
	
	return cell;
}

// helper for setting a connected routes byline, and setting color bands
- (void) setupByline: (UILabel*) byline andColorBands: (OBColorBandView*) bands withStop: (NSDictionary*) stop
{
	// storage for colors
	NSMutableArray* colors = [[NSMutableArray alloc] initWithCapacity: [[stop objectForKey: @"routes"] count]];
	
	NSMutableString* subtitle = [[NSMutableString alloc] init];
	unsigned int i = 0;
	unsigned long routeslen = [[stop objectForKey: @"routes"] count];
	for (NSDictionary* route in [stop objectForKey: @"routes"])
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
	
	[byline setText: subtitle];
	[subtitle release];
	bands.colors = colors;
	[colors release];
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
	OSU_BUS_NEW_UI_FONTIFY(label);
	
	// set color bands and byline
	OBColorBandView* bands = (OBColorBandView*)[cell viewWithTag: 4];
	label = (UILabel*)[cell viewWithTag: 2];
	[self setupByline: label andColorBands: bands withStop: data];
	
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
	
	return cell;
}

- (void) animatePredictionsCell: (UITableViewCell*) cell withData: (NSDictionary*) data
{
	NSTimeInterval time = [(NSDate*)[data objectForKey: @"prdtm"] timeIntervalSinceNow] / 60;
	UILabel* label = (UILabel*)[cell viewWithTag: 2];
	if (time < 1.0)
	{
		[label setText: @"now" animated: YES];
	} else {
		[label setText: [NSString stringWithFormat: @"%i min", (int)time] animated: YES];
	}
}

- (UITableViewCell*) predictionsCellForTable: (UITableView*) tableView withData: (NSDictionary*) data forVehicle: (BOOL) vehicle
{
	// data comes directly as an element from requestPredictions...
	// tag 1 - route name label
	// tag 2 - prediction time label
	// tag 3 - destination label
	// tag 4 - color bar
	
	// these are reused for vehicle-based predictions:
	// tag 1 - stop name label
	// tag 3 - connected routes
	// tag 4 - route colors
	UITableViewCell* cell = [self cellForTable: tableView withIdentifier: @"OBPredictionsCell"];
	
	UILabel* label;
	
	// fetch the stop from the database, we need it if vehicle == YES
	NSDictionary* stop = nil;
	if (vehicle)
		stop = [[OTClient sharedClient] stop: [data objectForKey: @"stpid"]];
	
	label = (UILabel*)[cell viewWithTag: 1];
	OSU_BUS_NEW_UI_FONTIFY(label);
	if (vehicle)
	{
		[label setText: [stop objectForKey: @"name"]];
	} else {
		[label setText: [data objectForKey: @"rt"]];
	}
	
	NSTimeInterval time = [(NSDate*)[data objectForKey: @"prdtm"] timeIntervalSinceNow] / 60;
	label = (UILabel*)[cell viewWithTag: 2];
	if (time < 1.0)
	{
		[label setText: @"now"];
	} else {
		[label setText: [NSString stringWithFormat: @"%i min", (int)time]];
	}
	
	label = (UILabel*)[cell viewWithTag: 3];
	OBColorBandView* bands = (OBColorBandView*)[cell viewWithTag: 4];
	if (vehicle)
	{
		[self setupByline: label andColorBands: bands withStop: stop];
	} else {
		[label setText: [NSString stringWithFormat: @"%@ to %@", [data objectForKey: @"vid"], [data objectForKey: @"des"]]];
		
		NSArray* tmpcolors = [[NSArray alloc] initWithObjects: [[data objectForKey: @"color"] colorFromHex], nil];
		bands.colors = tmpcolors;
		[tmpcolors release];
	}
	
	return cell;
}

@end
