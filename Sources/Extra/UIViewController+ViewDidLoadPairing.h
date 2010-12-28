// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

// to my mind, viewDidLoad: and viewDidUnload: should be *paired*,
// so that viewDidUnload: is *always* eventually called, even
// when the controller is dealloc'd

// this category forces this behaviour by calling didReceiveMemoryWarning
// in dealloc

@interface UIViewController (ViewDidLoadPairing)

+ (void) load;
- (void) ViewDidLoadPairing_dealloc;

@end