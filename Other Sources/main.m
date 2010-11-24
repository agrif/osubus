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
	NSString* pathToDB = [[paths objectAtIndex:0] stringByAppendingPathComponent: @"cabs.db"];
	
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathToDB];
	
	// if it doesn't exist, copy the db out of the bundle so we can write to it
	// FIXME don't overwrite, or do, based on relative database age
	if (!fileExists)
	{
		[[NSFileManager defaultManager] copyItemAtPath: [[NSBundle mainBundle] pathForResource: @"cabs" ofType: @"db"] toPath: pathToDB error: NULL];
	}
	
	[[OTClient sharedClient] setAPIKey: @"HgejWEsJAycCRf8gzsSWVHMcy"];
	[[OTClient sharedClient] setDatabasePath: pathToDB];
	
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
