// tripdb - a database updater for OSU Bus
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

#import <Foundation/Foundation.h>
#import "OTClient.h"

int main(int argc, char** argv)
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	if (argc != 2)
	{
		NSLog(@"Usage: tribdb [db path]");
		return 1;
	}
	
	[[OTClient sharedClient] setAPIKey: @"HgejWEsJAycCRf8gzsSWVHMcy"];
	[[OTClient sharedClient] setDatabasePath: [NSString stringWithCString: argv[1]]];
	
	[[OTClient  sharedClient] updateDatabase];
	
    [pool drain];
    return 0;
}
