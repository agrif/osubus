// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
// 
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#import <UIKit/UIKit.h>

#import "OTClient.h"

int main(int argc, char* argv[])
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	// set the local application time zone
	// this all only makes sense in OSU's time zone
	NSTimeZone* tz = [[NSTimeZone alloc] initWithName: @"US/Eastern"];
	[NSTimeZone setDefaultTimeZone: tz];
	[tz release];
	
	// handle the database setup
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* rwDB = [[paths objectAtIndex:0] stringByAppendingPathComponent: @"cabs.db"];
	NSString* bundleDB = [[NSBundle mainBundle] pathForResource: @"cabs" ofType: @"db"];
	
	BOOL rwDBExists = [[NSFileManager defaultManager] fileExistsAtPath: rwDB];
	
	BOOL dbNeedsCopying = NO;
	NSFileManager* fm = [NSFileManager defaultManager];
	
	if (rwDBExists)
	{
		// check to see if the bundle copy is newer than the RW copy
		// if it is, set dbNeedsCopying to YES
		
		NSDate* rwDate = [[fm attributesOfItemAtPath: rwDB error: NULL] fileModificationDate];
		NSDate* bundleDate = [[fm attributesOfItemAtPath: bundleDB error: NULL] fileModificationDate];
		
		//NSLog(@"rwDate: %@ bundleDate: %@", rwDate, bundleDate);
		
		if ([bundleDate timeIntervalSinceDate: rwDate] > 0)
			dbNeedsCopying = YES;
	} else {
		// RW copy does not exist, we need to copy it
		dbNeedsCopying = YES;
	}
	
	if (dbNeedsCopying)
	{
		NSLog(@"copying over database");
		// remove old path, if it exists
		// this is to prevent a bug where the mod times aren't copied over
		if (rwDBExists)
			[fm removeItemAtPath: rwDB error: NULL];
		[fm copyItemAtPath: bundleDB toPath: rwDB error: NULL];
	}
	
	[[OTClient sharedClient] setAPIKey: @"HgejWEsJAycCRf8gzsSWVHMcy"];
	[[OTClient sharedClient] setDatabasePath: rwDB];
	
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
