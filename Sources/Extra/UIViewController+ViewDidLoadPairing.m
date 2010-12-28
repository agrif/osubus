// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "UIViewController+ViewDidLoadPairing.h"

#import "NSObject+Swizzle.h"

static BOOL swizzled = NO;

@implementation UIViewController (ViewDidLoadPairing)

+ (void) load
{
	if (!swizzled)
	{
		[[self class] swizzleMethod: @selector(dealloc) withMethod: @selector(ViewDidLoadPairing_dealloc)];
		swizzled = YES;
	}
}

- (void) ViewDidLoadPairing_dealloc
{
	[self didReceiveMemoryWarning];
	[self ViewDidLoadPairing_dealloc];
}

@end
