// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

// register and unregister objects as using the network,
// to prevent network activity clobber

@interface UIApplication (NiceNetworkIndicator)

- (void) setNetworkInUse: (BOOL) inUse byObject: (NSObject*) obj;

@end