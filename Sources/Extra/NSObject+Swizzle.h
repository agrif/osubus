// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <Foundation/Foundation.h>

@interface NSObject (Swizzle)

+ (void) swizzleMethod: (SEL) orig_sel withMethod: (SEL) alt_sel;
+ (void) swizzleClassMethod: (SEL) orig_sel withClassMethod: (SEL) alt_sel;

@end