// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

// helper that implements iOS 5.0-like functionality for older
// OS versions as well

@interface UIViewController (PresentingCompat)

+ (void) load;
- (UIViewController*) PresentingCompat_presentingViewController;

@end