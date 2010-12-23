// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBMapViewController.h"

@implementation OBMapViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.navigationItem setTitle: @"Map"];
	
	NSLog(@"OBMapViewController loaded");
}

- (void) viewDidUnload
{
	NSLog(@"OBMapViewController unloaded");
    [super viewDidUnload];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
